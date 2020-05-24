// StringExtensionsTests.swift
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

import CryptoKit
import Foundation
import Hydra
import Persistence
import XCTest

final class StringExtensionsTests: XCTestCase {
  func testSha256IsComputedCorrectly() throws {
    let string = "this is a test"
    let expected = "2e99758548972a8e8822ad47fa1017ff72f06f3ff6a016851f45c398732bc50c"

    XCTAssertEqual(string.sha256, expected)
  }
}
