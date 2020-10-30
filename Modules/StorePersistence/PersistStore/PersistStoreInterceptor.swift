// PersistStoreInterceptor.swift
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

import CryptoKit
import Extensions
import Foundation
import Katana

/// The key that is used to store/retrieve the raw information for the store
let interceptorStorageKey = "storage_persistence"
let metadataKey = "storage_persistence_metadata"

/// Interceptor for the Katana Store that can be used to serialize/deserialize the
/// state. The only requirement is that the State implements the `Encodable` protocol.
/// See the Teleporter library for further information.
class PersistStoreInterceptor<S: State & Codable> {
  /// The storage that is used to persist/retrieve the state
  let storage: PersistStoreInterceptorStorage

  /// The build version of the app
  let currentBuildVersion: Int

  /// The queue that is used to perform the store operations
  private lazy var queue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    queue.qualityOfService = .utility

    return queue
  }()

  /// Default initializer. It creates an instance of the interceptor that is used to
  /// manage the store/retrieve operations
  ///
  /// - parameter storage: the storage to use
  init(storage: PersistStoreInterceptorStorage, currentBuildVersion: Int) {
    self.storage = storage
    self.currentBuildVersion = currentBuildVersion
  }

  /// Append a new request to persist the store. The method will cancel all previous requests (that have become obsolete due to
  /// this new state
  ///
  /// - parameter state: the state to serialize
  func appendPersistOperation(for state: S, encryptionKey: SymmetricKey) {
    self.appendOperation(
      PersistStateOperation(
        state: state,
        encryptionKey: encryptionKey,
        storage: self.storage
      )
    )
  }

  private func appendOperation(_ operation: Operation) {
    self.queue.cancelAllOperations()
    self.queue.addOperation(operation)
  }

  func retrievePersistedRawState(encryptionKey: SymmetricKey) -> RawState? {
    guard
      let base64String = self.storage.getPersistedState(for: interceptorStorageKey),
      let encryptedData = Data(base64Encoded: base64String),
      let box = try? AES.GCM.SealedBox(combined: encryptedData),
      let data = try? AES.GCM.open(box, using: encryptionKey),
      let rawState = try? JSONSerialization.jsonObject(with: data, options: [])
    else {
      return nil
    }

    return rawState as? RawState
  }
}

struct StorageMetadata: Codable {
  let lastStoredVersion: Int
}
