// MockAppDependencies.swift
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

// swiftlint:disable superfluous_disable_command force_try implicitly_unwrapped_optional force_unwrapping force_cast

import Alamofire
import Foundation
import Hydra
@testable import Immuni
import ImmuniExposureNotification
import Katana
import Networking
import Persistence
import PushNotification
import Tempura
import XCTest

extension AppDependencies {
  static func mocked(
    navigator: Navigator = Navigator(),
    getAppState: @escaping () -> AppState = { AppState() },
    dispatch: @escaping AnyDispatch = { _ in Promise(resolved: ()) },
    kvStorage: KVStorage = KVStorage(userDefaults: .standard, encryptionKey: nil),
    secretsStorage: SecretsStorage = SecretsStorage(bundle: .main),
    requestExecutor: RequestExecutor = MockRequestExecutor(mockedResult: .success(Data())),
    now: @escaping () -> Date = { Date() },
    temporaryExposureKeyProvider: TemporaryExposureKeyProvider = MockTemporaryExposureKeyProvider(urlsToReturn: 0),
    exposureNotificationProvider: ExposureNotificationProvider = ExposureNotificationProviderStub(status: .restricted),
    pushNotificationManager: PushNotificationManager = PushNotificationManager(),
    exposureDetectionExecutor: ExposureDetectionExecutor = MockExposureDetectionExecutor(),
    uniformDistributionGenerator: UniformDistributionGenerator.Type = Double.self,
    exponentialDistributionGenerator: ExponentialDistributionGenerator.Type = Double.self,
    deviceTokenGenerator: DeviceTokenGenerator = MockDeviceTokenGenerator(result: .success("testing")),
    analyticsTokenGenerator: AnalyticsTokenGenerator = MockAnalyticsTokenGenerator(token: "test", expirationDate: .distantFuture)
  ) -> AppDependencies {
    let networkManager = NetworkManager()
    networkManager.start(with: .init(requestExecutor: requestExecutor, now: now))
    return AppDependencies(
      navigator: navigator,
      getAppState: getAppState,
      dispatch: dispatch,
      kvStorage: kvStorage,
      secretsStorage: secretsStorage,
      networkManager: networkManager,
      reachabilityManager: NetworkReachabilityManager(),
      temporaryExposureKeyProvider: temporaryExposureKeyProvider,
      exposureNotificationManager: ExposureNotificationManager(
        provider: exposureNotificationProvider
      ),
      pushNotification: pushNotificationManager,
      exposureDetectionExecutor: exposureDetectionExecutor,
      uniformDistributionGenerator: uniformDistributionGenerator,
      exponentialDistributionGenerator: exponentialDistributionGenerator,
      deviceTokenGenerator: deviceTokenGenerator,
      analyticsTokenGenerator: analyticsTokenGenerator,
      now: now
    )
  }
}
