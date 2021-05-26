// RetriveDgcRequest.swift
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

public struct RetriveDgcRequest: HTTPRequest {

  // swiftlint:disable:next force_unwrapping
    public var baseURL = URL(string: "http://192.168.1.186:3001")!
//  public var baseURL = URL(string: "https://upload.immuni.gov.it")!
  public var path = "/v1/ingestion/get-dgc"
  public var method: HTTPMethod = .get
  public var cachePolicy: NSURLRequest.CachePolicy = .immuniPolicy

  public let parameters: [String: Any]

  public var headers: [HTTPHeader] {
      return HTTPHeader.defaultImmuniHeaders + [
        .authorization(bearerToken: self.code.sha256)
      ]
    }
    
  public let code: String

  init(tokenType: String, lastHisNumber: String, healthCardDate: String, code: String) {
    self.parameters = [
      "token_typestring": tokenType,
      "health_card_date": healthCardDate,
      "last_his_number" : lastHisNumber
    ]
    self.code = code
  }
}
