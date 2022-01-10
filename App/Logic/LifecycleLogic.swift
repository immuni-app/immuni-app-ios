// LifecycleLogic.swift
// Copyright (C) 2022 Presidenza del Consiglio dei Ministri.
// Please refer to the AUTHORS file for more information.
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

import Alamofire
import BackgroundTasks
import Extensions
import Foundation
import Hydra
import ImmuniExposureNotification
import Katana
import Models
import PushNotification

extension Logic {
  enum Lifecycle {
    /// Launched when app is started
    struct OnStart: AppSideEffect, OnStartObserverDispatchable {
      func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        let state = context.getState()

        // Perform any necessary migration
        try context.awaitDispatch(PerformMigrationsIfNecessary())

        // Preload animation assets. Check `PreloadAssets` action for better documentation.
        context.dispatch(Logic.Shared.PreloadAssets())

        // refresh statuses
        try context.awaitDispatch(Logic.Lifecycle.RefreshAuthorizationStatuses())
        try context.awaitDispatch(Logic.Lifecycle.RefreshNetworkReachabilityStatus())

        // Update user language
        try context.awaitDispatch(SetUserLanguage(language: UserLanguage(from: context.dependencies.locale)))

        // Update the app info using the bundle info
        try context.awaitDispatch(UpdateAppInfo(bundle: context.dependencies.bundle))

        let isFirstLaunch = !state.toggles.isFirstLaunchSetupPerformed

        // Perform the setup related to the first launch of the application, if needed
        try context.awaitDispatch(PerformFirstLaunchSetupIfNeeded())

        // starts the exposure manager if possible
        try Hydra.await(context.dependencies.exposureNotificationManager.startIfAuthorized())

        // clears `PositiveExposureResults` older than 14 days from the `ExposureDetectionState`
        try context.awaitDispatch(Logic.ExposureDetection.ClearOutdatedResults(now: context.dependencies.now()))

        guard !context.dependencies.application.isBackground else {
          NSLog(
            "[DEBUG] Stopping Onstart because not in foreground \(context.dependencies.application.applicationState.rawValue)"
          )
          // Background sessions are handled in `HandleExposureDetectionBackgroundTask`
          return
        }

        // Removes notifications as the user has opened the app
        context.dispatch(Logic.CovidStatus.RemoveRiskReminderNotification())

        // refresh the analytics token if expired, silently catching errors so that the exposure detection can be performed
        try? context.awaitDispatch(Logic.Analytics.RefreshAnalyticsTokenIfNeeded())

        // update analytics event without exposure opportunity window if expired
        try context.awaitDispatch(Logic.Analytics.UpdateEventWithoutExposureOpportunityWindowIfNeeded())

        // update analytics dummy opportunity window if expired
        try context.awaitDispatch(Logic.Analytics.UpdateDummyTrafficOpportunityWindowIfExpired())

        // Download the Configuration with a given timeout
        let configurationFetch = context
          .dispatch(Logic.Configuration.DownloadAndUpdateConfiguration())
          .timeout(timeout: 10)

        // Fail silently in case of error (for example, the timeout triggering)
        try? Hydra.await(configurationFetch)

        guard !isFirstLaunch else {
          // Nothing else to do if it's the first launch
          return
        }

        // Perform exposure detection if necessary
        context.dispatch(Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .foreground))

        // updates the ingestion dummy traffic opportunity window if it expired
        try context.awaitDispatch(Logic.DataUpload.UpdateDummyTrafficOpportunityWindowIfExpired())

