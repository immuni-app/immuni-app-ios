// Requests.swift
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
import Foundation
import Networking

struct EmptyRequest: HTTPRequest {
  var method: HTTPMethod
  var baseURL: URL
  var path: String
  var cachePolicy: NSURLRequest.CachePolicy
  var timeoutInterval: TimeInterval
  var headers: [HTTPHeader]
  var parameters: [String: Any]
  var parametersEncoder: ParameterEncoding
}

struct TestEndpointRequest: HTTPRequest {
  var baseURL = URL(string: "http://test.com")!
  var timeoutInterval: TimeInterval = HTTPRequestDefaults.timeoutInterval
  var method: HTTPMethod
  var path: String

  init(method: HTTPMethod, path: String) {
    self.method = method
    self.path = path
  }
}

struct ModelRequest: HTTPRequest, ModelResponseSerializer {
  typealias Model = SimpleModel
  var baseURL = URL(string: "http://test.com")!
  var method: HTTPMethod = .get
  var path: String = "/test"
}

struct TestJSONRequest<Body: Encodable>: JSONRequest, JSONResponse {
  var method: HTTPMethod = .post
  var baseURL = URL(string: "http://test.com")!
  var path: String = "/test"
  var jsonParameter: Body
}
