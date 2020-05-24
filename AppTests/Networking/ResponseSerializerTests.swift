// ResponseSerializerTests.swift
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

class ResponseSerializerTests: XCTestCase {
  func testSerializableModel() throws {
    let expectedResult = SimpleModel(numRegions: 2000)

    let requestExecutor = MockSerializingRequestExecutor(mockResponseData: expectedResult.encoded())
    let manager = NetworkManager()
    manager.start(with: NetworkManager.Dependencies(requestExecutor: requestExecutor, now: { Date() }))

    let promise = manager.request(ModelRequest())
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    XCTAssertEqual(promise.result, expectedResult)
  }

  func testJsonModel() throws {
    let expectedResult = SimpleModel(numRegions: 2000)
    let encodedResult = try JSONEncoder().encode(expectedResult)

    let requestExecutor = MockSerializingRequestExecutor(mockResponseData: encodedResult)
    let manager = NetworkManager()
    manager.start(with: NetworkManager.Dependencies(requestExecutor: requestExecutor, now: { Date() }))

    struct EmptyBody: Encodable {}
    let promise = manager.request(TestJSONRequest(jsonParameter: EmptyBody()))
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let result = try XCTUnwrap(promise.result)
    let typedResult = try XCTUnwrap(result as? [String: Int])
    XCTAssertEqual(typedResult[SimpleModel.CodingKeys.numRegions.rawValue], expectedResult.numRegions)
  }
}
