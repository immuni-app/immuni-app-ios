// KVStorage.swift
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

/// KVStorage is a wrapper around `UserDefaults`.
/// It provides an handy way to store/retrieve values from
/// `UserDefaults`
open class KVStorage {
  /// The underlying `UserDefaults`
  private let userDefaults: UserDefaults

  /// The key used to encrypt /decrypt the data
  private let encryptionKey: SymmetricKey?

  /**
   Creates a new instance of `KVStorage` backed by the
   given userDefaults

   - parameter userDefaults: the instance of `UserDefaults` where values
                             will be stored/retrieved
   */
  public init(userDefaults: UserDefaults, encryptionKey: SymmetricKey?) {
    self.userDefaults = userDefaults
    self.encryptionKey = encryptionKey
  }
}

public extension KVStorage {
  /**
   Retrieve a codable struct
   - parameter key: the key related to the struct to retrieve
   - returns: the codable struct, if available in the store, nil otherwise
   */
  func get<T>(_ key: KVStorageKey<T>, decoder: JSONDecoder = JSONDecoder()) -> T? where T: Codable {
    guard let data = self.unsafeGet(key) as? Data else {
      return nil
    }

    return try? decoder.decode(T.self, from: data)
  }

  /**
   Store a new struct for the given key
   - parameter value: the struct to store
   - parameter key: the key with which the struct will be associated
   */
  func set<T>(_ value: T, for key: KVStorageKey<T>, encoder: JSONEncoder = JSONEncoder()) where T: Codable {
    guard let data = try? encoder.encode(value) else {
      return
    }

    self.unsafeSet(data, for: key)
  }

  /**
   Remove a codable struct with a given key
   - parameter key: the key which value has to be removed
   */
  func delete<T>(_ key: KVStorageKey<T>) where T: Codable {
    self.userDefaults.removeObject(forKey: key.kvStorageKey)
  }
}

// Any Support
public extension KVStorage {
  /**
   Retrieve a non typed value
   - parameter key: the key related to the value to retrieve
   - returns: the value, if available in the store, nil otherwise

   - warning: this API has been added only to add custom conformance in projects.
              It shouldn't be used for any other case
   */
  func unsafeGet<T>(_ key: KVStorageKey<T>) -> Any? {
    guard let encryptionKey = self.encryptionKey else {
      return self.userDefaults.object(forKey: key.kvStorageKey)
    }

    return self.retrieveAndDecrypt(
      key: key,
      encryptionKey: encryptionKey
    )
  }

  /**
   Store a new value for the given key
   - parameter value: the value to store
   - parameter key: the with which the value will be associated

   - warning: this API has been added only to add custom conformance in projects.
              It shouldn't be used for any other case
   */
  func unsafeSet<T>(_ value: Any, for key: KVStorageKey<T>) {
    guard let encryptionKey = self.encryptionKey else {
      self.userDefaults.set(value, forKey: key.kvStorageKey)
      return
    }

    guard let encryptableData = value as? Data else {
      LibLogger.debug("[KVStorage] UnsafeSet, Cannot encrypt data \(value).")
      self.userDefaults.set(value, forKey: key.kvStorageKey)
      return
    }

    self.encryptAndSet(
      encryptableData,
      for: key,
      encryptionKey: encryptionKey
    )
  }
}

// Helpers to encrypt and decrypt
private extension KVStorage {
  func encryptAndSet<T>(_ data: Data, for key: KVStorageKey<T>, encryptionKey: SymmetricKey) {
    guard
      let box = try? AES.GCM.seal(data, using: encryptionKey),
      let encryptedData = box.combined
    else {
      LibLogger.warning("Cannot store value in userdefaults for key \(key.kvStorageKey)")
      return
    }

    self.userDefaults.set(encryptedData, forKey: key.kvStorageKey)
  }

  func retrieveAndDecrypt<T>(key: KVStorageKey<T>, encryptionKey: SymmetricKey) -> Data? {
    guard
      let combinedData = self.userDefaults.object(forKey: key.kvStorageKey) as? Data,
      let box = try? AES.GCM.SealedBox(combined: combinedData),
      let decryptedData = try? AES.GCM.open(box, using: encryptionKey)

    else {
      LibLogger.debug("[KVStorage] Cannot decrypt data for key \(key.kvStorageKey)")
      return nil
    }

    return decryptedData
  }
}
