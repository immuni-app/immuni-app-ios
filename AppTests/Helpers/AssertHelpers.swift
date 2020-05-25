// AssertHelpers.swift
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

// swiftlint:disable superfluous_disable_command force_try implicitly_unwrapped_optional force_unwrapping force_cast

import Foundation
import XCTest

typealias CheckClosure<T> = (T) throws -> Void

/// Asserts that a value is of a given `type` and allows further assertions in a `checkClosure`
func XCTAssertType<T>(_ value: Any?, _ type: T.Type, checkClosure: CheckClosure<T>? = nil) throws {
  let typedValue: T
  do {
    typedValue = try XCTUnwrap(value as? T)
  } catch {
    XCTFail("Type mismatch: expected \(type), got \(Swift.type(of: value))")
    return
  }

  try checkClosure?(typedValue)
}

/// Asserts that an array of values contains exactly one element of a given `type` and allows further assertions in a
/// `checkClosure`
func XCTAssertContainsType<T>(_ array: [Any], _ type: T.Type, checkClosure: CheckClosure<T>? = nil) throws {
  let interestingElements = array.compactMap { $0 as? T }

  XCTAssertLessThan(interestingElements.count, 2)

  let interestingElement: T
  do {
    interestingElement = try XCTUnwrap(interestingElements.first)
  } catch {
    XCTFail("Array does not contain an element of type \(type)")
    return
  }

  try checkClosure?(interestingElement)
}

/// Asserts that an array of value does not contain any element of the given `type`
func XCTAssertNotContainsType<T>(_ array: [Any], _ type: T.Type) throws {
  XCTAssert(!array.contains(where: { $0 is T }))
}

extension XCTestCase {
  /// Allows asynchronous await on a given predicate to become true.
  func expectToEventually(
    _ predicate: @escaping @autoclosure () -> Bool,
    _ description: String = "",
    _ timeout: TimeInterval = 1.0,
    _ file: String = #file,
    _ line: Int = #line
  ) {
    let timeoutExpectation = XCTestExpectation(description: "\(description), \(file):\(line)")
    let timer = DispatchSource.makeTimerSource(queue: .main)
    var done = false

    timer.schedule(deadline: .now(), repeating: .milliseconds(100), leeway: .milliseconds(10))

    timer.setEventHandler {
      if !done && predicate() {
        done = true
        timer.cancel()
        timeoutExpectation.fulfill()
      }
    }

    timer.resume()
    wait(for: [timeoutExpectation], timeout: timeout)
    timer.cancel()
    done = true
  }
}
