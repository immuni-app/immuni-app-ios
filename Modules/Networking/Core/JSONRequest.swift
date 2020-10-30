// JSONRequest.swift
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

/// A protocol that implements the usage of a JSON serializer for the HTTPRequest parameters.
/// This protocol is meant to be used in composition with other protocols, and not alone.
/// It is worth to mention that the JSON parsing doesn't check the method of the HTTP request and therefore
/// it always serializes the parameters as JSON in the request body. This protocol should be therefore used only
/// for HTTP requests that have a body (e.g., POST)
public protocol JSONRequest: HTTPRequest {
  associatedtype BodyModel: Encodable

  /// The body of the request, which will be encoded in JSON
  var jsonParameter: BodyModel { get }
}

public extension JSONRequest {
  /// Default value is `JSONEncoding.default`
  var parametersEncoder: ParameterEncoding {
    return JSONEncoding.default
  }

  var parameters: [String: Any] {
    do {
      return try JSONSerialization.jsonObject(with: try JSONEncoder().encode(self.jsonParameter)) as? [String: Any]
        ?? LibLogger.fatalError("Unencodable parameters")
    } catch {
      LibLogger.fatalError("\(error.localizedDescription)")
    }
  }
}

/// A protocol that implements the usage of a JSON serializer for network response.
/// This protocol is meant to be used in composition with other protocols, and not alone.
public protocol JSONResponse: HTTPRequest {}
public extension JSONResponse {
  /// Default value is `JSONResponseSerializer`
  var responseSerializer: JSONResponseSerializer {
    return JSONResponseSerializer()
  }
}
