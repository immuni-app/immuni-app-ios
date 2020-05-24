// AnalyticsLogicTests.swift
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
@testable import Immuni
import ImmuniExposureNotification
import Models
import Networking
import XCTest

// swiftlint:disable superfluous_disable_command force_try implicitly_unwrapped_optional force_unwrapping force_cast

class AnalyticsLogicTests: XCTestCase {
  override func tearDown() {
    super.tearDown()
    DeterministicGenerator.randomValue = 0.5
  }
}

// MARK: Operational Info With Exposure

extension AnalyticsLogicTests {
  func testTriggersAnalyticsWithExposure() throws {
    let state = AppState()
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    let outcome = ExposureDetectionOutcome.fullDetection(Date(), ExposureDetectionSummary.noMatch, [], 0, 0)

    try Logic.Analytics.SendOperationalInfoIfNeeded(outcome: outcome).sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Logic.Analytics.SendOperationalInfoWithExposureIfNeeded.self)
  }

  func testAnalyticsWithExposure() throws {
    let previousDate = Date(utcDay: 10, month: 9, year: 2020)
    let date = Date(utcDay: 10, month: 10, year: 2020)

    var state = AppState()
    state.configuration = Configuration(operationalInfoWithExposureSamplingRate: 0.7)
    state.analytics.eventWithExposureLastSent = previousDate.utcCalendarDay
    state.user.province = .alessandria

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let now = { date }
    let requestExecutor = MockRequestExecutor(mockedResult: .failure(NetworkManager.Error.badRequest))

    let token = "test_with_exposure"
    let tokenGenerator = MockDeviceTokenGenerator(result: .success(token))

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor,
      now: now,
      uniformDistributionGenerator: DeterministicGenerator.self,
      tokenGenerator: tokenGenerator
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Analytics.SendOperationalInfoWithExposureIfNeeded().sideEffect(context)

    let expectedRequest = AnalyticsRequest(body: .init(
      province: state.user.province!,
      exposureNotificationStatus: state.environment.exposureNotificationAuthorizationStatus,
      pushNotificationStatus: state.environment.pushNotificationAuthorizationStatus,
      riskyExposureDetected: true,
      deviceToken: token.data(using: .utf8)!.base64EncodedString()
    ))

    XCTAssertEqual(requestExecutor.executeMethodCalls.count, 1)

    try XCTAssertType(requestExecutor.executeMethodCalls.first, AnalyticsRequest.self) { value in

      XCTAssertEqual(value, expectedRequest)
    }

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(
      dispatchInterceptor.dispatchedItems.first,
      Logic.Analytics.UpdateEventWithExposureLastSent.self
    ) { value in

      XCTAssertEqual(value.day, date.utcCalendarDay)
    }
  }

  func testAnalyticsWithExposureNoMonth() throws {
    let previousDate = Date(utcDay: 10, month: 10, year: 2020)
    let date = Date(utcDay: 1, month: 10, year: 2020)

    var state = AppState()
    state.configuration = Configuration(operationalInfoWithExposureSamplingRate: 0.7)
    state.analytics.eventWithExposureLastSent = previousDate.utcCalendarDay
    state.user.province = .alessandria

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let now = { date }
    let requestExecutor = MockRequestExecutor(mockedResult: .failure(NetworkManager.Error.badRequest))

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor,
      now: now,
      uniformDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Analytics.SendOperationalInfoWithExposureIfNeeded().sideEffect(context)

    XCTAssertEqual(requestExecutor.executeMethodCalls.count, 0)
    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 0)
  }

  func testAnalyticsWithExposureNoRandom() throws {
    let previousDate = Date(utcDay: 10, month: 9, year: 2020)
    let date = Date(utcDay: 10, month: 10, year: 2020)

    var state = AppState()
    state.configuration = Configuration(operationalInfoWithExposureSamplingRate: 0.1)
    state.analytics.eventWithExposureLastSent = previousDate.utcCalendarDay
    state.user.province = .alessandria

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let now = { date }
    let requestExecutor = MockRequestExecutor(mockedResult: .failure(NetworkManager.Error.badRequest))

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor,
      now: now,
      uniformDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Analytics.SendOperationalInfoWithExposureIfNeeded().sideEffect(context)

    XCTAssertEqual(requestExecutor.executeMethodCalls.count, 0)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(
      dispatchInterceptor.dispatchedItems.first,
      Logic.Analytics.UpdateEventWithExposureLastSent.self
    ) { value in

      XCTAssertEqual(value.day, date.utcCalendarDay)
    }
  }

  func testUpdateAnalyticEventWithExposureLastSent() {
    var state = AppState()
    let calendarDay = Date(utcDay: 1, month: 10, year: 2020).utcCalendarDay

    Logic.Analytics.UpdateEventWithExposureLastSent(day: calendarDay).updateState(&state)
    XCTAssertEqual(state.analytics.eventWithExposureLastSent, calendarDay)
  }
}

