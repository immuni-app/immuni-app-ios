// ValidateAnalyticsTokenRequest.swift
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

import Alamofire
import Foundation

public struct ValidateAnalyticsTokenRequest: JSONRequest {
  public var method: HTTPMethod = .post

  // swiftlint:disable:next force_unwrapping
  public var baseURL = URL(string: "https://analytics.immuni.gov.it")!
  public var path = "/v1/analytics/apple/token"

  public var headers: [HTTPHeader] {
    return HTTPHeader.defaultImmuniHeaders + [
      .contentType("application/json; charset=UTF-8")
    ]
  }

  public var jsonParameter: Body

  public init(analyticsToken: String, deviceToken: Data) {
    self.jsonParameter = Body(analyticsToken: analyticsToken, deviceToken: deviceToken.base64EncodedString())
  }

  // Custom response serialzier
  public var responseSerializer: TokenValidationResponseSerializer {
    return TokenValidationResponseSerializer()
  }
}

public extension ValidateAnalyticsTokenRequest {
  struct Body: Encodable {
    public let analyticsToken: String
    public let deviceToken: String

    enum CodingKeys: String, CodingKey {
      case analyticsToken = "analytics_token"
      case deviceToken = "device_token"
    }
  }
}

// MARK: - Response serialization

public extension ValidateAnalyticsTokenRequest {
  enum ValidationResponse {
    /// The token is already validated by the backend
    case tokenAuthorized

    /// The token validation is in progress
    case authorizationInProgress
  }
}

public extension ValidateAnalyticsTokenRequest {
  /// Custom serializer that looks at the HTTP status code to determine whether the token has already been authorized or is
  /// being processed.
  class TokenValidationResponseSerializer: Alamofire.ResponseSerializer {
    public func serialize(
      request: URLRequest?,
      response: HTTPURLResponse?,
      data: Data?,
      error: Error?
    ) throws -> ValidationResponse {
      if let error = error {
        throw error
      }

      guard let response = response else {
        throw NetworkManager.Error.connectionError
      }

      if response.statusCode == 201 {
        return .tokenAuthorized
      } else if response.statusCode == 202 {
        return .authorizationInProgress
      } else {
        // Actual errors (such as connection errors or 5xx) are already captured in `error`, so this only handles unexpected
        // API responses.
        throw NetworkManager.Error.unknownError
      }
    }
  }
}
