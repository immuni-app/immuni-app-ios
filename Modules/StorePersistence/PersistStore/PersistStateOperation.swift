// PersistStateOperation.swift
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
import Foundation

/// Generic async operation boilerplate operation
///
/// It must be subclassed and the `run` method should be implemented
class PersistStateOperation<S: Encodable>: Operation {
  private let encryptionKey: SymmetricKey
  private let storage: PersistStoreInterceptorStorage
  private var katanaState: S

  enum State: String {
    case ready = "isReady"
    case executing = "isExecuting"
    case finished = "isFinished"

    var keyPath: String { return self.rawValue }
  }

  override var isAsynchronous: Bool {
    return true
  }

  override var isExecuting: Bool {
    return self.state == .executing
  }

  override var isFinished: Bool {
    return self.state == .finished
  }

  var state = State.ready {
    willSet {
      willChangeValue(forKey: self.state.keyPath)
      willChangeValue(forKey: newValue.keyPath)
    }

    didSet {
      didChangeValue(forKey: oldValue.keyPath)
      didChangeValue(forKey: self.state.keyPath)
    }
  }

  init(state: S, encryptionKey: SymmetricKey, storage: PersistStoreInterceptorStorage) {
    self.katanaState = state
    self.encryptionKey = encryptionKey
    self.storage = storage
  }

  override func start() {
    guard !self.isCancelled else {
      self.state = .finished
      return
    }

    self.state = .executing
    self.main()
  }

  override func main() {
    defer {
      self.state = .finished
    }

    if self.isCancelled {
      return
    }

    let encoder = JSONEncoder()
    let nonce = AES.GCM.Nonce.random()

    guard
      let data = try? encoder.encode(self.katanaState),
      let box = try? AES.GCM.seal(data, using: self.encryptionKey, nonce: nonce),
      let encryptedData = box.combined
    else {
      // we want to have the app crash here if something is wrong
      LibLogger.fatalError("Cannot seal state")
    }

    if self.isCancelled {
      return
    }

    self.storage.persistState(encryptedData.base64EncodedString(), for: interceptorStorageKey)
  }
}
