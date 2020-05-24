// MockRequestExecutor.swift
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

// swiftlint:disable superfluous_disable_command force_try implicitly_unwrapped_optional force_unwrapping force_cast

import Foundation
import Hydra
import Networking

class MockRequestExecutor: RequestExecutor {
  var mockedResult: Result<Any, Error>

  var executeMethodCalls: [Any] = []

  init(mockedResult: Result<Any, Error>, delay: TimeInterval = 0) {
    self.mockedResult = mockedResult
  }

  func execute<R: HTTPRequest>(
    _ request: R,
    _ queue: DispatchQueue = .global()
  ) -> Promise<R.ResponseSerializer.SerializedObject> {
    self.executeMethodCalls.append(request)

    switch self.mockedResult {
    case .success(let result):
      return .init(resolved: result as! R.ResponseSerializer.SerializedObject)
    case .failure(let error):
      return .init(rejected: error)
    }
  }
}

class MockSerializingRequestExecutor: RequestExecutor {
  let mockResponseData: Data

  init(mockResponseData: Data) {
    self.mockResponseData = mockResponseData
  }

  func execute<R: HTTPRequest>(_ request: R, _ queue: DispatchQueue) -> Promise<R.ResponseSerializer.SerializedObject> {
    do {
      let response = try request.responseSerializer
        .serialize(request: try request.asURLRequest(), response: nil, data: self.mockResponseData, error: nil)
      return .init(resolved: response)
    } catch {
      return .init(rejected: error)
    }
  }
}
