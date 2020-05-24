// OTPTests.swift
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

final class OTPTests: XCTestCase {
  func testOTPValidation() throws {
    let validOTPs = [
      "9K2RAY8UUQ",
      "UQ776R9A7E",
      "Z6UI7HAFXQ",
      "4K51Q19235",
      "A6HHFALQK1",
      "7WRQXW27EK",
      "A23X28L7F5",
      "I4A7KRXJ43",
      "QL412K779W",
      "6IJ3E7A9QI"
    ]

    for otpCode in validOTPs {
      let otp = OTP(rawValue: otpCode)
      XCTAssertNotNil(otp)
    }
  }

  func testOTPGeneration() throws {
    for _ in 0 ..< 100 {
      let otp = OTP()
      XCTAssertNotNil(OTP(rawValue: otp.rawValue))
    }
  }

  func testOTPShortString() throws {
    XCTAssertNil(OTP(rawValue: "A"))
  }

  func testInvalidCharacters() throws {
    XCTAssertNil(OTP(rawValue: "BCD"))
  }

  func testInvalidCheckDigit() throws {
    XCTAssertNil(OTP(rawValue: "6IJ3E7A9QE"))
  }
}
