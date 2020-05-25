// AppSetupLogicTests.swift
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

import Foundation
@testable import Immuni
import ImmuniExposureNotification
import Katana
import Models
import Tempura
import XCTest

final class AppSetupLogicTests: XCTestCase {
  func testPerformsSetupFirstLaunch() throws {
    let getState = { AppState() }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.AppSetup.PerformSetup().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 3)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Logic.Configuration.DownloadAndUpdateConfiguration.self)
    try XCTAssertType(dispatchInterceptor.dispatchedItems[1], Logic.AppSetup.PassFirstLaunchExecuted.self)
    try XCTAssertType(dispatchInterceptor.dispatchedItems[2], Logic.AppSetup.ChangeRoot.self)
  }

  func testPerformsSetup() throws {
    var state = AppState()
    state.toggles.isFirstLaunchPerformed = true

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.AppSetup.PerformSetup().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Logic.AppSetup.ChangeRoot.self)
  }

  func testChangeRootWithForceUpdate() throws {
    var state = AppState()

    // swiftlint:disable force_unwrapping
    state.configuration = .init(
      minimumBuildVersion: 99999,
      serviceNotActiveNotificationPeriod: 0,
      osForceUpdateNotificationPeriod: 0,
      requiredUpdateNotificationPeriod: 0,
      riskReminderNotificationPeriod: 0,
      exposureDetectionPeriod: 0,
      exposureConfiguration: .init(),
      exposureInfoMinimumRiskScore: 1,
      maximumExposureDetectionWaitingTime: 0,
      privacyPolicyURL: URL(string: "https://unit-test")!,
      tosURL: URL(string: "https://unit-test")!,
      faqURL: [:]
    )
    // swiftlint:enable force_unwrapping

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.AppSetup.ChangeRoot().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Logic.ForceUpdate.ShowAppForceUpdate.self)
  }

  func testChangeRootWithPrivacyNotAccepted() throws {
    let state = AppState()
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.AppSetup.ChangeRoot().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Logic.AppSetup.ShowWelcome.self)
  }

  func testChangeRootWithOnboardingNotCompleted() throws {
    var state = AppState()
    state.toggles.isOnboardingPrivacyAccepted = true
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.AppSetup.ChangeRoot().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Logic.Onboarding.ShowNecessarySteps.self)
  }

  func testChangeRootWithOnboardingCompleted() throws {
    var state = AppState()
    state.toggles.isOnboardingPrivacyAccepted = true
    state.toggles.isOnboardingCompleted = true
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.AppSetup.ChangeRoot().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Logic.AppSetup.ShowTabBar.self)
  }
}
