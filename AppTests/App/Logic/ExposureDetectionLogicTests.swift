// ExposureDetectionLogicTests.swift
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
import Hydra
@testable import Immuni
import ImmuniExposureNotification
import Models
import XCTest

final class ExposureDetectionLogicTests: XCTestCase {
  func testPerformsExposureDetection() throws {
    let state = AppState()
    let getState = { state }
    let exposureDetectionExecutor = MockExposureDetectionExecutor(outcome: .noDetectionNecessary)
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      exposureDetectionExecutor: exposureDetectionExecutor
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .foreground).sideEffect(context)

    XCTAssertEqual(exposureDetectionExecutor.executeMethodCalls, 1)
  }

  func testPerformsExposureDetectionInvokedWithProperPeriodInForeground() throws {
    var state = AppState()

    let detectionPeriod: TimeInterval = 9999
    let wrongDetectionPeriod: TimeInterval = 10

    state.configuration = Configuration(
      exposureDetectionPeriod: wrongDetectionPeriod,
      maximumExposureDetectionWaitingTime: detectionPeriod
    )

    let getState = { state }
    let exposureDetectionExecutor = MockExposureDetectionExecutor(outcome: .noDetectionNecessary)
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      exposureDetectionExecutor: exposureDetectionExecutor
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .foreground).sideEffect(context)

    XCTAssertEqual(exposureDetectionExecutor.executeMethodCalls, 1)
    XCTAssertEqual(exposureDetectionExecutor.detectionPeriods, [detectionPeriod])
  }

  func testPerformsExposureDetectionInvokedWithProperPeriodInBackground() throws {
    var state = AppState()

    let detectionPeriod: TimeInterval = 9999
    let wrongDetectionPeriod: TimeInterval = 10

    state.configuration = Configuration(
      exposureDetectionPeriod: detectionPeriod,
      maximumExposureDetectionWaitingTime: wrongDetectionPeriod
    )

    let getState = { state }
    let exposureDetectionExecutor = MockExposureDetectionExecutor(outcome: .noDetectionNecessary)
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      exposureDetectionExecutor: exposureDetectionExecutor
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .background(MockBackgroundTask())).sideEffect(context)

    XCTAssertEqual(exposureDetectionExecutor.executeMethodCalls, 1)
    XCTAssertEqual(exposureDetectionExecutor.detectionPeriods, [detectionPeriod])
  }

  func testSchedulesNotificationIfUnauthorized() throws {
    let state = AppState()
    let getState = { state }
    let exposureDetectionExecutor = MockExposureDetectionExecutor(outcome: .error(.notAuthorized))
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      exposureDetectionExecutor: exposureDetectionExecutor
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .foreground).sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.ExposureDetection.ScheduleLocalNotificationIfPossible.self
    )
  }

  func testUpdatesTheLatestProcessedChunkIfPartialDetection() throws {
    let lastIndex = 5
    let lastCountryIndex = ["IT": lastIndex]
    let state = AppState()
    let getState = { state }
    let exposureDetectionExecutor =
      MockExposureDetectionExecutor(outcome: .partialDetection(Date(), .noMatch, ["IT": 0], lastCountryIndex))
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      exposureDetectionExecutor: exposureDetectionExecutor
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .foreground).sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.ExposureDetection.UpdateLatestProcessedKeyChunkIndex.self
    ) { dispatchable in
      XCTAssertEqual(dispatchable.countryIndexCouple, lastCountryIndex)
    }
  }

  func testUpdatesTheLatestProcessedChunkIfFullDetection() throws {
    let lastIndex = 5
    let lastCountryIndex = ["IT": lastIndex]
    let state = AppState()
    let getState = { state }
    let exposureDetectionExecutor =
      MockExposureDetectionExecutor(outcome: .fullDetection(Date(), .noMatch, [], ["IT": 0], lastCountryIndex))
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      exposureDetectionExecutor: exposureDetectionExecutor
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .foreground).sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.ExposureDetection.UpdateLatestProcessedKeyChunkIndex.self
    ) { dispatchable in
      XCTAssertEqual(dispatchable.countryIndexCouple, lastCountryIndex)
    }
  }

  func testTrackExposureDetectionPerformedIsBeingCalled() throws {
    let outcome: ExposureDetectionOutcome = .fullDetection(Date(), .noMatch, [], ["IT": 0], ["IT": 5])
    let state = AppState()
    let getState = { state }
    let exposureDetectionExecutor = MockExposureDetectionExecutor(outcome: outcome)
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      exposureDetectionExecutor: exposureDetectionExecutor
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .foreground).sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.ExposureDetection.TrackExposureDetectionPerformed.self
    ) { dispatchable in
      XCTAssertEqual(dispatchable.outcome.rawCase, outcome.rawCase)
    }
  }

  func testSendToAnalyticsServerIfNecessaryIsBeingCalled() throws {
    let outcome: ExposureDetectionOutcome = .fullDetection(Date(), .noMatch, [], ["IT": 0], ["IT": 5])
    let state = AppState()
    let getState = { state }
    let exposureDetectionExecutor = MockExposureDetectionExecutor(outcome: outcome)
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      exposureDetectionExecutor: exposureDetectionExecutor
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .foreground).sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.Analytics.SendOperationalInfoIfNeeded.self
    ) { dispatchable in
      XCTAssertEqual(dispatchable.outcome.rawCase, outcome.rawCase)
    }
  }

  func testUpdateUserStatusIfNecessaryIsBeingCalled() throws {
    let outcome: ExposureDetectionOutcome = .fullDetection(Date(), .noMatch, [], ["IT": 0], ["IT": 5])
    let state = AppState()
    let getState = { state }
    let exposureDetectionExecutor = MockExposureDetectionExecutor(outcome: outcome)
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      exposureDetectionExecutor: exposureDetectionExecutor
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .foreground).sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.ExposureDetection.UpdateUserStatusIfNecessary.self
    ) { dispatchable in
      XCTAssertEqual(dispatchable.outcome.rawCase, outcome.rawCase)
    }
  }

  func testSetsAnExpirationHandlerOnTheBackgroundTask() throws {
    let state = AppState()
    let getState = { state }

    let backgroundTask = MockBackgroundTask()

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      exposureDetectionExecutor: MockExposureDetectionExecutor(outcome: .noDetectionNecessary)
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .background(backgroundTask)).sideEffect(context)

    XCTAssertNotNil(backgroundTask.expirationHandler)
  }

  func testBackgroundTaskCompletionCalledWithAppropriateValues() throws {
    let state = AppState()
    let getState = { state }

    let testCases: [(outcome: ExposureDetectionOutcome, expected: Bool)] = [
      (.error(.notAuthorized), false),
      (.noDetectionNecessary, true),
      (.partialDetection(Date(), .noMatch, ["IT": 1], ["IT": 5]), true),
      (.fullDetection(Date(), .noMatch, [], ["IT": 1], ["IT": 5]), true)
    ]

    for (outcome, expectedResult) in testCases {
      let backgroundTask = MockBackgroundTask()

      let dispatchInterceptor = DispatchInterceptor()
      let dependencies = AppDependencies.mocked(
        getAppState: getState,
        dispatch: dispatchInterceptor.dispatchFunction,
        exposureDetectionExecutor: MockExposureDetectionExecutor(outcome: outcome)
      )

      let context = AppSideEffectContext(dependencies: dependencies)

      try Logic.ExposureDetection.PerformExposureDetectionIfNecessary(type: .background(backgroundTask)).sideEffect(context)

      XCTAssertEqual(backgroundTask.setTaskCompletedMethodCalls, [expectedResult])
    }
  }

  func testErrorOutcomesAreNotPersisted() throws {
    var state = AppState()

    XCTAssertEqual(state.exposureDetection.recentPositiveExposureResults.count, 0)
    Logic.ExposureDetection.TrackExposureDetectionPerformed(outcome: .error(.notAuthorized), type: .foreground)
      .updateState(&state)
    XCTAssertEqual(state.exposureDetection.recentPositiveExposureResults.count, 0)
  }

  func testSkippedOutcomesAreNotPersisted() throws {
    var state = AppState()

    XCTAssertEqual(state.exposureDetection.recentPositiveExposureResults.count, 0)
    Logic.ExposureDetection.TrackExposureDetectionPerformed(outcome: .noDetectionNecessary, type: .foreground).updateState(&state)
    XCTAssertEqual(state.exposureDetection.recentPositiveExposureResults.count, 0)
  }

  func testPartialDetectionNoMatchesAreNotPersisted() throws {
    var state = AppState()

    XCTAssertEqual(state.exposureDetection.recentPositiveExposureResults.count, 0)
    Logic.ExposureDetection.TrackExposureDetectionPerformed(
      outcome: .partialDetection(Date(), .noMatch, ["IT": 0], ["IT": 5]),
      type: .foreground
    )
    .updateState(&state)
    XCTAssertEqual(state.exposureDetection.recentPositiveExposureResults.count, 0)
  }

  func testFullDetectionNoMatchesAreNotPersisted() throws {
    var state = AppState()

    XCTAssertEqual(state.exposureDetection.recentPositiveExposureResults.count, 0)
    Logic.ExposureDetection.TrackExposureDetectionPerformed(
      outcome: .fullDetection(Date(), .noMatch, [], ["IT": 0], ["IT": 5]),
      type: .foreground
    )
    .updateState(&state)
    XCTAssertEqual(state.exposureDetection.recentPositiveExposureResults.count, 0)
  }

  func testPartialDetectionMatchesArePersisted() throws {
    var state = AppState()

    let now = Date()
    let matchedKeyCount: UInt64 = 1
    let daysSinceLastExposure = 2
    let attenuationDurations: [TimeInterval] = [3, 4, 5]
    let maximumRiskScore: UInt8 = 6

    let summaryData = MockExposureDetectionSummaryData(
      durationByAttenuationBucket: attenuationDurations,
      daysSinceLastExposure: daysSinceLastExposure,
      matchedKeyCount: matchedKeyCount,
      maximumRiskScore: maximumRiskScore,
      metadata: nil
    )

    let outcome = ExposureDetectionOutcome.partialDetection(now, .matches(data: summaryData), ["IT": 0], ["IT": 5])

    XCTAssertEqual(state.exposureDetection.recentPositiveExposureResults.count, 0)
    Logic.ExposureDetection.TrackExposureDetectionPerformed(outcome: outcome, type: .foreground).updateState(&state)
    XCTAssertEqual(state.exposureDetection.recentPositiveExposureResults.count, 1)
    let positiveExposureResult = try XCTUnwrap(state.exposureDetection.recentPositiveExposureResults.first)

    XCTAssertEqual(positiveExposureResult.date, now)

    XCTAssertEqual(positiveExposureResult.date, now)
    XCTAssertEqual(positiveExposureResult.data.date, now.utcIsoString)
    XCTAssertEqual(positiveExposureResult.data.attenuationDurations, attenuationDurations.map { $0.roundedInt() })
    XCTAssertEqual(positiveExposureResult.data.daysSinceLastExposure, daysSinceLastExposure)
    XCTAssertEqual(positiveExposureResult.data.matchedKeyCount, Int(matchedKeyCount))
    XCTAssertEqual(positiveExposureResult.data.maximumRiskScore, Int(maximumRiskScore))
    XCTAssertEqual(positiveExposureResult.data.exposureInfo, [])
  }

  func testFullDetectionMatchesArePersisted() throws {
    var state = AppState()

    let now = Date()
    let matchedKeyCount: UInt64 = 1
    let daysSinceLastExposure = 2
    let attenuationDurations: [TimeInterval] = [3, 4, 5]
    let maximumRiskScore: UInt8 = 6
    let attenuationValue: UInt8 = 100
    let duration = attenuationDurations.reduce(0, +)
    let transmissionRisk = RiskLevel.high

    let summaryData = MockExposureDetectionSummaryData(
      durationByAttenuationBucket: attenuationDurations,
      daysSinceLastExposure: daysSinceLastExposure,
      matchedKeyCount: matchedKeyCount,
      maximumRiskScore: maximumRiskScore,
      metadata: nil
    )

    let exposureInfo = MockExposureInfo(
      attenuationValue: attenuationValue,
      durationByAttenuationBucket: attenuationDurations,
      date: now,
      duration: duration,
      transmissionRisk: transmissionRisk,
      totalRiskScore: maximumRiskScore,
      metadata: nil
    )

    let outcome = ExposureDetectionOutcome.fullDetection(now, .matches(data: summaryData), [exposureInfo], ["IT": 0], ["IT": 5])

    XCTAssertEqual(state.exposureDetection.recentPositiveExposureResults.count, 0)
    Logic.ExposureDetection.TrackExposureDetectionPerformed(outcome: outcome, type: .foreground).updateState(&state)
    XCTAssertEqual(state.exposureDetection.recentPositiveExposureResults.count, 1)
    let positiveExposureResult = try XCTUnwrap(state.exposureDetection.recentPositiveExposureResults.first)

    XCTAssertEqual(positiveExposureResult.date, now)

    XCTAssertEqual(positiveExposureResult.date, now)
    XCTAssertEqual(positiveExposureResult.data.date, now.utcIsoString)
    XCTAssertEqual(positiveExposureResult.data.attenuationDurations, attenuationDurations.map { $0.roundedInt() })
    XCTAssertEqual(positiveExposureResult.data.daysSinceLastExposure, daysSinceLastExposure)
    XCTAssertEqual(positiveExposureResult.data.matchedKeyCount, Int(matchedKeyCount))
    XCTAssertEqual(positiveExposureResult.data.maximumRiskScore, Int(maximumRiskScore))
    XCTAssertEqual(positiveExposureResult.data.exposureInfo.count, 1)
    let recordedExposureInfo = try XCTUnwrap(positiveExposureResult.data.exposureInfo.first)
    XCTAssertEqual(recordedExposureInfo.attenuationDurations, attenuationDurations.map { $0.roundedInt() })
    XCTAssertEqual(recordedExposureInfo.attenuationValue, Int(attenuationValue))
    XCTAssertEqual(recordedExposureInfo.date, now.utcIsoString)
    XCTAssertEqual(recordedExposureInfo.duration, duration.roundedInt())
    XCTAssertEqual(recordedExposureInfo.totalRiskScore, Int(maximumRiskScore))
    XCTAssertEqual(recordedExposureInfo.transmissionRiskLevel, transmissionRisk.intValue)
  }

  func testErrorOutcomeDoesNotTriggerUserStatusUpdate() throws {
    let state = AppState()
    let getState = { state }

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.ExposureDetection.UpdateUserStatusIfNecessary(outcome: .error(.notAuthorized)).sideEffect(context)
    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 0)
  }

  func testSkippedOutcomeDoesNotTriggerUserStatusUpdate() throws {
    let state = AppState()
    let getState = { state }

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.ExposureDetection.UpdateUserStatusIfNecessary(outcome: .noDetectionNecessary).sideEffect(context)
    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 0)
  }

  func testNoMatchPartialDetectionDoesNotTriggerUserStatusUpdate() throws {
    let state = AppState()
    let getState = { state }

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.ExposureDetection.UpdateUserStatusIfNecessary(outcome: .partialDetection(Date(), .noMatch, ["IT": 0], ["IT": 5]))
      .sideEffect(context)
    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 0)
  }

  func testNoMatchFullDetectionDoesNotTriggerUserStatusUpdate() throws {
    let state = AppState()
    let getState = { state }

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.ExposureDetection.UpdateUserStatusIfNecessary(outcome: .fullDetection(Date(), .noMatch, [], ["IT": 0], ["IT": 5]))
      .sideEffect(context)
    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 0)
  }

  func testMatchingPartialDetectionDoesNotTriggersUserStatusUpdate() throws {
    let state = AppState()
    let getState = { state }

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    let daysSinceLastExposure = 2

    let data = MockExposureDetectionSummaryData(
      durationByAttenuationBucket: [300, 600, 300],
      daysSinceLastExposure: daysSinceLastExposure,
      matchedKeyCount: 1,
      maximumRiskScore: 5,
      metadata: nil
    )

    try Logic.ExposureDetection
      .UpdateUserStatusIfNecessary(outcome: .partialDetection(Date(), .matches(data: data), ["IT": 0], ["IT": 5]))
      .sideEffect(context)
    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 0)
  }

  func testMatchingFullDetectionTriggersUserStatusUpdate() throws {
    let state = AppState()
    let getState = { state }

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    let daysSinceLastExposure = 2
    let lowRiskExposureDate = Date().addingTimeInterval(-Double(daysSinceLastExposure) * 24 * 60 * 60)
    let highRiskExposureDate = lowRiskExposureDate.addingTimeInterval(-1 * 24 * 60 * 60)

    let data = MockExposureDetectionSummaryData(
      durationByAttenuationBucket: [300, 600, 300],
      daysSinceLastExposure: daysSinceLastExposure,
      matchedKeyCount: 1,
      maximumRiskScore: 5,
      metadata: nil
    )

    // Older high risk exposure
    let highRiskExposure = MockExposureInfo(
      attenuationValue: 3,
      durationByAttenuationBucket: [300, 600, 300],
      date: highRiskExposureDate,
      duration: 1200,
      transmissionRisk: .high,
      totalRiskScore: 255,
      metadata: nil
    )

    // More recent low risk exposure
    let lowRiskExposure = MockExposureInfo(
      attenuationValue: 3,
      durationByAttenuationBucket: [300, 600, 300],
      date: lowRiskExposureDate,
      duration: 1200,
      transmissionRisk: .high,
      totalRiskScore: 1,
      metadata: nil
    )

    try Logic.ExposureDetection
      .UpdateUserStatusIfNecessary(outcome: .fullDetection(
        Date(),
        .matches(data: data),
        [highRiskExposure, lowRiskExposure],
        ["IT": 0],
        ["IT": 5]
      ))
      .sideEffect(context)
    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Logic.CovidStatus.UpdateStatusWithEvent.self) { dispatchable in
      guard case .contactDetected(let mostRecentContactDay) = dispatchable.event else {
        XCTFail("Wrong event type: \(dispatchable.event)")
        return
      }

      XCTAssertEqual(mostRecentContactDay, CalendarDay(date: highRiskExposureDate))
    }
  }

  func testClearOutdatedResultsOnlyClearsOutdatedResults() throws {
    var state = AppState()
    let now = Date()

    func timeAgo(_ value: TimeInterval) -> Date {
      return now.addingTimeInterval(-value)
    }

    let threshold = CovidStatus.alertPeriod

    state.exposureDetection.recentPositiveExposureResults = [
      .init(
        date: timeAgo(threshold + 2),
        data: .init(
          date: timeAgo(threshold + 2),
          matchedKeyCount: 3,
          daysSinceLastExposure: 2,
          attenuationDurations: [300, 600, 900],
          maximumRiskScore: 5,
          exposureInfo: []
        )
      ),
      .init(
        date: timeAgo(threshold + 1),
        data: .init(
          date: timeAgo(threshold + 1),
          matchedKeyCount: 3,
          daysSinceLastExposure: 2,
          attenuationDurations: [300, 600, 900],
          maximumRiskScore: 5,
          exposureInfo: []
        )
      ),
      .init(
        date: timeAgo(threshold),
        data: .init(
          date: timeAgo(threshold),
          matchedKeyCount: 3,
          daysSinceLastExposure: 2,
          attenuationDurations: [300, 600, 900],
          maximumRiskScore: 5,
          exposureInfo: []
        )
      ),
      .init(
        date: timeAgo(threshold - 1),
        data: .init(
          date: timeAgo(threshold - 1),
          matchedKeyCount: 3,
          daysSinceLastExposure: 2,
          attenuationDurations: [300, 600, 900],
          maximumRiskScore: 5,
          exposureInfo: []
        )
      ),
      .init(
        date: timeAgo(threshold - 2),
        data: .init(
          date: timeAgo(threshold - 2),
          matchedKeyCount: 3,
          daysSinceLastExposure: 2,
          attenuationDurations: [300, 600, 900],
          maximumRiskScore: 5,
          exposureInfo: []
        )
      )
    ]

    Logic.ExposureDetection.ClearOutdatedResults(now: now).updateState(&state)
    XCTAssertEqual(state.exposureDetection.recentPositiveExposureResults.count, 3)
  }
}