        // schedules a dummy sequence of ingestion requests for some point in the future
        try context.awaitDispatch(Logic.DataUpload.ScheduleDummyIngestionSequenceIfNecessary())
      }
    }

    /// Launched when app is about to enter in foreground
    struct WillEnterForeground: AppSideEffect, NotificationObserverDispatchable {
      init() {}

      init?(notification: Notification) {
        guard notification.name == UIApplication.willEnterForegroundNotification else {
          return nil
        }
      }

      func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        // Perform any necessary migration
        try context.awaitDispatch(PerformMigrationsIfNecessary())

        // refresh statuses
        try context.awaitDispatch(RefreshAuthorizationStatuses())

        // schedule background task
        try context.awaitDispatch(ScheduleBackgroundTask())

        // clears `PositiveExposureResults` older than 14 days from the `ExposureDetectionState`
        try context.awaitDispatch(Logic.ExposureDetection.ClearOutdatedResults(now: context.dependencies.now()))

        // Removes notifications as the user has opened the app
        context.dispatch(Logic.CovidStatus.RemoveRiskReminderNotification())

        // check whether to show force update
        try context.awaitDispatch(ForceUpdate.CheckAppVersion())

        // refresh the analytics token if expired, silently catching errors so that the exposure detection can be performed
        try? context.awaitDispatch(Logic.Analytics.RefreshAnalyticsTokenIfNeeded())

        // update analytics event without exposure opportunity window if expired
        try context.awaitDispatch(Logic.Analytics.UpdateEventWithoutExposureOpportunityWindowIfNeeded())

        // update analytics dummy opportunity window if expired
        try context.awaitDispatch(Logic.Analytics.UpdateDummyTrafficOpportunityWindowIfExpired())

        // Perform exposure detection if necessary
        context.dispatch(Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .foreground))

        // updates the ingestion dummy traffic opportunity window if it expired
        try context.awaitDispatch(Logic.DataUpload.UpdateDummyTrafficOpportunityWindowIfExpired())

        // schedules a dummy sequence of ingestion requests for some point in the future
        try context.awaitDispatch(Logic.DataUpload.ScheduleDummyIngestionSequenceIfNecessary())
      }
    }

    /// Launched when app did become active.
    /// Note that when the app is in foreground and the command center is opened / closed, `didBecomeActiveNotification`
    /// will be dispatched, but not `willEnterForegroundNotification`.
    struct DidBecomeActive: AppSideEffect, NotificationObserverDispatchable {
      init() {}

      init?(notification: Notification) {
        guard notification.name == UIApplication.didBecomeActiveNotification else {
          return nil
        }
      }

      func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        // dismiss sensitive data overlay. Check `SensitiveDataCoverVC` documentation.
        context.dispatch(Logic.Shared.HideSensitiveDataCoverIfPresent())

        // refresh statuses
        try context.awaitDispatch(RefreshAuthorizationStatuses())

        /// removes uneeded notifications
        try context.awaitDispatch(Logic.ExposureDetection.RemoveLocalNotificationIfNotNeeded())
      }
    }

    /// Launched when app will resign active.
    struct WillResignActive: AppSideEffect, NotificationObserverDispatchable {
      init() {}

      init?(notification: Notification) {
        guard notification.name == UIApplication.willResignActiveNotification else {
          return nil
        }
      }

      func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        // show sensitive data overlay. Check `SensitiveDataCoverVC` documentation.
        context.dispatch(Logic.Shared.ShowSensitiveDataCoverIfNeeded())
      }
    }

    /// Launched when the app entered background
    struct DidEnterBackground: AppSideEffect, NotificationObserverDispatchable {
      init() {}

      init?(notification: Notification) {
        guard notification.name == UIApplication.didEnterBackgroundNotification else {
          return nil
        }
      }

      func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        // schedule background task
        try context.awaitDispatch(ScheduleBackgroundTask())

        // resets the state related to dummy sessions
        try context.awaitDispatch(Logic.DataUpload.MarkForegroundSessionFinished())
      }
    }

    /// Performed when the system launches the app in the background to run the exposure detection task.
    struct HandleExposureDetectionBackgroundTask: AppSideEffect {
      /// The background task that dispatched this SideEffect
      var task: BackgroundTask

      func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        // Perform any necessary migration
        try context.awaitDispatch(PerformMigrationsIfNecessary())

        // clears `PositiveExposureResults` older than 14 days from the `ExposureDetectionState`
        try context.awaitDispatch(Logic.ExposureDetection.ClearOutdatedResults(now: context.dependencies.now()))

        /// removes uneeded notifications
        try context.awaitDispatch(Logic.ExposureDetection.RemoveLocalNotificationIfNotNeeded())

        // refresh the analytics token if expired, silently catching errors so that the exposure detection can be performed
        try? context.awaitDispatch(Logic.Analytics.RefreshAnalyticsTokenIfNeeded())

        // update analytics event without exposure opportunity window if expired
        try context.awaitDispatch(Logic.Analytics.UpdateEventWithoutExposureOpportunityWindowIfNeeded())

        // update analytics dummy opportunity window if expired
        try context.awaitDispatch(Logic.Analytics.UpdateDummyTrafficOpportunityWindowIfExpired())

        // updates the ingestion dummy traffic opportunity window if it expired
        try context.awaitDispatch(Logic.DataUpload.UpdateDummyTrafficOpportunityWindowIfExpired())

        // Update the configuration, with a timeout. Continue in any case in order not to waste an Exposure Detection cycle.
        try? Hydra.await(context.dispatch(Logic.Configuration.DownloadAndUpdateConfiguration()).timeout(timeout: 10))

        // Dispatch the exposure detection
        context.dispatch(Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .background(self.task)))
      }
    }
  }
}

