// FixedSizeJsonRequestTests.swift
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
import Models
import Networking
import XCTest

class FixedSizeJsonRequestTests: XCTestCase {
  func testRequestWithNoBodyAndNoHeadersHasGivenSize() throws {
    let targetSize = 100_000
    let request = try MockEmptyRequest(targetSize: targetSize).asURLRequest()

    XCTAssertEqual(request.size, targetSize)
  }

  func testNumberOfHeadersDoesNotMatter() throws {
    let headers: [HTTPHeader] = [
      .acceptCharset("test"),
      .authorization(bearerToken: "someToken"),
      .userAgent("test3")
    ]

    let targetSize = 100_000
    let request1 = try MockEmptyRequest(targetSize: targetSize, headers: Array(headers.prefix(1))).asURLRequest()
    let request2 = try MockEmptyRequest(targetSize: targetSize, headers: Array(headers.prefix(2))).asURLRequest()
    let request3 = try MockEmptyRequest(targetSize: targetSize, headers: Array(headers.prefix(3))).asURLRequest()

    XCTAssertEqual(request1.size, targetSize)
    XCTAssertEqual(request1.size, request2.size)
    XCTAssertEqual(request1.size, request3.size)
  }

  func testBodyDoesNotMatter() throws {
    let targetSize = 100_000
    let request1 = try MockEmptyRequest(targetSize: targetSize).asURLRequest()
    let request2 = try MockRequest(targetSize: targetSize, body: .init(string: "SomeString", int: 42, array: [true, false]))
      .asURLRequest()
    let request3 = try MockRequest(targetSize: targetSize, body: .init(string: "Some Other String", int: 0, array: []))
      .asURLRequest()

    XCTAssertEqual(request1.size, targetSize)
    XCTAssertEqual(request1.size, request2.size)
    XCTAssertEqual(request1.size, request3.size)
  }

  func testMethodDoesNotMatter() throws {
    let targetSize = 100_000
    let request1 = try MockEmptyRequest(targetSize: targetSize, method: .post).asURLRequest()
    let request2 = try MockEmptyRequest(targetSize: targetSize, method: .connect).asURLRequest()
    let request3 = try MockEmptyRequest(targetSize: targetSize, method: .get).asURLRequest()

    XCTAssertEqual(request1.size, targetSize)
    XCTAssertEqual(request1.size, request2.size)
    XCTAssertEqual(request1.size, request3.size)
  }

  func testBaseURLDoesNotMatter() throws {
    let targetSize = 100_000
    let request1 = try MockEmptyRequest(targetSize: targetSize, baseURL: URL(string: "http://example.com")!).asURLRequest()
    let request2 = try MockEmptyRequest(targetSize: targetSize, baseURL: URL(string: "https://example.com")!).asURLRequest()
    let request3 = try MockEmptyRequest(targetSize: targetSize, baseURL: URL(string: "https://www.example.com")!).asURLRequest()

    XCTAssertEqual(request1.size, targetSize)
    XCTAssertEqual(request1.size, request2.size)
    XCTAssertEqual(request1.size, request3.size)
  }

  func testPathDoesNotMatter() throws {
    let targetSize = 100_000
    let request1 = try MockEmptyRequest(targetSize: targetSize, path: "").asURLRequest()
    let request2 = try MockEmptyRequest(targetSize: targetSize, path: "/some/endpoint").asURLRequest()
    let request3 = try MockEmptyRequest(targetSize: targetSize, path: "/some/other/endpoint?query=1").asURLRequest()

    XCTAssertEqual(request1.size, targetSize)
    XCTAssertEqual(request1.size, request2.size)
    XCTAssertEqual(request1.size, request3.size)
  }

  func testConcreteRequestsHaveSameSize() throws {
    let targetSize = 50000

    let teks = (0 ..< 14).map { _ in CodableTemporaryExposureKey.mock() }
    let summaries = (0 ..< 30).map { _ in CodableExposureDetectionSummary.mock() }

    let request1 = try DataUploadRequest(
      body: .init(
        teks: teks,
        province: "AA",
        exposureDetectionSummaries: summaries,
        maximumExposureInfoCount: 600,
        maximumExposureDetectionSummaryCount: 100,
        countriesOfInterest: []
      ),
      otp: OTP(),
      now: { Date() },
      targetSize: targetSize
    ).asURLRequest()

    let request2 = try OTPValidationRequest(otp: OTP(), now: { Date() }, targetSize: targetSize).asURLRequest()
    let request3 = try DummyIngestionRequest(now: { Date() }, targetSize: targetSize).asURLRequest()

    XCTAssertEqual(request1.size, targetSize)
    XCTAssertEqual(request1.size, request2.size)
    XCTAssertEqual(request1.size, request3.size)
  }
}

// MARK: - Helpers

private extension URLRequest {
  var size: Int {
    let bodySize = self.httpBody?.count ?? 0
    let headersSize = self.headers.map { "\($0.name): \($0.value)\r\n" }.map { $0.data(using: .utf8)?.count ?? 0 }.reduce(0, +)
    let methodSize = self.method?.rawValue.data(using: .utf8)?.count ?? 0
    let urlSize = self.url?.absoluteString.data(using: .utf8)?.count ?? 0
    return bodySize + headersSize + methodSize + urlSize
  }
}

// MARK: - Mocks

extension FixedSizeJsonRequestTests {
  struct MockRequest: FixedSizeJSONRequest {
    typealias BodyModel = Body

    var targetSize: Int
    var method: HTTPMethod
    var baseURL: URL
    var path: String
    var headers: [HTTPHeader]

    let jsonParameter: Body

    init(
      targetSize: Int,
      method: HTTPMethod = .post,
      baseURL: URL = URL(string: "https://example.com")!,
      path: String = "/some/endpoint",
      headers: [HTTPHeader] = [],
      body: Body
    ) {
      self.targetSize = targetSize
      self.method = method
      self.baseURL = baseURL
      self.path = path
      self.headers = headers
      self.jsonParameter = body
    }

    struct Body: Encodable {
      let string: String
      let int: Int
      let array: [Bool]
    }
  }

  struct MockEmptyRequest: FixedSizeJSONRequest {
    typealias BodyModel = EmptyBody

    var targetSize: Int
    var method: HTTPMethod
    var baseURL: URL
    var path: String
    var headers: [HTTPHeader]

    init(
      targetSize: Int,
      method: HTTPMethod = .post,
      baseURL: URL = URL(string: "https://example.com")!,
      path: String = "/some/endpoint",
      headers: [HTTPHeader] = []
    ) {
      self.targetSize = targetSize
      self.method = method
      self.baseURL = baseURL
      self.path = path
      self.headers = headers
    }
  }
}
