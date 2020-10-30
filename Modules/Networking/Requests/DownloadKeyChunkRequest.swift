// DownloadKeyChunkRequest.swift
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

public struct DownloadKeyChunkIndexRequest: HTTPRequest {
  // swiftlint:disable:next force_unwrapping
  public var baseURL = URL(string: "https://get.immuni.gov.it")!
  public var method: HTTPMethod = .get
  public var cachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData
  public var parameters: [String: Any] = [:]
  public var headers: [HTTPHeader] = HTTPHeader.defaultImmuniHeaders

  public var path: String {
    guard let country = self.country else {
      return "/v1/keys/\(self.chunkNumber)"
    }
    return "/v1/keys/eu/\(country.countryId)/\(self.chunkNumber)"
  }

  let chunkNumber: Int
  let country: Country?
}
