// DataUploadLogicTests.swift
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
import Foundation
import Hydra
@testable import Immuni
import ImmuniExposureNotification
import Katana
import Models
import Networking
import Tempura
import XCTest

final class DataUploadLogicTests: XCTestCase {
  override func tearDown() {
    super.tearDown()
    DeterministicGenerator.randomValue = 0.5
  }

  func testVerifyCodeChecksExposureNotificationPermission() throws {
    let state = AppState()
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.VerifyCode(code: OTP()).sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.DataUpload.AssertExposureNotificationPermissionGranted.self
    )
  }

  func testVerifyCodeSendsAVerifyRequest() throws {
    let state = AppState()
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let requestExecutor = MockRequestExecutor(mockedResult: .success(Data()))

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor
    )
    let context = AppSideEffectContext(dependencies: dependencies)

    let otp = OTP()

    try Logic.DataUpload.VerifyCode(code: otp).sideEffect(context)

    XCTAssertEqual(requestExecutor.executeMethodCalls.count, 1)
    try XCTAssertType(requestExecutor.executeMethodCalls.first, OTPValidationRequest.self) { request in
      XCTAssertEqual(request.otp.rawValue, otp.rawValue)

      let headers = Dictionary(uniqueKeysWithValues: request.headers.map { ($0.name, $0.value) })
      XCTAssertNotNil(headers["Authorization"])
      XCTAssertEqual(headers["Content-Type"], "application/json; charset=UTF-8")
      XCTAssertEqual(headers["Immuni-Dummy-Data"], "0")
    }
  }

  func testThrowsOnFailedOTPValidationAttempt() throws {
    let state = AppState()
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let requestExecutor = MockRequestExecutor(mockedResult: .failure(NetworkManager.Error.unauthorizedOTP))

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor
    )
    let context = AppSideEffectContext(dependencies: dependencies)

    let otp = OTP()

    XCTAssertThrowsError(try Logic.DataUpload.VerifyCode(code: otp).sideEffect(context), "Expected throw") { error in
      do {
        try XCTAssertType(error, Logic.DataUpload.VerifyCode.Error.self)
      } catch {
        XCTFail("Unexpected error \(error)")
      }
    }
  }

  func testTracksFailedOTPValidationAttempt() throws {
    let state = AppState()
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let requestExecutor = MockRequestExecutor(mockedResult: .failure(NetworkManager.Error.unauthorizedOTP))

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor
    )
    let context = AppSideEffectContext(dependencies: dependencies)

    let otp = OTP()

    do {
      try Logic.DataUpload.VerifyCode(code: otp).sideEffect(context)
    } catch {
      // Catch silently to evaluate asserts
    }

    try XCTAssertContainsType(dispatchInterceptor.dispatchedItems, Logic.DataUpload.MarkOTPValidationFailedAttempt.self)
  }

  func testShowsConfirmDataIfCodeIsValidated() throws {
    let state = AppState()
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let requestExecutor = MockRequestExecutor(mockedResult: .success(Data()))

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor
    )
    let context = AppSideEffectContext(dependencies: dependencies)

    let otp = OTP()
    try Logic.DataUpload.VerifyCode(code: otp).sideEffect(context)

    try XCTAssertContainsType(dispatchInterceptor.dispatchedItems, Logic.DataUpload.ShowConfirmData.self) { dispatchable in
      XCTAssertEqual(dispatchable.code.rawValue, otp.rawValue)
    }
  }

  func testShowConfirmDataShowsTheCorrectScreen() throws {
    let state = AppState()
    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.ShowConfirmData(code: OTP()).sideEffect(context)

    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Tempura.Show.self) { dispatchable in
      XCTAssertEqual(dispatchable.identifiersToShow, [Screen.confirmUpload.rawValue])
    }
  }

  func testConfirmDataChecksExposureNotificationPermission() throws {
    var state = AppState()
    state.user.province = .trieste

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let dependencies = AppDependencies.mocked(getAppState: getState, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.ConfirmData(code: OTP()).sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.DataUpload.AssertExposureNotificationPermissionGranted.self
    )
  }

  func testConfirmDataRetrievesKeys() throws {
    var state = AppState()
    state.user.province = .trieste

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let enProvider = MockExposureNotificationProvider(overriddenStatus: .authorized)

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      exposureNotificationProvider: enProvider
    )
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.ConfirmData(code: OTP()).sideEffect(context)

    XCTAssertEqual(enProvider.getDiagnosisKeysMethodCalls, 1)
  }

  func testConfirmDataSendsDataUploadRequest() throws {
    var state = AppState()
    state.user.province = .trieste

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let clock = Date(timeIntervalSince1970: 1_590_073_834)

    let matchDate = clock.addingTimeInterval(-24 * 60 * 60)
    let matchedKeyCount: Int = 1
    let daysSinceLastExposure = 2
    let attenuationDurations: [TimeInterval] = [3, 4, 5]
    let maximumRiskScore: Int = 6
    let attenuationValue: Int = 100
    let duration = attenuationDurations.reduce(0, +)
    let transmissionRisk = 5

    let exposureInfo = CodableExposureInfo(
      date: matchDate,
      duration: duration,
      attenuationValue: attenuationValue,
      attenuationDurations: attenuationDurations,
      transmissionRiskLevel: transmissionRisk,
      totalRiskScore: maximumRiskScore
    )

    let summary = CodableExposureDetectionSummary(
      date: clock,
      matchedKeyCount: matchedKeyCount,
      daysSinceLastExposure: daysSinceLastExposure,
      attenuationDurations: attenuationDurations,
      maximumRiskScore: maximumRiskScore,
      exposureInfo: [exposureInfo]
    )

    state.exposureDetection.recentPositiveExposureResults.append(.init(date: clock, data: summary))

    let teks = (0 ..< 14).map { _ in MockTemporaryExposureKey.mock() }
      .sorted(by: { $0.rollingStartNumber < $1.rollingStartNumber })
    let enProvider = TekReturningMockExposureNotificationProvider(teksToReturn: teks, overriddenStatus: .authorized)
    let requestExecutor = MockRequestExecutor(mockedResult: .success(Data()))

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor,
      now: { clock },
      exposureNotificationProvider: enProvider
    )
    let context = AppSideEffectContext(dependencies: dependencies)

    let otp = OTP()
    try Logic.DataUpload.ConfirmData(code: otp).sideEffect(context)

    XCTAssertEqual(requestExecutor.executeMethodCalls.count, 1)
    try XCTAssertType(requestExecutor.executeMethodCalls.first, DataUploadRequest.self) { request in
      XCTAssertEqual(request.otp.rawValue, otp.rawValue)

      let headers = Dictionary(uniqueKeysWithValues: request.headers.map { ($0.name, $0.value) })
      XCTAssertNotNil(headers["Authorization"])
      XCTAssertEqual(headers["Content-Type"], "application/json; charset=UTF-8")
      XCTAssertEqual(headers["Immuni-Dummy-Data"], "0")
      XCTAssertEqual(headers["Immuni-Client-Clock"], String(clock.timeIntervalSince1970.roundedInt()))

      XCTAssertEqual(request.jsonParameter.teks.count, teks.count)

      let sortedRequestTeks = request.jsonParameter.teks
        .sorted(by: { $0.rollingStartNumber < $1.rollingStartNumber })
      for (index, requestTek) in sortedRequestTeks.enumerated() {
        XCTAssertEqual(requestTek.base64EncodedKeyData, teks[index].keyData.base64EncodedString())
        XCTAssertEqual(requestTek.rollingPeriod, Int(teks[index].rollingPeriod))
        XCTAssertEqual(requestTek.rollingStartNumber, Int(teks[index].rollingStartNumber))
      }

      XCTAssertEqual(request.jsonParameter.exposureDetectionSummaries.count, 1)
      let requestSummary = try XCTUnwrap(request.jsonParameter.exposureDetectionSummaries.first)
      XCTAssertEqual(requestSummary.attenuationDurations, attenuationDurations.map { $0.roundedInt() })
      XCTAssertEqual(requestSummary.date, clock.utcIsoString)
      XCTAssertEqual(requestSummary.daysSinceLastExposure, daysSinceLastExposure)
      XCTAssertEqual(requestSummary.exposureInfo, [exposureInfo])
      XCTAssertEqual(requestSummary.matchedKeyCount, matchedKeyCount)
      XCTAssertEqual(requestSummary.maximumRiskScore, maximumRiskScore)
    }

    func testConfirmDataUpdatesUserState() throws {
      var state = AppState()
      state.user.province = .trieste

      let getState = { state }
      let dispatchInterceptor = DispatchInterceptor()

      let clock = Date(timeIntervalSince1970: 1_590_073_834)

      let dependencies = AppDependencies.mocked(
        getAppState: getState,
        dispatch: dispatchInterceptor.dispatchFunction,
        requestExecutor: MockRequestExecutor(mockedResult: .success(Data())),
        now: { clock }
      )

      let context = AppSideEffectContext(dependencies: dependencies)

      try Logic.DataUpload.ConfirmData(code: OTP()).sideEffect(context)

      try XCTAssertContainsType(
        dispatchInterceptor.dispatchedItems,
        Logic.CovidStatus.UpdateStatusWithEvent.self
      ) { dispatchable in
        guard case .dataUpload(let date) = dispatchable.event else {
          XCTFail("Wrong event \(dispatchable.event)")
          return
        }

        XCTAssertEqual(date, clock.calendarDay)
      }
    }
  }

  func testFailedOTPValidationUpdatesState() throws {
    var state = AppState()
    state.ingestion.otpValidationFailedAttempts = 7
    state.ingestion.lastOtpValidationFailedAttempt = Date(timeIntervalSince1970: 0)

    let now = Date(timeIntervalSince1970: 1_590_073_834)

    Logic.DataUpload.MarkOTPValidationFailedAttempt(date: now).updateState(&state)

    XCTAssertEqual(state.ingestion.otpValidationFailedAttempts, 8)
    XCTAssertEqual(state.ingestion.lastOtpValidationFailedAttempt, now)
  }

  func testSuccessfulOTPValidationUpdatesState() throws {
    var state = AppState()
    state.ingestion.otpValidationFailedAttempts = 7
    state.ingestion.lastOtpValidationFailedAttempt = Date(timeIntervalSince1970: 0)

    Logic.DataUpload.MarkOTPValidationSuccessfulAttempt().updateState(&state)

    XCTAssertEqual(state.ingestion.otpValidationFailedAttempts, 0)
    XCTAssertEqual(state.ingestion.lastOtpValidationFailedAttempt, nil)
  }
}

