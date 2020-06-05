// FixedSizeJSONRequest.swift
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

/// An HTTP Requests with a JSON-represented body.
/// The body has an additional `padding` field that is a random String, the length of which makes it possible for the whole
/// request (including headers, method, and URL) to have a fixed `targetSize`.
/// -seeAlso: https://github.com/immuni-app/immuni-documentation/blob/master/Traffic%20Analysis%20Mitigation.md
public protocol FixedSizeJSONRequest: JSONRequest {
  var targetSize: Int { get }
}

public extension FixedSizeJSONRequest {
  var parametersEncoder: ParameterEncoding {
    return PaddedJSONEncoding(targetSize: self.targetSize)
  }
}

/// A parameter encoding strategy that:
/// - Adds an additional padding parameter so that the total bytes of the request's url, method, headers and body corresponds to
///   the given `targetSize`
/// - Encodes the resulting body in JSON format
///
/// *Note*: this assumes that the communication with the server uses the HTTP/1.1 protocol. Unfortunately there seems to be no
/// way for the client to enforce this, as it's completely handled by iOS.
/// If for some reasons the communication is upgraded to HTTP2 (and this happens automatically if the server allows it), then the
/// headers are compressed with HPACK (https://www.rfc-editor.org/rfc/rfc7541.html) and this makes it impossible to ensure
/// a consistent size among the resulting requests being sent on the wire.
struct PaddedJSONEncoding: ParameterEncoding {
  /// The name of the parameter used for padding
  private static var paddingParameterName: String { "padding" }

  /// The additional overhead caused by adding a field with the given `paddingParameterName`
  private static var paddingParameterOverhead: Int { "\"\(Self.paddingParameterName)\":\"\"".utf8.count }

  /// The target size that this `ParameterEncoding` must guarantee
  var targetSize: Int

  /// Given a dictionary of parameters and a given target size, adds an additional `padding` parameter large enough so it adds
  /// exactly `size` bytes to the JSON representation of the given `parameters`.
  private static func addPadding(to parameters: [String: Any], size: Int) throws -> [String: Any] {
    var paddedParameters = parameters
    let paddingOverhead = parameters.isEmpty
      ? Self.paddingParameterOverhead
      : Self.paddingParameterOverhead + 1 // accounts for the additional "," character

    let paddingSize = size - paddingOverhead

    guard paddingSize >= 0 else {
      /// There is no way of fitting an additional parameter
      throw Error.paddingOverflow
    }

    if paddingSize > 0 {
      paddedParameters[Self.paddingParameterName] = String.random(length: paddingSize)
    }
    return paddedParameters
  }

  /// Note that compared to the implementation of `JSONEncoding` provider by Alamofire, this encoder purposefully avoids adding
  /// the `Content-Type` header, which then must be explicitly added to the request on the application layer.
  func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
    var urlRequest = try urlRequest.asURLRequest()

    let urlSize = urlRequest.url?.byteCount ?? 0
    let methodSize = urlRequest.method?.byteCount ?? 0
    let headersSize = urlRequest.headers.map { $0.byteCount }.reduce(0, +)

    let originalParameters = parameters ?? [:]
    let originalParametersSize = originalParameters.httpRepresentation.byteCount

    let originalRequestSize = urlSize + methodSize + headersSize + originalParametersSize

    let totalPaddingSize = self.targetSize - originalRequestSize
    let paddedParameters = try Self.addPadding(to: originalParameters, size: totalPaddingSize)

    let data = try JSONSerialization.data(withJSONObject: paddedParameters)
    urlRequest.httpBody = data

    return urlRequest
  }

  enum Error: Swift.Error {
    /// The request is already too big.
    case paddingOverflow
  }
}

// MARK: - HTTPRepresentable

/// A protocol that describes something that can be represented with a given String in a raw HTTP/1.1 request
protocol HTTPRepresentable {
  /// The raw representation of the object when encoded in an HTTP/1.1 request
  var httpRepresentation: String { get }
}

extension HTTPRepresentable {
  /// The size in bytes of the `httpRepresentation` for this object
  var byteCount: Int {
    return self.httpRepresentation.utf8.count
  }
}

extension Parameters {
  var httpRepresentation: String {
    let data = (try? JSONSerialization.data(withJSONObject: self)) ?? Data()
    return String(data: data, encoding: .utf8) ?? ""
  }
}

extension String: HTTPRepresentable {
  var httpRepresentation: String {
    return self
  }
}

extension HTTPMethod: HTTPRepresentable {
  var httpRepresentation: String {
    return self.rawValue.uppercased()
  }
}

extension URL: HTTPRepresentable {
  var httpRepresentation: String {
    return self.absoluteString
  }
}

extension HTTPHeader: HTTPRepresentable {
  var httpRepresentation: String {
    /// This follows the RFC2616 specification for HTTP Headers in HTTP/1.1
    /// https://tools.ietf.org/html/rfc2616#section-4.2
    return "\(self.name): \(self.value)\r\n"
  }
}
