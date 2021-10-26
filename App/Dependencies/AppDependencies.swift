// AppDependencies.swift
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

import Alamofire
import DeviceCheck
import Extensions
import Hydra
import ImmuniExposureNotification
import Katana
import Networking
import Persistence
import PushNotification
import Tempura

#if canImport(DebugMenu)
  import DebugMenu
#endif

final class AppDependencies: NSObject, SideEffectDependencyContainer, NavigationProvider {
  let getAppState: () -> AppState
  let dispatch: AnyDispatch

  // MARK: App Managers and utilities

  let uniformDistributionGenerator: UniformDistributionGenerator.Type
  let exponentialDistributionGenerator: ExponentialDistributionGenerator.Type
  let deviceTokenGenerator: DeviceTokenGenerator
  let analyticsTokenGenerator: AnalyticsTokenGenerator
  let now: () -> Date

  // MARK: Module Managers

  let navigator: Navigator
  let kvStorage: KVStorage
  let secretsStorage: SecretsStorage
  var exposureNotificationManager: ExposureNotificationManager
  let networkManager: NetworkManager
  let reachabilityManager: NetworkReachabilityManager?
  let temporaryExposureKeyProvider: TemporaryExposureKeyProvider
  let pushNotification: PushNotificationManager
  let exposureDetectionExecutor: ExposureDetectionExecutor

  // MARK: Dev Tooling

  #if canImport(DebugMenu)
    let debugMenu: DebugMenu
  #endif

  required init(dispatch: @escaping AnyDispatch, getState: @escaping GetState) {
    let getAppState: () -> AppState = {
      guard let state = getState() as? AppState else {
        AppLogger.fatalError("Wrong State Type")
      }

      return state
    }

    self.navigator = Navigator()
    self.getAppState = getAppState
    self.dispatch = dispatch

    self.secretsStorage = SecretsStorage(bundle: .main)

    let kvStorageEncryptionKey = self.secretsStorage.getOrCreateSymmetricKey(for: SecretsStorage.storagePasswordKey)
    self.kvStorage = KVStorage(userDefaults: .standard, encryptionKey: kvStorageEncryptionKey)

    let networkManager = NetworkManager()
    self.networkManager = networkManager
    self.reachabilityManager = NetworkReachabilityManager.default

    self.temporaryExposureKeyProvider = ImmuniTemporaryExposureKeyProvider(
      networkManager: networkManager,
      fileStorage: ImmuniFileStorage(fileManager: .default)
    )

    self.exposureNotificationManager = ExposureNotificationManager()
    self.pushNotification = PushNotificationManager()

    self.exposureDetectionExecutor = ImmuniExposureDetectionExecutor()

    self.uniformDistributionGenerator = Double.self
    self.exponentialDistributionGenerator = Double.self
    self.now = Date.init

    #if targetEnvironment(simulator)
      self.deviceTokenGenerator = MockDeviceTokenGenerator(result: .success("this_is_a_simulator"))
    #else
      self.deviceTokenGenerator = DCDevice.current
    #endif

    self.analyticsTokenGenerator = ImmuniAnalyticsTokenGenerator(
      now: self.now,
      uniformDistributionGenerator: self.uniformDistributionGenerator
    )

    #if canImport(DebugMenu)
      self.debugMenu = DebugMenu()
    #endif

    super.init()
    self.startDependencies()
  }

  /// Init used for testing. This init expects fully initialized managers that are ready to use
  init(
    navigator: Navigator,
    getAppState: @escaping () -> AppState,
    dispatch: @escaping AnyDispatch,
    kvStorage: KVStorage,
    secretsStorage: SecretsStorage,
    networkManager: NetworkManager,
    reachabilityManager: NetworkReachabilityManager?,
    temporaryExposureKeyProvider: TemporaryExposureKeyProvider,
    exposureNotificationManager: ExposureNotificationManager,
    pushNotification: PushNotificationManager,
    exposureDetectionExecutor: ExposureDetectionExecutor,
    uniformDistributionGenerator: UniformDistributionGenerator.Type,
    exponentialDistributionGenerator: ExponentialDistributionGenerator.Type,
    deviceTokenGenerator: DeviceTokenGenerator,
    analyticsTokenGenerator: AnalyticsTokenGenerator,
    now: @escaping () -> Date
  ) {
    self.navigator = navigator
    self.getAppState = getAppState
    self.dispatch = dispatch
    self.kvStorage = kvStorage
    self.secretsStorage = secretsStorage
    self.networkManager = networkManager
    self.reachabilityManager = reachabilityManager
    self.temporaryExposureKeyProvider = temporaryExposureKeyProvider
    self.exposureNotificationManager = exposureNotificationManager
    self.pushNotification = pushNotification
    self.exposureDetectionExecutor = exposureDetectionExecutor
    self.uniformDistributionGenerator = uniformDistributionGenerator
    self.exponentialDistributionGenerator = exponentialDistributionGenerator
    self.now = now
    self.deviceTokenGenerator = deviceTokenGenerator
    self.analyticsTokenGenerator = analyticsTokenGenerator

    #if canImport(DebugMenu)
      self.debugMenu = DebugMenu()
    #endif
  }
}

// MARK: Managers Start

private extension AppDependencies {
  func startDependencies() {
    self.pushNotification.start(with: .init())

    self.networkManager.start(
      with: .init(
        requestExecutor: AlamofireRequestExecutor(
          sessionProvider: ImmuniSessionProvider(bundle: .main)
        ),
        now: self.now
      )
    )

    #if canImport(DebugMenu)
      self.debugMenu.start(with: self)
    #endif
  }
}

// MARK: Common

extension AppDependencies {
  var application: UIApplication { UIApplication.shared }
  var pasteboard: UIPasteboard { UIPasteboard.general }
  var bundle: Bundle { .main }
  var locale: Locale { .current }
}

// MARK: App Helpers

extension AppDependencies {
  /// Allows retrieving the AppState safely, since `getState()` has an assertion on `state.isReady`.
  var safeGetAppState: () -> AppState? {
    guard
      let appDelegate = mainThread({ self.application.delegate as? AppDelegate }),
      appDelegate.store.isReady
    else {
      return { return nil }
    }

    return self.getAppState
  }
}

private extension SecretsStorage {
  static let storagePasswordKey = SecretsStorageKey<Data>("DependenciesPasswordKey")
}
