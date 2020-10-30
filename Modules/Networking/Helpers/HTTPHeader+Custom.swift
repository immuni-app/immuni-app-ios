// HTTPHeader+Custom.swift
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

public extension HTTPHeader {
  /// Returns an `Exp-Dummy-Data` header.
  static func dummyData(_ value: Bool) -> HTTPHeader {
    // Convert bool to int to ensure that the packet sizes are always the same.
    let intValue = value ? 1 : 0
    return HTTPHeader(name: "Immuni-Dummy-Data", value: String(intValue))
  }

  /// Returns a `Exp-Client-Clock` header.
  static func clientClock(_ value: Date) -> HTTPHeader {
    HTTPHeader(name: "Immuni-Client-Clock", value: String(value.timeIntervalSince1970.roundedInt()))
  }

  /// Default headers for the Immuni application. These headers will be used across
  /// all the requests and they will contribute in ensuring that the traffic analytis prevention
  /// logic can be implemented correctly
  ///
  /// - seeAlso: https://github.com/immuni-app/immuni-documentation
  static var defaultImmuniHeaders: [HTTPHeader] = [
    .userAgent("Immuni"),
    .acceptLanguage("en-US;q=1.0"),
    .acceptEncoding("br;q=1.0")
  ]
}
