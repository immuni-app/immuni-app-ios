// MostRecentContactDayTests.swift
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

import ImmuniExposureNotification
import Models
import XCTest

final class MostRecentContactDayTests: XCTestCase {
  // MARK: - CodableInfo

  func testMostRecentContactDay_onCodableExposureInfo_whenEmpty_returnsNil() throws {
    let exposureInfo: [CodableExposureInfo] = []
    XCTAssertNil(exposureInfo.mostRecentRiskyContactDay(closeContactRiskThreshold: -1))
  }

  func testMostRecentContactDay_onCodableExposureInfo_whenAllBelowThreshold_returnsNil() throws {
    let mockDay = CalendarDay(year: 2020, month: 10, day: 30)
    let exposureInfo: [CodableExposureInfo] = [
      .mock(date: mockDay.byAdding(days: -1).utcDateAtBeginningOfTheDay, totalRiskScore: 0),
      .mock(date: mockDay.byAdding(days: -2).utcDateAtBeginningOfTheDay, totalRiskScore: 1),
      .mock(date: mockDay.byAdding(days: -3).utcDateAtBeginningOfTheDay, totalRiskScore: 2)
    ]
    XCTAssertNil(exposureInfo.mostRecentRiskyContactDay(closeContactRiskThreshold: 3))
  }

  func testMostRecentContactDay_onCodableExposureInfo_whenOneEqualToThreshold_returnsCorrectDay() throws {
    let mockDay = CalendarDay(year: 2020, month: 10, day: 30)
    let exposureInfo: [CodableExposureInfo] = [
      .mock(date: mockDay.byAdding(days: -1).utcDateAtBeginningOfTheDay, totalRiskScore: 0),
      .mock(date: mockDay.byAdding(days: -2).utcDateAtBeginningOfTheDay, totalRiskScore: 2),
      .mock(date: mockDay.byAdding(days: -3).utcDateAtBeginningOfTheDay, totalRiskScore: 1)
    ]

    let expected = mockDay.byAdding(days: -2)
    let got = exposureInfo.mostRecentRiskyContactDay(closeContactRiskThreshold: 2)
    XCTAssertEqual(got, expected)
  }

  func testMostRecentContactDay_onCodableExposureInfo_whenMultipleAboveThreshold_returnsMostRecentDay() throws {
    let mockDay = CalendarDay(year: 2020, month: 10, day: 30)
    let exposureInfo: [CodableExposureInfo] = [
      .mock(date: mockDay.byAdding(days: -1).utcDateAtBeginningOfTheDay, totalRiskScore: 0),
      .mock(date: mockDay.byAdding(days: -2).utcDateAtBeginningOfTheDay, totalRiskScore: 2),
      .mock(date: mockDay.byAdding(days: -3).utcDateAtBeginningOfTheDay, totalRiskScore: 1)
    ]

    let expected = mockDay.byAdding(days: -1)
    let got = exposureInfo.mostRecentRiskyContactDay(closeContactRiskThreshold: 0)
    XCTAssertEqual(got, expected)
  }

  // MARK: - ExposureInfo

  func testMostRecentContactDay_onExposureInfo_whenEmpty_returnsNil() throws {
    let exposureInfo: [ExposureInfo] = []
    XCTAssertNil(exposureInfo.mostRecentRiskyContactDay(closeContactRiskThreshold: -1))
  }

  func testMostRecentContactDay_onExposureInfo_whenAllBelowThreshold_returnsNil() throws {
    let mockDay = CalendarDay(year: 2020, month: 10, day: 30)
    let exposureInfo: [ExposureInfo] = [
      MockExposureInfo.mock(date: mockDay.byAdding(days: -1).utcDateAtBeginningOfTheDay, totalRiskScore: 0),
      MockExposureInfo.mock(date: mockDay.byAdding(days: -2).utcDateAtBeginningOfTheDay, totalRiskScore: 1),
      MockExposureInfo.mock(date: mockDay.byAdding(days: -3).utcDateAtBeginningOfTheDay, totalRiskScore: 2)
    ]
    XCTAssertNil(exposureInfo.mostRecentRiskyContactDay(closeContactRiskThreshold: 3))
  }

  func testMostRecentContactDay_onExposureInfo_whenOneEqualToThreshold_returnsCorrectDay() throws {
    let mockDay = CalendarDay(year: 2020, month: 10, day: 30)
    let exposureInfo: [ExposureInfo] = [
      MockExposureInfo.mock(date: mockDay.byAdding(days: -1).utcDateAtBeginningOfTheDay, totalRiskScore: 0),
      MockExposureInfo.mock(date: mockDay.byAdding(days: -2).utcDateAtBeginningOfTheDay, totalRiskScore: 2),
      MockExposureInfo.mock(date: mockDay.byAdding(days: -3).utcDateAtBeginningOfTheDay, totalRiskScore: 1)
    ]

    let expected = mockDay.byAdding(days: -2)
    let got = exposureInfo.mostRecentRiskyContactDay(closeContactRiskThreshold: 2)
    XCTAssertEqual(got, expected)
  }

  func testMostRecentContactDay_onExposureInfo_whenMultipleAboveThreshold_returnsMostRecentDay() throws {
    let mockDay = CalendarDay(year: 2020, month: 10, day: 30)
    let exposureInfo: [ExposureInfo] = [
      MockExposureInfo.mock(date: mockDay.byAdding(days: -1).utcDateAtBeginningOfTheDay, totalRiskScore: 0),
      MockExposureInfo.mock(date: mockDay.byAdding(days: -2).utcDateAtBeginningOfTheDay, totalRiskScore: 2),
      MockExposureInfo.mock(date: mockDay.byAdding(days: -3).utcDateAtBeginningOfTheDay, totalRiskScore: 1)
    ]

    let expected = mockDay.byAdding(days: -1)
    let got = exposureInfo.mostRecentRiskyContactDay(closeContactRiskThreshold: 0)
    XCTAssertEqual(got, expected)
  }
}
