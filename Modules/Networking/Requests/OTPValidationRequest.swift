// OTPValidationRequest.swift
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
import Extensions
import Foundation
import Models

public struct OTPValidationRequest: FixedSizeJSONRequest {
  public typealias BodyModel = EmptyBody

  // swiftlint:disable:next force_unwrapping
  public var baseURL = URL(string: "https://upload.immuni.gov.it")!
  public var path = "/v1/ingestion/check-otp"
  public var method: HTTPMethod = .post
  public var cachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData

  public var headers: [HTTPHeader] {
    return HTTPHeader.defaultImmuniHeaders + [
      .authorization(bearerToken: self.otp.rawValue.sha256),
      .contentType("application/json; charset=UTF-8"),
      .dummyData(false),
      .clientClock(self.now())
    ]
  }

  public let otp: OTP
  public let now: () -> Date
  public var targetSize: Int

  public init(otp: OTP, now: @escaping () -> Date, targetSize: Int) {
    self.otp = otp
    self.now = now
    self.targetSize = targetSize
  }
}