// MARK: Operational Info Without Exposure

extension AnalyticsLogicTests {
  func testTriggersAnalyticsWithoutExposure() throws {
    let state = AppState()
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    let outcome = ExposureDetectionOutcome.partialDetection(Date(), .noMatch, 0, 0)

    try Logic.Analytics.SendOperationalInfoIfNeeded(outcome: outcome).sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Logic.Analytics.SendOperationalInfoWithoutExposureIfNeeded.self)
  }

  func testDoesntTriggerWithError() throws {
    let state = AppState()
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    let outcome = ExposureDetectionOutcome.error(.notAuthorized)

    try Logic.Analytics.SendOperationalInfoIfNeeded(outcome: outcome).sideEffect(context)
    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 0)
  }

  func testDoesntTriggerWithNotNecessary() throws {
    let state = AppState()
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    let outcome = ExposureDetectionOutcome.noDetectionNecessary

    try Logic.Analytics.SendOperationalInfoIfNeeded(outcome: outcome).sideEffect(context)
    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 0)
  }

  func testAnalyticsWithoutExposure() throws {
    let currentDayOfMonth = 10
    let previousDate = Date(utcDay: 10, month: 9, year: 2020)
    let date = Date(utcDay: currentDayOfMonth, month: 10, year: 2020)

    var state = AppState()
    state.configuration = Configuration(operationalInfoWithoutExposureSamplingRate: 0.7)
    state.analytics.eventWithExposureLastSent = previousDate.utcCalendarDay

    state.analytics.eventWithoutExposureWindow = .init(
      month: CalendarMonth(year: 2020, month: 10),
      shift: Double(currentDayOfMonth - 1) * AnalyticsState.OpportunityWindow.secondsInDay
    )

    state.user.province = .alessandria

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let now = { date }
    let requestExecutor = MockRequestExecutor(mockedResult: .failure(NetworkManager.Error.badRequest))

    let token = "test_with_exposure"
    let tokenGenerator = MockDeviceTokenGenerator(result: .success(token))

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor,
      now: now,
      uniformDistributionGenerator: DeterministicGenerator.self,
      tokenGenerator: tokenGenerator
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Analytics.SendOperationalInfoWithoutExposureIfNeeded().sideEffect(context)

    let expectedRequest = AnalyticsRequest(body: .init(
      province: state.user.province!,
      exposureNotificationStatus: state.environment.exposureNotificationAuthorizationStatus,
      pushNotificationStatus: state.environment.pushNotificationAuthorizationStatus,
      riskyExposureDetected: false,
      deviceToken: token.data(using: .utf8)!.base64EncodedString()
    ))

    XCTAssertEqual(requestExecutor.executeMethodCalls.count, 1)

    try XCTAssertType(requestExecutor.executeMethodCalls.first, AnalyticsRequest.self) { value in
      XCTAssertEqual(value, expectedRequest)
    }

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(
      dispatchInterceptor.dispatchedItems.first,
      Logic.Analytics.UpdateEventWithoutExposureLastSent.self
    ) { value in

      XCTAssertEqual(value.day, date.utcCalendarDay)
    }
  }

  func testAnalyticsWithoutExposureNoProvince() throws {
    let currentDayOfMonth = 10
    let previousDate = Date(utcDay: 10, month: 9, year: 2020)
    let date = Date(utcDay: currentDayOfMonth, month: 10, year: 2020)

    var state = AppState()
    state.configuration = Configuration(operationalInfoWithoutExposureSamplingRate: 0.7)
    state.analytics.eventWithExposureLastSent = previousDate.utcCalendarDay

    state.analytics.eventWithoutExposureWindow = .init(
      month: CalendarMonth(year: 2020, month: 10),
      shift: Double(currentDayOfMonth) * AnalyticsState.OpportunityWindow.secondsInDay
    )

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let now = { date }
    let requestExecutor = MockRequestExecutor(mockedResult: .failure(NetworkManager.Error.badRequest))

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor,
      now: now,
      uniformDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Analytics.SendOperationalInfoWithoutExposureIfNeeded().sideEffect(context)

    XCTAssertEqual(requestExecutor.executeMethodCalls.count, 0)
    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 0)
  }

  func testAnalyticsWithoutExposureNoMonthPassed() throws {
    let currentDayOfMonth = 10
    let previousDate = Date(utcDay: 10, month: 10, year: 2020)
    let date = Date(utcDay: currentDayOfMonth, month: 10, year: 2020)

    var state = AppState()
    state.configuration = Configuration(operationalInfoWithoutExposureSamplingRate: 0.7)
    state.analytics.eventWithExposureLastSent = previousDate.utcCalendarDay

    state.analytics.eventWithoutExposureWindow = .init(
      month: CalendarMonth(year: 2020, month: 10),
      shift: Double(currentDayOfMonth) * AnalyticsState.OpportunityWindow.secondsInDay
    )

    state.user.province = .alessandria

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let now = { date }
    let requestExecutor = MockRequestExecutor(mockedResult: .failure(NetworkManager.Error.badRequest))

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor,
      now: now,
      uniformDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Analytics.SendOperationalInfoWithoutExposureIfNeeded().sideEffect(context)

    XCTAssertEqual(requestExecutor.executeMethodCalls.count, 0)
    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 0)
  }

  func testAnalyticsWithoutExposureBeforeWindow() throws {
    let currentDayOfMonth = 10
    let previousDate = Date(utcDay: 10, month: 9, year: 2020)

    // "today" is the 10th of the month minus a second (that is, 23.59.59PM of 9th of the month)
    let date = Date(utcDay: currentDayOfMonth, month: 10, year: 2020).advanced(by: -1)

    var state = AppState()
    state.configuration = Configuration(operationalInfoWithoutExposureSamplingRate: 0.7)
    state.analytics.eventWithExposureLastSent = previousDate.utcCalendarDay

    state.analytics.eventWithoutExposureWindow = .init(
      month: CalendarMonth(year: 2020, month: 10),
      // just a second before the beginning of the time window
      shift: Double(currentDayOfMonth - 1) * AnalyticsState.OpportunityWindow.secondsInDay
    )

    state.user.province = .alessandria

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let now = { date }
    let requestExecutor = MockRequestExecutor(mockedResult: .failure(NetworkManager.Error.badRequest))

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor,
      now: now,
      uniformDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Analytics.SendOperationalInfoWithoutExposureIfNeeded().sideEffect(context)

    XCTAssertEqual(requestExecutor.executeMethodCalls.count, 0)
    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 0)
  }

  func testAnalyticsWithoutExposureAfterWindow() throws {
    let currentDayOfMonth = 10
    let previousDate = Date(utcDay: 10, month: 9, year: 2020)

    // "today" is the 11th of the month (that is, 00.00AM of 10th of the month)
    // exactly when the window closes
    let date = Date(utcDay: currentDayOfMonth + 1, month: 10, year: 2020)

    var state = AppState()
    state.configuration = Configuration(operationalInfoWithoutExposureSamplingRate: 0.7)
    state.analytics.eventWithExposureLastSent = previousDate.utcCalendarDay

    state.analytics.eventWithoutExposureWindow = .init(
      month: CalendarMonth(year: 2020, month: 10),
      // just a second before the beginning of the time window
      shift: Double(currentDayOfMonth - 1) * AnalyticsState.OpportunityWindow.secondsInDay
    )

    state.user.province = .alessandria

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let now = { date }
    let requestExecutor = MockRequestExecutor(mockedResult: .failure(NetworkManager.Error.badRequest))

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor,
      now: now,
      uniformDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Analytics.SendOperationalInfoWithoutExposureIfNeeded().sideEffect(context)

    XCTAssertEqual(requestExecutor.executeMethodCalls.count, 0)
    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 0)
  }

  func testAnalyticsWithoutExposureFailSampling() throws {
    let currentDayOfMonth = 10
    let previousDate = Date(utcDay: 10, month: 9, year: 2020)
    let date = Date(utcDay: currentDayOfMonth, month: 10, year: 2020)

    var state = AppState()
    state.configuration = Configuration(operationalInfoWithoutExposureSamplingRate: 0.1)
    state.analytics.eventWithExposureLastSent = previousDate.utcCalendarDay

    state.analytics.eventWithoutExposureWindow = .init(
      month: CalendarMonth(year: 2020, month: 10),
      shift: Double(currentDayOfMonth - 1) * AnalyticsState.OpportunityWindow.secondsInDay
    )

    state.user.province = .alessandria

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let now = { date }
    let requestExecutor = MockRequestExecutor(mockedResult: .failure(NetworkManager.Error.badRequest))

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor,
      now: now,
      uniformDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Analytics.SendOperationalInfoWithoutExposureIfNeeded().sideEffect(context)

    XCTAssertEqual(requestExecutor.executeMethodCalls.count, 0)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(
      dispatchInterceptor.dispatchedItems.first,
      Logic.Analytics.UpdateEventWithoutExposureLastSent.self
    ) { value in

      XCTAssertEqual(value.day, date.utcCalendarDay)
    }
  }

  func testUpdateOpportunityWindow() throws {
    let currentDayOfMonth = 10
    let previousDate = Date(utcDay: 10, month: 9, year: 2020)

    let date = Date(utcDay: currentDayOfMonth, month: 10, year: 2020)

    var state = AppState()
    state.configuration = Configuration(operationalInfoWithoutExposureSamplingRate: 0.7)
    state.analytics.eventWithExposureLastSent = previousDate.utcCalendarDay
    state.analytics.eventWithoutExposureWindow = .init(month: previousDate.utcCalendarMonth, shift: 100)
    state.user.province = .alessandria

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let now = { date }
    DeterministicGenerator.randomValue = 500

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      now: now,
      uniformDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Analytics.UpdateOpportunityWindowIfNeeded().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(
      dispatchInterceptor.dispatchedItems.first,
      Logic.Analytics.UpdateEventWithoutExposureOppurtunityWindow.self
    ) { value in

      XCTAssertEqual(
        value.window,
        AnalyticsState
          .OpportunityWindow(
            month: date.utcCalendarMonth,
            shift: 500,
            windowDuration: AnalyticsState.OpportunityWindow.secondsInDay
          )
      )
    }
  }

  func testUpdateOpportunityWindowAlreadyUpdated() throws {
    let currentDayOfMonth = 10
    let previousDate = Date(utcDay: 10, month: 10, year: 2020)

    let date = Date(utcDay: currentDayOfMonth, month: 10, year: 2020)

    var state = AppState()
    state.configuration = Configuration(operationalInfoWithoutExposureSamplingRate: 0.7)
    state.analytics.eventWithExposureLastSent = previousDate.utcCalendarDay
    state.analytics.eventWithoutExposureWindow = .init(month: previousDate.utcCalendarMonth, shift: 100)
    state.user.province = .alessandria

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()
    let now = { date }

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      now: now,
      uniformDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Analytics.UpdateOpportunityWindowIfNeeded().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 0)
  }

  func testUpdateEventWithoutExposureLastSent() {
    var state = AppState()
    let calendarDay = Date(utcDay: 1, month: 10, year: 2020).utcCalendarDay

    Logic.Analytics.UpdateEventWithoutExposureLastSent(day: calendarDay).updateState(&state)
    XCTAssertEqual(state.analytics.eventWithoutExposureLastSent, calendarDay)
  }

  func testUpdateEventWithoutExposureOppurtunityWindow() {
    var state = AppState()
    let window = AnalyticsState.OpportunityWindow(month: CalendarMonth(year: 2020, month: 10), shift: 10)

    Logic.Analytics.UpdateEventWithoutExposureOppurtunityWindow(window: window).updateState(&state)
    XCTAssertEqual(state.analytics.eventWithoutExposureWindow, window)
  }
}

// MARK: Helpers

private enum DeterministicGenerator: UniformDistributionGenerator {
  static var randomValue = 0.5

  static func random(in range: Range<Double>) -> Double {
    return self.randomValue
  }
}

private extension Date {
  init(utcDay: Int, month: Int, year: Int) {
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = utcDay

    var calendar = Calendar.current
    calendar.timeZone = TimeZone(abbreviation: "UTC")!
    self = calendar.date(from: dateComponents)!
  }
}
