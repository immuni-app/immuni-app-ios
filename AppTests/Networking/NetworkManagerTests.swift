// NetworkManagerTests.swift
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

import Alamofire
import Networking
import XCTest

class NetworkManagerTests: XCTestCase {
  func testHandlesSuccessfulRequests() throws {
    let request = TestEndpointRequest(method: .get, path: "/path")
    let expectedResult = "result".data(using: .utf8)!

    let requestExecutor = MockRequestExecutor(mockedResult: .success(expectedResult))
    let manager = NetworkManager()
    manager.start(with: NetworkManager.Dependencies(requestExecutor: requestExecutor, now: { Date() }))

    let promise = manager.request(request)
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    XCTAssertEqual(promise.result, expectedResult)
  }

  func testHandlesFailingRequests() throws {
    enum Error: Swift.Error, Equatable {
      case someError
    }

    let request = TestEndpointRequest(method: .get, path: "/path")
    let error = Error.someError

    let requestExecutor = MockRequestExecutor(mockedResult: .failure(error))
    let manager = NetworkManager()
    manager.start(with: NetworkManager.Dependencies(requestExecutor: requestExecutor, now: { Date() }))

    let promise = manager.request(request)
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.result)
    let returnedError = try XCTUnwrap(promise.error)
    let typedError = try XCTUnwrap(returnedError as? Error)
    XCTAssertEqual(typedError, error)
  }
}
