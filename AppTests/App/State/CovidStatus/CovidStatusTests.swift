// CovidStatusTests.swift
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
import Katana
import Models
import XCTest

private struct CovidStatusTestCase {
  let from: CovidStatus
  let event: CovidEvent
  let expectedTo: CovidStatus
}

let referenceDate = CalendarDay(year: 2020, month: 1, day: 1)
let afterTwoDaysDate = referenceDate.byAdding(days: 2)

private let neutralTransitionTest: [CovidStatusTestCase] = [
  .init(
    from: .neutral,
    event: .contactDetected(date: referenceDate),
    expectedTo: .risk(lastContact: referenceDate)
  ),
  .init(from: .neutral, event: .dataUpload(currentDate: referenceDate), expectedTo: .positive(lastUpload: referenceDate)),
  .init(from: .neutral, event: .userEvent(.alertDismissal), expectedTo: .neutral),
  .init(from: .neutral, event: .userEvent(.recoverConfirmed), expectedTo: .neutral)
]

private let riskTransitionTest: [CovidStatusTestCase] = [
  .init(
    from: .risk(lastContact: referenceDate),
    event: .contactDetected(date: afterTwoDaysDate),
    expectedTo: .risk(lastContact: afterTwoDaysDate)
  ),
  .init(
    from: .risk(lastContact: referenceDate),
    event: .dataUpload(currentDate: referenceDate),
    expectedTo: .positive(lastUpload: referenceDate)
  ),
  .init(from: .risk(lastContact: referenceDate), event: .userEvent(.alertDismissal), expectedTo: .neutral),
  .init(
    from: .risk(lastContact: referenceDate),
    event: .userEvent(.recoverConfirmed),
    expectedTo: .risk(lastContact: referenceDate)
  )
]

private let positiveTransitionTest: [CovidStatusTestCase] = [
  .init(
    from: .positive(lastUpload: referenceDate),
    event: .contactDetected(date: afterTwoDaysDate),
    expectedTo: .positive(lastUpload: referenceDate)
  ),
  .init(
    from: .positive(lastUpload: referenceDate),
    event: .contactDetected(date: afterTwoDaysDate),
    expectedTo: .positive(lastUpload: referenceDate)
  ),
  .init(
    from: .positive(lastUpload: referenceDate),
    event: .dataUpload(currentDate: afterTwoDaysDate),
    expectedTo: .positive(lastUpload: afterTwoDaysDate)
  ),
  .init(
    from: .positive(lastUpload: referenceDate),
    event: .userEvent(.alertDismissal),
    expectedTo: .positive(lastUpload: referenceDate)
  ),
  .init(from: .positive(lastUpload: referenceDate), event: .userEvent(.recoverConfirmed), expectedTo: .neutral)
]

final class CovidStatusNeutralTests: XCTestCase {
  func testNeutralTransitions() throws {
    for testCase in neutralTransitionTest {
      XCTAssertEqual(testCase.expectedTo, testCase.from.transitioned(becauseOf: testCase.event))
    }
  }

  func testRiskTransitions() throws {
    for testCase in riskTransitionTest {
      XCTAssertEqual(testCase.expectedTo, testCase.from.transitioned(becauseOf: testCase.event))
    }
  }

  func testPositiveTransitions() throws {
    for testCase in positiveTransitionTest {
      XCTAssertEqual(testCase.expectedTo, testCase.from.transitioned(becauseOf: testCase.event))
    }
  }
}
