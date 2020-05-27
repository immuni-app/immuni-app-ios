// DataUploadRequestTests.swift
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
import Models
import Networking
import XCTest

class DataUploadRequestTests: XCTestCase {
  func testTeksAreCappedTo14() throws {
    let teks = (0 ..< 100).map { _ in CodableTemporaryExposureKey.mock() }
    let requestBody = DataUploadRequest.Body(
      teks: teks,
      province: "AA",
      exposureDetectionSummaries: [],
      maximumExposureInfoCount: 0,
      maximumExposureDetectionSummaryCount: 0
    )

    XCTAssertEqual(requestBody.teks.count, 14)
  }

  func testTeksAreSortedByRollingNumberDescending() throws {
    let teks = (0 ..< 100).map { _ in CodableTemporaryExposureKey.mock() }.shuffled()
    let requestBody = DataUploadRequest.Body(
      teks: teks,
      province: "AA",
      exposureDetectionSummaries: [],
      maximumExposureInfoCount: 0,
      maximumExposureDetectionSummaryCount: 0
    )

    for (index, tek) in requestBody.teks.enumerated() {
      guard let nextTek = requestBody.teks[safe: index + 1] else {
        continue
      }

      XCTAssertGreaterThanOrEqual(tek.rollingStartNumber, nextTek.rollingStartNumber)
    }
  }
}
