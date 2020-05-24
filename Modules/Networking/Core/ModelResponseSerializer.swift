// ModelResponseSerializer.swift
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

/// A protocol that implements the usage of a Model response serializer.
/// This protocol is meant to be used in composition with other protocols, and not alone.
public protocol ModelResponseSerializer: HTTPRequest {
  /// The model in which the response will be serialized into
  associatedtype Model: Decodable

  /// The response serializer
  var responseSerializer: DecodableResponseSerializer<Model> { get }
}

public extension ModelResponseSerializer {
  /// A Response serializer that uses `DecodableResponseSerializer` to serialize the response
  var responseSerializer: DecodableResponseSerializer<Model> {
    return DecodableResponseSerializer<Model>()
  }
}
