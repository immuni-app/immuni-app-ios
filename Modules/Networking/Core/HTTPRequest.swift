// HTTPRequest.swift
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

/// Namespace for HTTPRequest default values
public enum HTTPRequestDefaults {
  /// The default cache policy used in by HTTPRequest. The value is `.useProtocolCachePolicy`
  public static let cachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy

  /// The default timeout interval used by HTTPRequest. The value is `20`
  public static let timeoutInterval: TimeInterval = 20
}

/// HTTPRequest represents an HTTP network call.
/// The core idea is that a request is represented entirely by this protocol, and the NetworkManager just contains
/// the logic to execute it.
/// The request conforms to the `URLRequestConvertible` protocol by Alamofire, and it allows
/// to get the URLRequest, that the Foundation executes, just by calling `asURLRequest`.
///
/// Typically the HTTPRequest protocol is used together with other protocols. Instead of creating a single struct that implements
/// everything is required by HTTPRequest, the library promotes the composition of different protocols that carry
/// different pieces of the data that are used to create the request.
/// NetworkManager cointains different protocols that provide default implementation of behaviours.
/// For example the `JSONRequest` can be used to serialize a request with a JSON payload
public protocol HTTPRequest: URLRequestConvertible {
  /// The serialized used to serialize the response returned by the backend.
  associatedtype ResponseSerializer: Alamofire.ResponseSerializer

  /// The HTTP method of the API call
  var method: HTTPMethod { get }

  /// The base URL of the API call
  var baseURL: URL { get }

  /// The path of the API call
  var path: String { get }

  /// The cache policy of the request
  var cachePolicy: NSURLRequest.CachePolicy { get }

  /// The timeout interval of the request
  var timeoutInterval: TimeInterval { get }

  /// The headers of the request
  var headers: [HTTPHeader] { get }

  /// The parameters of the API request. Parameters are generic for the request, how they are serialized
  /// in the URLRequest is decided by the parametersEncoding variable. They can be serialized as JSON body,
  /// as headers or anything else, really.
  var parameters: [String: Any] { get }

  /// The parameter serializer. It is used to encapsulate the logic to decide how parameters are serialized within
  /// the request
  var parametersEncoder: ParameterEncoding { get }

  /// The serializer of the response. It is used to decide how the response will be serialized.
  var responseSerializer: ResponseSerializer { get }
}

public extension HTTPRequest {
  /// HTTPRequestDefaults.cachePolicy
  var cachePolicy: NSURLRequest.CachePolicy {
    return HTTPRequestDefaults.cachePolicy
  }

  /// HTTPRequestDefaults.timeoutInterval
  var timeoutInterval: TimeInterval {
    return HTTPRequestDefaults.timeoutInterval
  }

  /// An empty array
  var headers: [HTTPHeader] {
    return []
  }

  /// An empty dictionary
  var parameters: [String: Any] {
    return [:]
  }

  /// URL Encoding. See also [Alamofire URLEncoding](https://github.com/Alamofire/Alamofire#parameter-encoding)
  var parametersEncoder: ParameterEncoding {
    return URLEncoding(destination: .methodDependent)
  }

  /// A simple serializer, that just returns the http body of the response as Data
  var responseSerializer: DataResponseSerializer {
    return DataResponseSerializer()
  }
}

public extension HTTPRequest {
  /// Serialize the `HTTPRequest` as an `URLRequest`
  ///
  /// - throws: The method rethrow errors that are raised by serializer that are involved in the process
  ///
  /// - returns: a value of `URLRequest` with all the fields that are speficied in the `HTTPRequest`
  ///
  /// - seeAlso: [Alamofire Documentation](https://github.com/Alamofire/Alamofire#custom-encoding)
  func asURLRequest() throws -> URLRequest {
    let url = self.baseURL.appendingPathComponent(self.path)

    // base request
    var request = URLRequest(url: url, cachePolicy: self.cachePolicy, timeoutInterval: self.timeoutInterval)
    request.httpMethod = self.method.rawValue

    // add headers
    for httpHeader in self.headers {
      request.addValue(httpHeader.value, forHTTPHeaderField: httpHeader.name)
    }

    // add params
    request = try self.parametersEncoder.encode(request, with: self.parameters)

    // return the enriched request
    return request
  }
}