extension ExposureDetectionOutcome {
  enum Case: Equatable {
    case noDetectionNecessary
    case partialDetection
    case fullDetection
    case error
  }

  var rawCase: Case {
    switch self {
    case .noDetectionNecessary:
      return .noDetectionNecessary
    case .fullDetection:
      return .fullDetection
    case .partialDetection:
      return .partialDetection
    case .error:
      return .error
    }
  }
}

extension ExposureDetectionError {
  enum Case: Equatable {
    case timeout
    case notAuthorized
    case unableToRetrieveKeys
    case unableToRetrieveStatus
    case unableToRetrieveSummary
    case unableToRetrieveExposureInfo
  }

  var rawCase: Case {
    switch self {
    case .timeout:
      return .timeout
    case .notAuthorized:
      return .notAuthorized
    case .unableToRetrieveKeys:
      return .unableToRetrieveKeys
    case .unableToRetrieveStatus:
      return .unableToRetrieveStatus
    case .unableToRetrieveSummary:
      return .unableToRetrieveSummary
    case .unableToRetrieveExposureInfo:
      return .unableToRetrieveExposureInfo
    }
  }
}

private extension RiskLevel {
  var intValue: Int {
    switch self {
    case .invalid:
      return 0
    case .lowest:
      return 1
    case .low:
      return 2
    case .lowMedium:
      return 3
    case .medium:
      return 4
    case .mediumHigh:
      return 5
    case .high:
      return 6
    case .veryHigh:
      return 7
    case .highest:
      return 8
    }
  }
}
