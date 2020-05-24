// ExponentialDistributionGeneratorTests.swift
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

@testable import Immuni
import XCTest

final class ExponentialDistributionGeneratorTests: XCTestCase {
  func testAboveOne() {
    let mean = 10.0
    let values = (0 ..< 100_000).map { _ in Double.exponentialRandom(with: mean) }
    let calculatedMean = values.reduce(0, +) / Double(values.count)

    XCTAssertEqual(mean, calculatedMean, accuracy: 0.1)
  }

  func testBelowOne() {
    let mean = 0.5
    let values = (0 ..< 100_000).map { _ in Double.exponentialRandom(with: mean) }
    let calculatedMean = values.reduce(0, +) / Double(values.count)

    XCTAssertEqual(mean, calculatedMean, accuracy: 0.1)
  }
}