// MARK: Helper Side Effects

extension Logic.Lifecycle {
  struct PerformFirstLaunchSetupIfNeeded: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      guard !state.toggles.isFirstLaunchSetupPerformed else {
        // The first launch setup was already performed
        return
      }
      /// Initialize the stochastic parameters required for the generation of dummy ingestion traffic.
      try context.awaitDispatch(Logic.DataUpload.UpdateDummyTrafficOpportunityWindow())

      // flags the first launch as done to prevent further downloads during the startup phase
      try context.awaitDispatch(PassFirstLaunchExecuted())
    }
  }

  struct RefreshAuthorizationStatuses: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let pushStatus = try Hydra.await(context.dependencies.pushNotification.getCurrentAuthorizationStatus())
      let exposureStatus = try Hydra.await(context.dependencies.exposureNotificationManager.getStatus())

      try context.awaitDispatch(UpdateAuthorizationStatus(
        pushNotificationAuthorizationStatus: pushStatus,
        exposureNotificationAuthorizationStatus: exposureStatus
      ))
    }
  }

  /// Refreshes the network reachability status in the state
  struct RefreshNetworkReachabilityStatus: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      guard let status = context.dependencies.reachabilityManager?.status else {
        return
      }
      context.dispatch(UpdateNetworkReachabilityStatus(value: status))
    }
  }

  /// Schedules the background task
  struct ScheduleBackgroundTask: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let appDelegate = mainThread { context.dependencies.application.delegate as? AppDelegate }
        ?? AppLogger.fatalError("Missing or wrong AppDelegate")

      appDelegate.scheduleBackgroundTask()
    }
  }
}

// MARK: Private State Updaters

private extension Logic.Lifecycle {
  /// Update app info using the bundle info.
  private struct UpdateAppInfo: AppStateUpdater {
    let bundle: Bundle

    func updateState(_ state: inout AppState) {
      if let appName = self.bundle.appDisplayName {
        state.environment.appName = appName
      }
      if let appVersion = self.bundle.appVersion,
         let bundleVersion = self.bundle.bundleVersion
      {
        state.environment.appVersion = "\(appVersion) (\(bundleVersion))"
      }
      let device = UIDevice.current
      state.environment.osVersion = "\(device.systemName) (\(device.systemVersion))"
      state.environment.deviceModel = device.modelName
    }
  }

  /// Update the network reachability status
  private struct UpdateNetworkReachabilityStatus: AppStateUpdater {
    let value: NetworkReachabilityManager.NetworkReachabilityStatus
    func updateState(_ state: inout AppState) {
      state.environment.networkReachabilityStatus = self.value
    }
  }

  /// Updates the authorization statuses
  private struct UpdateAuthorizationStatus: AppStateUpdater {
    let pushNotificationAuthorizationStatus: PushNotificationStatus
    let exposureNotificationAuthorizationStatus: ExposureNotificationStatus

    func updateState(_ state: inout AppState) {
      state.environment.pushNotificationAuthorizationStatus = self.pushNotificationAuthorizationStatus
      state.environment.exposureNotificationAuthorizationStatus = self.exposureNotificationAuthorizationStatus
    }
  }

  /// Update the user language
  private struct SetUserLanguage: AppStateUpdater {
    let language: UserLanguage

    func updateState(_ state: inout AppState) {
      state.environment.userLanguage = self.language
    }
  }

  /// Marks the first launch executed as done
  struct PassFirstLaunchExecuted: AppStateUpdater {
    func updateState(_ state: inout AppState) {
      state.toggles.isFirstLaunchSetupPerformed = true
    }
  }
}

// MARK: - Migrations

extension Logic.Lifecycle {
  /// Performs all necessary migrations, blockingly.
  struct PerformMigrationsIfNecessary: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Logic.ExposureDetection.ClearRiskStatusIfWronglyAttributed())
    }
  }
}

// MARK: - Helpers

extension UIApplication {
  var isBackground: Bool {
    mainThread {
      self.applicationState == .background
    }
  }
}