// MARK: - Dummy Data

extension DataUploadLogicTests {
  func testUpdatesOpportunityWindow() throws {
    let state = AppState()

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let clock = Date(timeIntervalSince1970: 1_590_073_834)

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      now: { clock },
      exponentialDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.UpdateDummyTrafficOpportunityWindow().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)
    try XCTAssertType(
      dispatchInterceptor.dispatchedItems.first,
      Logic.DataUpload.SetDummyTrafficOpportunityWindow.self
    ) { dispatchable in
      XCTAssertEqual(dispatchable.now, clock)
      XCTAssertEqual(dispatchable.dummyTrafficStochasticDelay, DeterministicGenerator.randomValue)
    }
  }

  func testDoesNotUpdateOpportunityWindowIfBeforeWindowStart() throws {
    let clock = Date(timeIntervalSince1970: 1_590_073_834)

    var state = AppState()
    state.ingestion.dummyTrafficOpportunityWindow = .init(windowStart: clock.addingTimeInterval(1), windowDuration: 1)

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      now: { clock },
      exponentialDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.UpdateDummyTrafficOpportunityWindowIfExpired().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 0)
  }

  func testDoesNotUpdateOpportunityWindowIfDuringWindow() throws {
    let clock = Date(timeIntervalSince1970: 1_590_073_834)

    var state = AppState()
    state.ingestion.dummyTrafficOpportunityWindow = .init(windowStart: clock.addingTimeInterval(-1), windowDuration: 2)

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      now: { clock },
      exponentialDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.UpdateDummyTrafficOpportunityWindowIfExpired().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 0)
  }

  func testUpdatesOpportunityWindowIfAfterWindow() throws {
    let clock = Date(timeIntervalSince1970: 1_590_073_834)

    var state = AppState()
    state.ingestion.dummyTrafficOpportunityWindow = .init(windowStart: clock.addingTimeInterval(-2), windowDuration: 1)

    let getState = { state }
    let dispatchInterceptor = DispatchInterceptor()

    let dependencies = AppDependencies.mocked(
      getAppState: getState,
      dispatch: dispatchInterceptor.dispatchFunction,
      now: { clock },
      exponentialDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.UpdateDummyTrafficOpportunityWindowIfExpired().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)
    try XCTAssertType(dispatchInterceptor.dispatchedItems.first, Logic.DataUpload.UpdateDummyTrafficOpportunityWindow.self)
  }
}

