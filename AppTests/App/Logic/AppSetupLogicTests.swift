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
  func testAwaitsForFirstLaunchSetup() throws {
    var state = AppState()
    state.toggles.isFirstLaunchSetupPerformed = true

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.AppSetup.PerformSetup().sideEffect(context)
    self.expectToEventually(dispatchInterceptor.dispatchedItems.contains(where: { $0 is WaitForState }))
    self.expectToEventually(dispatchInterceptor.dispatchedItems.contains(where: { $0 is Logic.AppSetup.ChangeRoot }))
  }

  func testChangeRootWithForceUpdate() throws {
    var state = AppState()

    state.configuration = .init(minimumBuildVersion: 99999)

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
