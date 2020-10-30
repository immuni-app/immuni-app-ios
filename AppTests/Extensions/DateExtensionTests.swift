// DateExtensionTests.swift
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

import XCTest

final class DateExtensionsTests: XCTestCase {
  func testUtcIsoStringIsComputedCorrectly() throws {
    let date = Date(timeIntervalSince1970: 1_604_102_399) // Friday, October 30, 2020 11:59:59 PM (GMT)
    XCTAssertEqual(date.utcIsoString, "2020-10-30")
  }

  func testUtcIsoStringIsReadCorrectly() throws {
    let expected = Date(timeIntervalSince1970: 1_604_016_000) // Friday, October 30, 2020 12:00:00 AM (GMT)
    XCTAssertEqual(Date(utcIsoString: "2020-10-30"), expected)
  }
}