// MARK: - Dummy traffic lifecycle

extension DataUploadLogicTests {
  func testFirstLaunchSetupAlwaysUpdatesTheOpportunityWindow() throws {
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(dispatch: dispatchInterceptor.dispatchFunction)

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.PerformFirstLaunchSetupIfNeeded().sideEffect(context)

    try XCTAssertContainsType(dispatchInterceptor.dispatchedItems, Logic.DataUpload.UpdateDummyTrafficOpportunityWindow.self)
  }

  func testHandleBackgroundSessionUpdatesTheOpportunityWindowWhenExpired() throws {
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(dispatch: dispatchInterceptor.dispatchFunction)

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.HandleExposureDetectionBackgroundTask(task: MockBackgroundTask()).sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.DataUpload.UpdateDummyTrafficOpportunityWindowIfExpired.self
    )
  }

  func testOnStartUpdatesTheOpportunityWindowWhenExpiredIfNotFirstLaunch() throws {
    var state = AppState()
    state.toggles.isFirstLaunchSetupPerformed = true

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: { state }, dispatch: dispatchInterceptor.dispatchFunction)

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.OnStart().sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.DataUpload.UpdateDummyTrafficOpportunityWindowIfExpired.self
    )
  }

  func testWillEnterForegroundUpdatesTheOpportunityWindowWhenExpiredIfNotFirstLaunch() throws {
    var state = AppState()
    state.toggles.isFirstLaunchSetupPerformed = true

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: { state }, dispatch: dispatchInterceptor.dispatchFunction)

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.OnStart().sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.DataUpload.UpdateDummyTrafficOpportunityWindowIfExpired.self
    )
  }

  func testOnStartSchedulesDummyTrafficIfNotFirstLaunch() throws {
    var state = AppState()
    state.toggles.isFirstLaunchSetupPerformed = true

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: { state }, dispatch: dispatchInterceptor.dispatchFunction)

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.OnStart().sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.DataUpload.ScheduleDummyIngestionSequenceIfNecessary.self
    )
  }

  func testWillEnterForegroundSchedulesDummyTrafficIfNotFirstLaunch() throws {
    var state = AppState()
    state.toggles.isFirstLaunchSetupPerformed = true

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: { state }, dispatch: dispatchInterceptor.dispatchFunction)

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.OnStart().sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.DataUpload.ScheduleDummyIngestionSequenceIfNecessary.self
    )
  }

  func testSimulationIsCancelledIfOpeningDataUploadScreen() throws {
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(dispatch: dispatchInterceptor.dispatchFunction)

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.ShowUploadData(callCenterMode: false).sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.DataUpload.SetDummyTrafficSequenceCancelled.self
    ) { dispatchable in
      XCTAssertEqual(dispatchable.value, true)
    }
  }

  func testForegroundSessionIsMarkedFinishedWhenEnteringBackground() throws {
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(dispatch: dispatchInterceptor.dispatchFunction)

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.DidEnterBackground().sideEffect(context)

    try XCTAssertContainsType(dispatchInterceptor.dispatchedItems, Logic.DataUpload.MarkForegroundSessionFinished.self)
  }
}

