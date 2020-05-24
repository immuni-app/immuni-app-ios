// AlamofireRequestExecutor.swift
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
import Hydra

/// Default implementation of RequestExecutor that uses Alamofire.
/// It can be configured with a `SessionProvider` to allow more advanced features such as certificate pinning
public class AlamofireRequestExecutor: RequestExecutor {
  /// The session that is used to execute the requests.
  public let session: Session

  public init(sessionProvider: SessionProvider) {
    self.session = sessionProvider.getSession()
  }

  public func execute<R: HTTPRequest>(_ request: R, _ queue: DispatchQueue) -> Promise<R.ResponseSerializer.SerializedObject> {
    return Promise { resolve, reject, _ in
      self.session
        .request(request)
        .validate()
        .responseNetworkManager(serializer: request.responseSerializer, queue: queue) { response in
          switch response.result {
          case .success(let serializedResponse):
            resolve(serializedResponse)
          case .failure:
            let error = response.networkError ?? NetworkManager.Error.unknownError
            reject(error)
          }
        }
    }
  }
}

/// A protocol for providing an Alamofire Session to an `AlamofireRequestExecutor`
public protocol SessionProvider {
  /// Returns a new `Session`
  /// - seeAlso: [Alamofire session](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#session)
  func getSession() -> Session
}

// MARK: - Helpers

private extension DataResponse {
  /// Tries to extract `NetworkManager.Error` from a `DataResponse`
  var networkError: NetworkManager.Error? {
    guard case .failure = self.result else {
      // The request succeeded. There is no error
      return nil
    }

    guard let data = self.data else {
      // No response body. Treat it as a connection error
      return .connectionError
    }

    guard let apiError = try? JSONDecoder().decode(ApiError.self, from: data) else {
      // Unreadable body. Treat it as a connection error
      return .connectionError
    }

    return apiError.asNetworkError
  }
}
