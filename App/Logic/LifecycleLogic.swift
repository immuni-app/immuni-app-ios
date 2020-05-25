// LifecycleLogic.swift
// Copyright (C) 2020 Presidenza del Consiglio dei Ministri.
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

import BackgroundTasks
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
        // Set the app name used in the application using the bundle's display name
        if let appName = context.dependencies.bundle.appDisplayName {
          try context.awaitDispatch(SetAppName(appName: appName))
        }

        // Set the app version used in the application using the bundle
        if let appVersion = context.dependencies.bundle.appVersion,
          let bundleVersion = context.dependencies.bundle.bundleVersion {
          try context.awaitDispatch(SetAppVersion(appVersion: "\(appVersion) (\(bundleVersion))"))
        }

        /// starts the exposure manager if possible
        try await(context.dependencies.exposureNotificationManager.startIfAuthorized())

        // refresh statuses
        try context.awaitDispatch(Logic.Lifecycle.RefreshAuthorizationStatuses())

        // update today variable
        let now = context.dependencies.now()
        try context.awaitDispatch(Logic.Shared.UpdateToday(today: now.calendarDay))

        // clears `PositiveExposureResults` older than 14 days from the `ExposureDetectionState`
        try context.awaitDispatch(Logic.ExposureDetection.ClearOutdatedResults(now: context.dependencies.now()))

        // Update user language
        try context.awaitDispatch(SetUserLanguage(language: UserLanguage(from: context.dependencies.locale)))

        // Perform exposure detection if necessary
        context.dispatch(Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .foreground))

        // Removes notifications as the user has opened the app
        context.dispatch(Logic.CovidStatus.RemoveRiskReminderNotification())
      }
    }

    /// Launched when app is about to enter in foreground
    struct WillEnterForeground: AppSideEffect, NotificationObserverDispatchable {
      init?(notification: Notification) {
        guard notification.name == UIApplication.willEnterForegroundNotification else {
          return nil
        }
      }

      func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        // refresh statuses
        try context.awaitDispatch(RefreshAuthorizationStatuses())

        // update today variable
        let now = context.dependencies.now()
        try context.awaitDispatch(Logic.Shared.UpdateToday(today: now.calendarDay))

        // clears `PositiveExposureResults` older than 14 days from the `ExposureDetectionState`
        try context.awaitDispatch(Logic.ExposureDetection.ClearOutdatedResults(now: context.dependencies.now()))

        // check whether to show force update
        try context.awaitDispatch(ForceUpdate.CheckAppVersion())

        // Perform exposure detection if necessary
        context.dispatch(Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .foreground))

        // Removes notifications as the user has opened the app
        context.dispatch(Logic.CovidStatus.RemoveRiskReminderNotification())
      }
    }

    /// Launched when app did become active.
    /// Note that when the app is in foreground and the command center is opened / closed, `didBecomeActiveNotification`
    /// will be dispatched, but not `willEnterForegroundNotification`.
    struct DidBecomeActive: AppSideEffect, NotificationObserverDispatchable {
      init?(notification: Notification) {
        guard notification.name == UIApplication.didBecomeActiveNotification else {
          return nil
        }
      }

      func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        // refresh statuses
        try context.awaitDispatch(RefreshAuthorizationStatuses())

        // update today variable
        let now = context.dependencies.now()
        try context.awaitDispatch(Logic.Shared.UpdateToday(today: now.calendarDay))

        // update analaytics info
        try context.awaitDispatch(Logic.Analytics.UpdateOpportunityWindowIfNeeded())

        // Perform exposure detection if necessary
        context.dispatch(Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .foreground))
      }
    }

    /// Launched when there is a significant change in time, for example, change to a new day.
    struct SignificantTimeChange: AppSideEffect, NotificationObserverDispatchable {
      init?(notification: Notification) {
        guard notification.name == UIApplication.significantTimeChangeNotification else {
          return nil
        }
      }

      func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        // update today variable
        let now = context.dependencies.now()
        try context.awaitDispatch(Logic.Shared.UpdateToday(today: now.calendarDay))
      }
    }

    /// Performed when the system launches the app in the background to run the exposure detection task.
    struct HandleExposureDetectionBackgroundTask: AppSideEffect {
      /// The background task that dispatched this SideEffect
      var task: BGTask

      func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        // update today variable
        let now = context.dependencies.now()
        try context.awaitDispatch(Logic.Shared.UpdateToday(today: now.calendarDay))

        // clears `PositiveExposureResults` older than 14 days from the `ExposureDetectionState`
        try context.awaitDispatch(Logic.ExposureDetection.ClearOutdatedResults(now: context.dependencies.now()))

        // update analaytics info
        try context.awaitDispatch(Logic.Analytics.UpdateOpportunityWindowIfNeeded())

        // Update the configuration, with a timeout. Continue in any case in order not to waste an Exposure Detection cycle.
        try? await(context.dispatch(Logic.Configuration.DownloadAndUpdateConfiguration()).timeout(timeout: 10))

        // Dispatch the exposure detection
        context.dispatch(Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .background(self.task)))
      }
    }
  }
}

// MARK: Helper Side Effects

extension Logic.Lifecycle {
  struct RefreshAuthorizationStatuses: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let pushStatus = try await(context.dependencies.pushNotification.getCurrentAuthorizationStatus())
      let exposureStatus = try await(context.dependencies.exposureNotificationManager.getStatus())

      try context.awaitDispatch(UpdateAuthorizationStatus(
        pushNotificationAuthorizationStatus: pushStatus,
        exposureNotificationAuthorizationStatus: exposureStatus
      ))
    }
  }
}

// MARK: Private State Updaters

private extension Logic.Lifecycle {
  /// Update and store the app name used in the application using the bundle's display name
  private struct SetAppName: AppStateUpdater {
    let appName: String

    func updateState(_ state: inout AppState) {
      state.environment.appName = self.appName
    }
  }

  /// Update and store the app version
  private struct SetAppVersion: AppStateUpdater {
    let appVersion: String

    func updateState(_ state: inout AppState) {
      state.environment.appVersion = self.appVersion
    }
  }

  /// Updates the authorization statuses
  private struct UpdateAuthorizationStatus: AppStateUpdater {
    let pushNotificationAuthorizationStatus: UNAuthorizationStatus
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
}