// MARK: - Dummy traffic scheduling

extension DataUploadLogicTests {
  func testDummyTrafficScheduledIfWithinOpportunityWindow() throws {
    let clock = Date()

    var state = AppState()
    state.ingestion.dummyTrafficOpportunityWindow = .init(windowStart: clock.addingTimeInterval(-1), windowDuration: 2)

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: { state },
      dispatch: dispatchInterceptor.dispatchFunction,
      exponentialDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.ScheduleDummyIngestionSequenceIfNecessary().sideEffect(context)

    try XCTAssertContainsType(dispatchInterceptor.dispatchedItems, DelayedDispatchable.self) { dispatchable in
      XCTAssertEqual(dispatchable.delay, DeterministicGenerator.randomValue)
      try XCTAssertType(dispatchable.dispatchable, Logic.DataUpload.StartIngestionSequenceIfNotCancelled.self)
    }
  }

  func testDummyTrafficNotScheduledIfBeforeOpportunityWindow() throws {
    let clock = Date()

    var state = AppState()
    state.ingestion.dummyTrafficOpportunityWindow = .init(windowStart: clock.addingTimeInterval(-2), windowDuration: 1)

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: { state }, dispatch: dispatchInterceptor.dispatchFunction)

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.ScheduleDummyIngestionSequenceIfNecessary().sideEffect(context)

