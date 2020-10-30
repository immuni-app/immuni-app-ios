//
//  MigrationTests.swift
//  Immuni Tests
//
//  Created by LorDisturbia on 30/10/2020.
//

import Foundation
import Models
import XCTest
@testable import Immuni

final class MigrationTests: XCTestCase {
  // MARK: PerformMigrationsIfNecessary
  func testPerformMigrationsIfNecessary_performsAllMigrations() throws {
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(
      dispatch: dispatchInterceptor.dispatchFunction
    )

    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.PerformMigrationsIfNecessary().sideEffect(context)

    XCTAssertEqual(dispatchInterceptor.dispatchedItems.count, 1)
    try XCTAssertType(dispatchInterceptor.dispatchedItems[0], Logic.ExposureDetection.ClearRiskStatusIfWronglyAttributed.self)
  }

  // MARK: - Migration 1
  func testFirstMigration_whenUserStartsNeutral_statusDoesNotChange() throws {
    let date = Date()
    let summary: CodableExposureDetectionSummary = .mock(
      date: date,
      exposureInfo: [
        .mock(
          date: date.addingTimeInterval(-86400),
          totalRiskScore: 1000
        )
      ]
    )

    let got = Logic.ExposureDetection.ClearRiskStatusIfWronglyAttributed.correctUserStatus(
      currentStatus: .neutral,
      recentPositiveExposureResults: [.init(date: Date(), data: summary)],
      closeContactRiskThreshold: 0
    )

    XCTAssertEqual(got.rawCase, .neutral)
  }

  func testFirstMigration_whenUserStartsPositive_statusDoesNotChange() throws {
    let date = Date()
    let summary: CodableExposureDetectionSummary = .mock(
      date: date,

      exposureInfo: [
        .mock(
          date: date.addingTimeInterval(-86400),
          totalRiskScore: 1000
        )
      ]
    )

    let got = Logic.ExposureDetection.ClearRiskStatusIfWronglyAttributed.correctUserStatus(
      currentStatus: .positive(lastUpload: CalendarDay(year: 2020, month: 11, day: 30)),
      recentPositiveExposureResults: [.init(date: Date(), data: summary)],
      closeContactRiskThreshold: 0
    )

    guard case .positive(let lastUpload) = got else {
      XCTFail("Unexpected status \(got)")
      return
    }

    XCTAssertEqual(lastUpload, CalendarDay(year: 2020, month: 11, day: 30))
  }

  func testFirstMigration_whenUserStartsRisky_whenNoRecentPositiveExposureResults_statusGoesToNeutral() throws {
    let got = Logic.ExposureDetection.ClearRiskStatusIfWronglyAttributed.correctUserStatus(
      currentStatus: .risk(lastContact: CalendarDay(year: 2020, month: 11, day: 30)),
      recentPositiveExposureResults: [],
      closeContactRiskThreshold: 0
    )

    XCTAssertEqual(got.rawCase, .neutral)
  }

  func testFirstMigration_whenUserStartsRisky_whenAllRecentPositiveExposureResultsBelowThreshold_statusGoesToNeutral() throws {
    let date = Date()
    let summary: CodableExposureDetectionSummary = .mock(
      date: date,
      exposureInfo: [
        .mock(
          date: date.addingTimeInterval(-86400),
          totalRiskScore: 1000
        )
      ]
    )

    let got = Logic.ExposureDetection.ClearRiskStatusIfWronglyAttributed.correctUserStatus(
      currentStatus: .risk(lastContact: CalendarDay(year: 2020, month: 11, day: 30)),
      recentPositiveExposureResults: [.init(date: Date(), data: summary)],
      closeContactRiskThreshold: .max
    )

    XCTAssertEqual(got.rawCase, .neutral)
  }

  func testFirstMigration_whenUserStartsRisky_whenOneRecentPositiveExposureResultsAboveThreshold_statusIsUpdated() throws {
    let date = Date()
    let summary: CodableExposureDetectionSummary = .mock(
      date: date,
      exposureInfo: [
        .mock(
          date: date.addingTimeInterval(-2 * 86400),
          totalRiskScore: 1000
        ),
        .mock(
          date: date.addingTimeInterval(-1 * 86400),
          totalRiskScore: 1
        )
      ]
    )

    let got = Logic.ExposureDetection.ClearRiskStatusIfWronglyAttributed.correctUserStatus(
      currentStatus: .risk(lastContact: CalendarDay(year: 2019, month: 11, day: 30)),
      recentPositiveExposureResults: [.init(date: Date(), data: summary)],
      closeContactRiskThreshold: 1000
    )

    guard case .risk(let lastContact) = got else {
      XCTFail("Unexpected status \(got)")
      return
    }

    XCTAssertEqual(lastContact, date.addingTimeInterval(-2 * 86400).utcCalendarDay)
  }

  func testFirstMigration_whenUserStartsRisky_whenMultipleRecentPositiveExposureResultsAboveThreshold_statusIsUpdated() throws {
    let date = Date()
    let summary: CodableExposureDetectionSummary = .mock(
      date: date,
      exposureInfo: [
        .mock(
          date: date.addingTimeInterval(-2 * 86400),
          totalRiskScore: 1001
        ),
        .mock(
          date: date.addingTimeInterval(-1 * 86400),
          totalRiskScore: 1002
        )
      ]
    )

    let got = Logic.ExposureDetection.ClearRiskStatusIfWronglyAttributed.correctUserStatus(
      currentStatus: .risk(lastContact: CalendarDay(year: 2020, month: 11, day: 30)),
      recentPositiveExposureResults: [.init(date: Date(), data: summary)],
      closeContactRiskThreshold: 1000
    )

    guard case .risk(let lastContact) = got else {
      XCTFail("Unexpected status \(got)")
      return
    }

    XCTAssertEqual(lastContact, date.addingTimeInterval(-1 * 86400).utcCalendarDay)
  }

  func testFirstMigration_whenToggleIsFalse_isPerformed() throws {
    var state = AppState()
    state.toggles.isWronglyAttributedRiskStatusBeenChecked = false
    state.user.covidStatus = .risk(lastContact: .init(year: 2020, month: 11, day: 30))
    state.exposureDetection.previousDetectionResults = []

    Logic.ExposureDetection.ClearRiskStatusIfWronglyAttributed().updateState(&state)

    XCTAssertEqual(state.toggles.isWronglyAttributedRiskStatusBeenChecked, true)
    XCTAssertEqual(state.user.covidStatus.rawCase, .neutral)
  }

  func testFirstMigration_whenToggleIsTrue_isNotPerformed() throws {
    var state = AppState()
    state.toggles.isWronglyAttributedRiskStatusBeenChecked = true
    state.user.covidStatus = .risk(lastContact: .init(year: 2020, month: 11, day: 30))
    state.exposureDetection.previousDetectionResults = []

    Logic.ExposureDetection.ClearRiskStatusIfWronglyAttributed().updateState(&state)

    XCTAssertEqual(state.toggles.isWronglyAttributedRiskStatusBeenChecked, true)

    guard case .risk(let lastContact) = state.user.covidStatus else {
      XCTFail("Unexpected user status \(state.user.covidStatus)")
      return
    }

    XCTAssertEqual(lastContact, .init(year: 2020, month: 11, day: 30))
  }
}
