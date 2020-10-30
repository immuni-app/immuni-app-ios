// MigrationTests.swift
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
import Models
import XCTest

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