    try XCTAssertNotContainsType(dispatchInterceptor.dispatchedItems, DelayedDispatchable.self)
  }

  func testDummyTrafficNotScheduledIfAfterOpportunityWindow() throws {
    let clock = Date()

    var state = AppState()
    state.ingestion.dummyTrafficOpportunityWindow = .init(windowStart: clock.addingTimeInterval(1), windowDuration: 1)

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: { state }, dispatch: dispatchInterceptor.dispatchFunction)

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.ScheduleDummyIngestionSequenceIfNecessary().sideEffect(context)

    try XCTAssertNotContainsType(dispatchInterceptor.dispatchedItems, DelayedDispatchable.self)
  }

  func testDummyTrafficSchedulingIsSetInState() throws {
    let clock = Date()

    var state = AppState()
    state.ingestion.dummyTrafficOpportunityWindow = .init(windowStart: clock.addingTimeInterval(-1), windowDuration: 2)

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: { state },
      dispatch: dispatchInterceptor.dispatchFunction,
      exponentialDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.ScheduleDummyIngestionSequenceIfNecessary().sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.DataUpload.SetDummyIngestionSequenceScheduledForThisSession.self
    ) { dispatchable in
      XCTAssertEqual(dispatchable.value, true)
    }
  }

  func testDummyTrafficNotScheduledTwice() throws {
    let clock = Date()

    var state = AppState()
    state.ingestion.dummyTrafficOpportunityWindow = .init(windowStart: clock.addingTimeInterval(-1), windowDuration: 2)
    state.ingestion.dummyTrafficSequenceScheduledInSession = true

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: { state },
      dispatch: dispatchInterceptor.dispatchFunction,
      exponentialDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.ScheduleDummyIngestionSequenceIfNecessary().sideEffect(context)

    try XCTAssertNotContainsType(dispatchInterceptor.dispatchedItems, DelayedDispatchable.self)
  }
}

// MARK: - Dummy traffic scheduling

