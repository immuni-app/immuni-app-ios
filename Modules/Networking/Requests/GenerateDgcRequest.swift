// GenerateDgcRequest.swift
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
import Models
import Extensions


public struct GenerateDgcRequest: FixedSizeJSONRequest {
    
  // swiftlint:disable:next force_unwrapping
  public var baseURL = URL(string: "https://upload.immuni.gov.it")!
  public var path = "/v1/ingestion/get-dgc"
  public var method: HTTPMethod = .post
  public var cachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData

  public let jsonParameter: Body
  public let now: () -> Date
  public let code: String
  public var targetSize: Int


  public var headers: [HTTPHeader] {
    return HTTPHeader.defaultImmuniHeaders + [
      .authorization(bearerToken: self.code.sha256),
      .contentType("application/json; charset=UTF-8"),
      .dummyData(false),
      .clientClock(self.now())
      ]
    }

  public init(body: Body, code: String, now: @escaping () -> Date, targetSize: Int) {
      self.jsonParameter = body
      self.code = code
      self.now = now
      self.targetSize = targetSize
    }
}

public extension GenerateDgcRequest {
  struct Body: Encodable {
    public let lastHisNumber: String
    public let hisExpiringDate: String
    public let tokenType: String
  
    /// Create a Generate dgc  request body.
    /// A padding is added automatically so that both valid both dummy requests will have the same size.
    public init(
      lastHisNumber: String,
      hisExpiringDate: String,
      tokenType: String
    ) {
        self.lastHisNumber = lastHisNumber
        self.hisExpiringDate = hisExpiringDate
        self.tokenType = tokenType
    }
  }
}

public extension GenerateDgcRequest.Body {
  enum CodingKeys: String, CodingKey {
    case lastHisNumber = "last_his_number"
    case hisExpiringDate = "his_expiring_date"
    case tokenType = "token_type"
    }
}
