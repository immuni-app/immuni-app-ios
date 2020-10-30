// DataRequest+NetworkManager.swift
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

/// Extension of DataRequest to insert the NetworkManager response serializer
extension DataRequest {
  /// The response manager of the NetworkManager
  ///
  /// - parameter serializer:        the serializer that will be used to serialize the response
  /// - parameter queue:             an optional queue that will be used to perform the network request
  /// - parameter completionHandler: the completion handler that is invoked ath the end of the process
  ///
  /// - returns: an instance of DataRequest
  @discardableResult
  func responseNetworkManager<Serializer: DataResponseSerializerProtocol>(
    serializer: Serializer,
    queue: DispatchQueue = DispatchQueue.global(),
    completionHandler: @escaping (DataResponse<Serializer.SerializedObject, AFError>) -> Void
  )
    -> Self
  {
    return response(
      queue: queue,
      responseSerializer: serializer,
      completionHandler: completionHandler
    )
  }
}
