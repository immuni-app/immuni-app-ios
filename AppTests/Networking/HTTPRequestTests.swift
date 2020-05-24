// HTTPRequestTests.swift
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

class HTTPRequestTests: XCTestCase {
  func testBaseURLEncoding() throws {
    let request = EmptyRequest(
      method: .get,
      baseURL: URL(string: "http://www.test.com")!,
      path: "/path",
      cachePolicy: .useProtocolCachePolicy,
      timeoutInterval: 100,
      headers: [
        .init(name: "A", value: "1"),
        .init(name: "B", value: "Hello")
      ],
      parameters: [:],
      parametersEncoder: MockParameterEncoding()
    )

    let urlRequest = try! request.asURLRequest()

    XCTAssertEqual(urlRequest.httpMethod, request.method.rawValue)
    XCTAssertEqual(urlRequest.url, request.baseURL.appendingPathComponent(request.path))
    XCTAssertEqual(urlRequest.cachePolicy, request.cachePolicy)
    XCTAssertEqual(urlRequest.timeoutInterval, request.timeoutInterval)

    // headers
    for header in request.headers {
      XCTAssertEqual(urlRequest.allHTTPHeaderFields?[header.name], header.value)
    }
  }

  func testParameterEncodingInvoked() throws {
    var invoked = false
    var invokedParameters: Parameters?
    let passedParams = ["Param1": 1]

    let callback = { (parameters: Parameters?) -> Void in
      invoked = true
      invokedParameters = parameters
    }

    let request = EmptyRequest(
      method: .get,
      baseURL: URL(string: "http://www.test.com")!,
      path: "/path",
      cachePolicy: .useProtocolCachePolicy,
      timeoutInterval: 100,
      headers: [
        .init(name: "A", value: "1"),
        .init(name: "B", value: "Hello")
      ],
      parameters: passedParams,
      parametersEncoder: MockParameterEncoding(invokedCallback: callback)
    )

    _ = try! request.asURLRequest()

    XCTAssert(invoked)

    let castedParams = invokedParameters as? [String: Int]
    XCTAssertNotNil(castedParams)
    XCTAssertEqual(castedParams!, passedParams)
  }

  func testJSONRequest() throws {
    struct TestBody: Encodable {
      let test: Int
    }

    let body = TestBody(test: 10)
    let request = TestJSONRequest(jsonParameter: body)

    let urlRequest = try! request.asURLRequest()

    XCTAssertEqual(urlRequest.httpMethod, request.method.rawValue)
    XCTAssertEqual(urlRequest.url, request.baseURL.appendingPathComponent(request.path))
    XCTAssertEqual(urlRequest.cachePolicy, request.cachePolicy)
    XCTAssertEqual(urlRequest.timeoutInterval, request.timeoutInterval)

    // headers
    for header in request.headers {
      XCTAssert(urlRequest.allHTTPHeaderFields?[header.name] == header.value)
    }

    let expectedBody = try! JSONEncoder().encode(body)
    XCTAssertEqual(urlRequest.httpBody, expectedBody)
  }
}
