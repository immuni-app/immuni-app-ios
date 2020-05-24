// DeviceTokenGenerator.swift
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

import DeviceCheck
import Foundation
import Hydra

/// A protocol that types that generate a token for the device can adopt.
/// Note that the token should be anonymous, one-time, and must be verifiable using a third-party
/// server
protocol DeviceTokenGenerator {
  func generateToken() -> Promise<Data>
}

/// An error that may occur while generating the token
enum DeviceTokenError: Error {
  /// The current device is not supported
  case notSupported

  /// The token cannot be generated
  case cannotGenerateData(underlyingError: Error)

  /// An unknown error
  case unknownError
}

/// Conformance of `DCDevice` to `DeviceTokenGenerator`.
extension DCDevice: DeviceTokenGenerator {
  func generateToken() -> Promise<Data> {
    return Promise { resolve, reject, _ in
      self.generateToken { data, error in
        if let data = data {
          resolve(data)
        } else if let error = error {
          reject(DeviceTokenError.cannotGenerateData(underlyingError: error))
        } else {
          reject(DeviceTokenError.unknownError)
        }
      }
    }
  }
}

/// A mocked device token generator that is used in the simulator and during testing
struct MockDeviceTokenGenerator: DeviceTokenGenerator {
  let result: Result<String, DeviceTokenError>

  func generateToken() -> Promise<Data> {
    switch self.result {
    case .failure(let err):
      return Promise(rejected: err)

    case .success(let value):
      return Promise(resolved: value.data(using: .utf8) ?? Data())
    }
  }
}
