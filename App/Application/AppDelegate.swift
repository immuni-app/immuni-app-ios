// AppDelegate.swift
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
import Extensions
import Foundation
import Katana
import Logging
import Persistence
import StorePersistence
import Tempura
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate, RootInstaller {
  var window: UIWindow?

  lazy var store: Store<AppState, AppDependencies> = {
    Store<AppState, AppDependencies>(
      interceptors: self.storeInterceptors,
      stateInitializer: self.persistStore.katanaStateInitializer
    )
  }()

  lazy var persistStore: PersistStore<AppState> = {
    guard let intBuildVersion = Bundle.main.intBuildVersion else {
      AppLogger.fatalError("Bundle Version missing")
    }

    let secretsStorage = SecretsStorage(bundle: .main)

    return PersistStore<AppState>(
      storage: FileManager.default,
      encryptionKey: secretsStorage.getOrCreateSymmetricKey(for: SecretsStorageKeys.storagePasswordKey),
      currentBuildVersion: intBuildVersion
    )
  }()

  func application(
    _ application: UIApplication,
    // swiftlint:disable:next discouraged_optional_collection
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // set log level
    #if DEBUG
      Log.isProduction = false
    #else
      Log.isProduction = true
    #endif

    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window
    window.overrideUserInterfaceStyle = .light
    window.makeKeyAndVisible()

    self.store.dependencies?.navigator.start(
      using: self,
      in: window,
      at: Screen.appSetup.rawValue
    )

    UNUserNotificationCenter.current().delegate = self

    self.registerExposureDetectionBackgroundTask()

    return true
  }
}

// MARK: - Background Task

extension AppDelegate {
  /// Whitelisted in the `Info.plist`
  // swiftlint:disable:next identifier_name
  static let exposureDetectionBackgroundTaskIdentifier = "\(Bundle.main.unwrappedBundleIdentifier).exposure-notification"

  /// Registers and schedule background task for exposure detection
  func registerExposureDetectionBackgroundTask() {
    guard #available(iOS 13.5, *) else {
      /// if iOS 13.5 is not available, it makes no sense to schedule the background task
      return
    }

    BGTaskScheduler.shared
      .register(forTaskWithIdentifier: AppDelegate.exposureDetectionBackgroundTaskIdentifier, using: nil) { task in

        // Signals that the background task has started. This has an effect only in debug mode, and it's extracted here
        // To ensure that there is nothing preventing this notification from being scheduled.
        if self.store.state.toggles.isBackgroundTaskDebugMode {
          self.store.dependencies.pushNotification.scheduleLocalNotification(
            .init(title: "Background task started", body: "\(Date().fullDateWithMillisString)\nBackground task has started"),
            with: .timeInterval(5)
          )
        }

        // Handle the background task
        self.store.dispatch(Logic.Lifecycle.HandleExposureDetectionBackgroundTask(task: task))

        // Reschedule background task
        self.scheduleBackgroundTask()
      }
  }

  /// Schedules the exposure detection background task.
  /// To debug this, set a breakpoint right after `BGTaskScheduler.shared.submit()` and then execute the following line in the
  /// lldb console:
  /// ```
  ///   e -l objc -- (void)[[BGTaskScheduler sharedScheduler]
  ///   _simulateLaunchForTaskWithIdentifier:@"it.ministerodellasalute.immuni.exposure-notification"]
  /// ```
  func scheduleBackgroundTask() {
    guard #available(iOS 13.5, *) else {
      /// if iOS 13.5 is not available, it makes no sense to schedule the background task
      return
    }

    let taskRequest = BGProcessingTaskRequest(identifier: AppDelegate.exposureDetectionBackgroundTaskIdentifier)
    taskRequest.requiresNetworkConnectivity = true
    taskRequest.requiresExternalPower = false
    taskRequest.earliestBeginDate = nil

    do {
      try BGTaskScheduler.shared.submit(taskRequest)
      AppLogger.debug("Background task submitted")
    } catch {
      AppLogger.error("Unable to schedule background task: \(error)")
    }
  }
}

// MARK: Interceptors

extension AppDelegate {
  /// interceptors used by the store
  private var storeInterceptors: [StoreInterceptor] {
    return [
      self.persistStore.katanaInterceptor,
      ObserverInterceptor.observe(self.observers)
    ]
  }

  private var observers: [ObserverInterceptor.ObserverType] {
    return [
      .onStart([
        Logic.Lifecycle.OnStart.self
      ]),
      .onNotification(UIApplication.willEnterForegroundNotification, [
        Logic.Lifecycle.WillEnterForeground.self
      ]),
      .onNotification(UIApplication.didEnterBackgroundNotification, [
        Logic.Lifecycle.DidEnterBackground.self
      ]),
      .onNotification(UIApplication.didBecomeActiveNotification, [
        Logic.Lifecycle.DidBecomeActive.self
      ]),
      .onNotification(UIApplication.willResignActiveNotification, [
        Logic.Lifecycle.WillResignActive.self
      ]),
      .onNotification(UIResponder.keyboardWillShowNotification, [
        Logic.Keyboard.KeyboardWillShow.self
      ]),
      .onNotification(UIResponder.keyboardWillHideNotification, [
        Logic.Keyboard.KeyboardWillHide.self
      ]),
      .onStateChange(Logic.ForceUpdate.minimumAppVersionDidChange, [
        Logic.ForceUpdate.CheckAppVersion.self
      ])
    ]
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    self.store.dispatch(Logic.Shared.HandleNotificationResponse(requestNotificationID: response.notification.request.identifier))
    completionHandler()
  }
}

// MARK: - Global Helpers

/// Leverages `LoggerProvider` to log events for the application
enum AppLogger: LoggerProvider {
  static var logger: Logger { Log.logger(for: "immuni.main-application", logLevel: .debug) }
}

// MARK: Extensions

private extension SecretsStorageKeys {
  static let storagePasswordKey = SecretsStorageKey<Data>("StatePasswordKey")
}