extension DataUploadLogicTests {
  func testSimulationDoesNotStartIfSessionCancelled() throws {
    var state = AppState()
    state.ingestion.isDummyTrafficSequenceCancelled = true

    let requestExecutor = MockRequestExecutor(mockedResult: .success(Data()))

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: { state },
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor,
      exponentialDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.StartIngestionSequenceIfNotCancelled().sideEffect(context)

    XCTAssertEqual(requestExecutor.executeMethodCalls.count, 0)
  }

  func testSimulationUpdatesOpportunityWindowIfCancelled() throws {
    var state = AppState()
    state.ingestion.isDummyTrafficSequenceCancelled = true

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: { state },
      dispatch: dispatchInterceptor.dispatchFunction
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.StartIngestionSequenceIfNotCancelled().sideEffect(context)

    try XCTAssertContainsType(dispatchInterceptor.dispatchedItems, Logic.DataUpload.UpdateDummyTrafficOpportunityWindow.self)
  }

  func testSimulationSendsOneRequestEvenIfProbabilityIsZero() throws {
    var state = AppState()
    state.ingestion.isDummyTrafficSequenceCancelled = false

    let requestExecutor = MockRequestExecutor(mockedResult: .success(Data()))

    DeterministicGenerator.randomValue = 1

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: { state },
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor,
      uniformDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.StartIngestionSequenceIfNotCancelled().sideEffect(context)

    XCTAssertEqual(requestExecutor.executeMethodCalls.count, 1)
  }

  func testSimulationUpdatesOpportunityWindowIfNotCancelled() throws {
    var state = AppState()
    state.ingestion.isDummyTrafficSequenceCancelled = false

    // Fail the first dice roll
    DeterministicGenerator.randomValue = 1

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: { state },
      dispatch: dispatchInterceptor.dispatchFunction,
      uniformDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.StartIngestionSequenceIfNotCancelled().sideEffect(context)

    try XCTAssertContainsType(dispatchInterceptor.dispatchedItems, Logic.DataUpload.UpdateDummyTrafficOpportunityWindow.self)
  }

  func testReleasesSimulationSession() throws {
    var state = AppState()
    state.ingestion.isDummyTrafficSequenceCancelled = true

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: { state },
      dispatch: dispatchInterceptor.dispatchFunction
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.StartIngestionSequenceIfNotCancelled().sideEffect(context)

    try XCTAssertContainsType(
      dispatchInterceptor.dispatchedItems,
      Logic.DataUpload.SetDummyIngestionSequenceScheduledForThisSession.self
    ) { dispatchable in
      XCTAssertEqual(dispatchable.value, false)
    }
  }

  func testSimulationStopsIfSequenceIsCancelled() throws {
    let stateChangingClosure: (() -> AppState) = {
      var counter = 0
      return {
        var state = AppState()
        state.ingestion.isDummyTrafficSequenceCancelled = counter >= 2
        counter += 1
        return state
      }
    }()

    let requestExecutor = MockRequestExecutor(mockedResult: .success(Data()))

    // Always pass the dice rolls and never block on awaits
    DeterministicGenerator.randomValue = 0

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      getAppState: stateChangingClosure,
      dispatch: dispatchInterceptor.dispatchFunction,
      requestExecutor: requestExecutor,
      uniformDistributionGenerator: DeterministicGenerator.self,
      exponentialDistributionGenerator: DeterministicGenerator.self
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.DataUpload.StartIngestionSequenceIfNotCancelled().sideEffect(context)

    XCTAssertEqual(requestExecutor.executeMethodCalls.count, 2)
  }
}

// MARK: - Mocks

class TekReturningMockExposureNotificationProvider: MockExposureNotificationProvider {
  let teksToReturn: [MockTemporaryExposureKey]

  init(teksToReturn: [MockTemporaryExposureKey], overriddenStatus: ExposureNotificationStatus = .unknown) {
    self.teksToReturn = teksToReturn
    super.init(overriddenStatus: overriddenStatus)
  }

  override func getDiagnosisKeys() -> Promise<[TemporaryExposureKey]> {
    return super.getDiagnosisKeys().then(in: .background) { _ in self.teksToReturn }
  }
}
