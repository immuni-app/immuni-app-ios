// OnboardingLogicTests.swift
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

final class OnboardingLogicTests: XCTestCase {
  func testShowRegion() throws {
    let state = AppState()
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Onboarding.ShowNecessarySteps().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Tempura.Show.self) { value in
      XCTAssertEqual(value.identifiersToShow, [Screen.onboardingStep.rawValue])

      let context = value.context as? OnboardingContainerNC.NavigationContext
      XCTAssertEqual(context?.child, .region)
    }
  }

  func testHandleRegionSelelectedWithManyProvinces() throws {
    let state = AppState()
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Onboarding.HandleRegionStepCompleted(region: .lombardia).sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Tempura.Show.self) { value in
      XCTAssertEqual(value.identifiersToShow, [Screen.onboardingStep.rawValue])

      let context = value.context as? OnboardingContainerNC.NavigationContext
      XCTAssertEqual(context?.child, .province(region: .lombardia))
    }
  }

  func testHandleRegionSelelectedWithSingleProvince() throws {
    var state = AppState()
    // prepare the state as the dispatchable works
    state.user.province = .aosta

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Onboarding.HandleRegionStepCompleted(region: .valleAosta).sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 2)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Logic.Onboarding.SetUserProvince.self) { value in
      XCTAssertEqual(value.province, .aosta)
    }

    try XCTAssertType(dispatchInterceptor.dispatchedItems[1], Logic.Onboarding.ShowExposureNotification.self)
  }

  func testShowExposureNotification() throws {
    var state = AppState()
    state.user.province = .aosta

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Onboarding.ShowNecessarySteps().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Logic.Onboarding.ShowExposureNotification.self)
  }

  func testShowBluetoothOffIfNecessary() throws {
    var state = AppState()
    state.user.province = .aosta
    state.environment.exposureNotificationAuthorizationStatus = .authorizedAndBluetoothOff

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Onboarding.ShowNecessarySteps().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Logic.Onboarding.ShowBluetoothOff.self)
  }

  func testShowPushPermissions() throws {
    var state = AppState()
    state.user.province = .aosta
    state.environment.exposureNotificationAuthorizationStatus = .authorized

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Onboarding.ShowNecessarySteps().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Tempura.Show.self) { value in
      XCTAssertEqual(value.identifiersToShow, [Screen.onboardingStep.rawValue])

      let context = value.context as? OnboardingContainerNC.NavigationContext
      XCTAssertEqual(context?.child, .pushNotificationPermissions)
    }
  }

  func testShowPinAdvice() throws {
    var state = AppState()
    state.user.province = .aosta
    state.environment.exposureNotificationAuthorizationStatus = .authorized
    state.environment.pushNotificationAuthorizationStatus = .authorized

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Onboarding.ShowNecessarySteps().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Tempura.Show.self) { value in
      XCTAssertEqual(value.identifiersToShow, [Screen.onboardingStep.rawValue])

      let context = value.context as? OnboardingContainerNC.NavigationContext
      XCTAssertEqual(context?.child, .pinAdvice)
    }
  }

  func testShowCommunicationAdvice() throws {
    var state = AppState()
    state.user.province = .aosta
    state.environment.exposureNotificationAuthorizationStatus = .authorized
    state.environment.pushNotificationAuthorizationStatus = .authorized
    state.toggles.didShowPinAdvice = true

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Onboarding.ShowNecessarySteps().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Tempura.Show.self) { value in
      XCTAssertEqual(value.identifiersToShow, [Screen.onboardingStep.rawValue])

      let context = value.context as? OnboardingContainerNC.NavigationContext
      XCTAssertEqual(context?.child, .communicationAdvice)
    }
  }

  func testShowTabbarWhenOnboardingIsCompleted() throws {
    var state = AppState()
    state.toggles.isOnboardingCompleted = true

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Onboarding.ShowNecessarySteps().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Tempura.Show.self) { value in
      XCTAssertEqual(value.identifiersToShow, [Screen.tabBar.rawValue])
    }
  }

  func testOnboardingCompletedOnLaunch() throws {
    var state = AppState()
    state.user.province = .arezzo
    state.environment.pushNotificationAuthorizationStatus = .authorized
    state.environment.exposureNotificationAuthorizationStatus = .authorized
    state.toggles.didShowPinAdvice = true
    state.toggles.didShowCommunicationAdvice = true

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Onboarding.ShowNecessarySteps().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 3)

    try XCTAssertType(dispatchInterceptor.dispatchedItems[0], Logic.ForceUpdate.RemoveScheduledOSReminderIfNeeded.self)
    try XCTAssertType(dispatchInterceptor.dispatchedItems[1], Logic.Onboarding.MarkOnboardingAsCompleted.self)

    try XCTAssertType(dispatchInterceptor.dispatchedItems[2], Tempura.Show.self) { value in
      XCTAssertEqual(value.identifiersToShow, [Screen.tabBar.rawValue])
    }
  }

  func testCompleteOnboarding() throws {
    var state = AppState()
    state.user.province = .arezzo
    state.environment.pushNotificationAuthorizationStatus = .authorized
    state.environment.exposureNotificationAuthorizationStatus = .authorized
    state.toggles.didShowPinAdvice = true
    state.toggles.didShowCommunicationAdvice = true

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Onboarding.CompleteOnboarding().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 4)

    try XCTAssertType(dispatchInterceptor.dispatchedItems[0], Logic.ForceUpdate.RemoveScheduledOSReminderIfNeeded.self)
    try XCTAssertType(dispatchInterceptor.dispatchedItems[1], Logic.Onboarding.MarkOnboardingAsCompleted.self)

    try XCTAssertType(dispatchInterceptor.dispatchedItems[2], Tempura.Show.self) { value in
      XCTAssertEqual(value.identifiersToShow, [Screen.onboardingStep.rawValue])

      let context = value.context as? OnboardingContainerNC.NavigationContext
      XCTAssertEqual(context?.child, .onboardingCompleted)
    }

    try XCTAssertType(dispatchInterceptor.dispatchedItems[3], Tempura.Show.self) { value in
      XCTAssertEqual(value.identifiersToShow, [Screen.tabBar.rawValue])
    }
  }

  func testHandleProvinceStepCompleted() throws {
    var state = AppState()
    state.user.province = .roma // simulate the update that will happen
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Onboarding.HandleProvinceStepCompleted(selectedProvince: .roma).sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 2)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Logic.Onboarding.SetUserProvince.self) { value in
      XCTAssertEqual(value.province, .roma)
    }

    try XCTAssertType(dispatchInterceptor.dispatchedItems[1], Logic.Onboarding.ShowExposureNotification.self)
  }

  func testUserDidTapExposureActionButton() throws {
    var state = AppState()
    state.user.province = .roma

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let provider = MockExposureNotificationProvider(overriddenStatus: .authorized)

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      exposureNotificationProvider: provider
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Onboarding.UserDidTapExposureActionButton().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 4)

    try XCTAssertType(dispatchInterceptor.dispatchedItems[0], Tempura.Show.self) { value in
      XCTAssertEqual(value.identifiersToShow, [Screen.permissionOverlay.rawValue])
    }

    try XCTAssertType(dispatchInterceptor.dispatchedItems[1], Logic.Lifecycle.ScheduleBackgroundTask.self)

    try XCTAssertType(dispatchInterceptor.dispatchedItems[2], Tempura.Hide.self) { value in
      XCTAssertEqual(value.identifierToHide, Screen.permissionOverlay.rawValue)
    }

    try XCTAssertType(dispatchInterceptor.dispatchedItems[3], Logic.Lifecycle.RefreshAuthorizationStatuses.self)
  }

  func testUserDidTapExposureActionButtonWithNotAuthorized() throws {
    var state = AppState()
    state.user.province = .roma
    state.environment.exposureNotificationAuthorizationStatus = .notAuthorized

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let provider = MockExposureNotificationProvider(overriddenStatus: .notAuthorized)

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      exposureNotificationProvider: provider
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Onboarding.UserDidTapExposureActionButton().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(
      dispatchInterceptor.dispatchedItems[0],
      Logic.PermissionTutorial.ShowActivateExposureNotificationTutorial.self
    )
  }

  func testSetUserProvince() throws {
    var state = AppState()
    Logic.Onboarding.SetUserProvince(province: .agrigento).updateState(&state)
    XCTAssertEqual(state.user.province, .agrigento)
  }

  func testSetUserProvinceStateUpdater() throws {
    var state = AppState()
    Logic.Onboarding.MarkOnboardingAsCompleted().updateState(&state)
    XCTAssertEqual(state.toggles.isOnboardingCompleted, true)
  }
}
