// SecretsStorage.swift
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

/// SecretsStorage is an handy wrapper around KeyChain APIs.
/// It allows to save/retieve/delete data and strings
open class SecretsStorage {
  /// The service that will be used to access the keychain
  private let service: String

  /**
   Creates the SecretsStorage using a Bundle instance.

   - parameter bundle: the application's bundle
   */
  public convenience init(bundle: Bundle) {
    guard let service = bundle.bundleIdentifier else {
      LibLogger.fatalError("Plist should contain a bundle identifier")
    }

    self.init(service: service)
  }

  /**
   Creates the SecretsStorage using a service.
   This parameter should be different in each application (instance) since it will be used to store/retrieve/delete
   information

   - parameter service: The service that will be used
   */
  public init(service: String) {
    self.service = service
  }

  /**
   Set a `Data` value for the given key.

   - parameter data: the data to store
   - parameter key: the key with which the information will be associated
   */
  open func set(_ data: Data, for key: SecretsStorageKey<Data>) {
    objc_sync_enter(self)
    defer {
      objc_sync_exit(self)
    }

    // Checks whether the key is already into the keychain or not
    let shouldAdd = self.get(key: key) == nil

    // Performs the right operation
    if shouldAdd {
      self.add(data, for: key)
    } else {
      self.update(data, for: key)
    }
  }

  /**
   Set a `String` value for the given key.

   - parameter string: the string to store
   - parameter key: the key with which the information will be associated
   */
  open func set(_ string: String, for key: SecretsStorageKey<String>) {
    if let data = string.data(using: .utf8) {
      self.set(data, for: key.dataVersionKey)
    }
  }

  /**
   Set a codable struct for a given key

   - parameter value: the struct to store
   - parameter key: the key with which the information will be associated
   */
  open func set<T>(_ value: T, for key: SecretsStorageKey<T>) where T: Codable {
    guard let data = try? JSONEncoder().encode(value) else {
      return
    }
    self.set(data, for: key.dataVersionKey)
  }

  /**
   Deletes the information associated with the given key
   - parameter key: the key
   */
  open func delete<T>(_ key: SecretsStorageKey<T>) {
    objc_sync_enter(self)
    defer {
      objc_sync_exit(self)
    }

    let query = self.searchDictionary(for: key.secretsStorageKey)

    let result = SecItemDelete(query as CFDictionary)

    guard result == errSecItemNotFound || result == errSecSuccess else {
      LibLogger.fatalError("Keychain query failed")
    }
  }

  /**
   Get a struct that implements Codable for the given key

   - parameter key: the key with which the information is associated
   - returns: the struct found in the secretsStorage
   */
  open func get<T>(key: SecretsStorageKey<T>) -> T? where T: Codable {
    guard let data = get(key: key.dataVersionKey),
          let toRet = try? JSONDecoder().decode(T.self, from: data)
    else {
      return nil
    }
    return toRet
  }

  /**
   Get a `Data` value for the given key.

   - parameter key: the key with which the information is associated
   - returns: the information, if available. Nil othwerwise
   */
  open func get(key: SecretsStorageKey<Data>) -> Data? {
    objc_sync_enter(self)
    defer {
      objc_sync_exit(self)
    }

    var query = self.searchDictionary(for: key.secretsStorageKey)
    query[kSecReturnData as String] = true

    var extractedData: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &extractedData)

    guard status == errSecItemNotFound || status == errSecSuccess else {
      LibLogger.fatalError("Keychain query failed")
    }

    guard status != errSecItemNotFound else {
      LibLogger.debug("SecretsStorage, item for key \(key.secretsStorageKey) not found")
      return nil
    }

    return extractedData as? Data
  }

  /**
   Get a `String` value for the given key.

   - parameter key: the key with which the information is associated
   - returns: the information, if available. Nil othwerwise
   */
  open func get(key: SecretsStorageKey<String>) -> String? {
    guard let data = self.get(key: key.dataVersionKey) else {
      return nil
    }

    return String(data: data, encoding: .utf8)
  }

  /**
   Utility method that returns a dictionary to query the keychain
   - parameter key: the information key in the secret storage
   - returns: the query dictionary
   */
  private func searchDictionary(for key: String) -> [String: Any] {
    let dict: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: self.service,
      kSecAttrAccount as String: key,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
    ]

    return dict
  }

  /**
   Utility method that adds a key into the Keychain if it isn't there already
    - parameter data: the data to store
    - parameter key: the key with which the information will be associated
   */
  private func add(_ data: Data, for key: SecretsStorageKey<Data>) {
    var query = self.searchDictionary(for: key.secretsStorageKey)
    query[kSecValueData as String] = data

    let status = SecItemAdd(query as CFDictionary, nil)

    guard status == errSecDuplicateItem || status == errSecSuccess else {
      LibLogger.fatalError("Keychain query failed")
    }
  }

  /**
   Utility method that updates an existing key into the Keychain
    - parameter data: the data to store
    - parameter key: the key with which the information will be associated
   */
  private func update(_ data: Data, for key: SecretsStorageKey<Data>) {
    let query = self.searchDictionary(for: key.secretsStorageKey)
    let attributesToUpdate = [kSecValueData as String: data]

    let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

    guard status == errSecItemNotFound || status == errSecSuccess else {
      LibLogger.fatalError("Keychain query failed")
    }
  }
}

// MARK: Generation Helpers

public extension SecretsStorage {
  /// Retrieves a symmetric key associated with the given key. In case a symmetric key is not available, is generated
  /// - parameter key: the key associated with the symmetric key
  /// - parameter size: the size of the symmetric key. Note that this must not change across calls
  /// - returns: the symmetric key
  func getOrCreateSymmetricKey(for key: SecretsStorageKey<Data>, size: SymmetricKeySize = .bits256) -> SymmetricKey {
    if let data = self.get(key: key) {
      let symmetricKey = SymmetricKey(data: data)
      assert(symmetricKey.bitCount == size.bitCount)
      return symmetricKey
    }

    let symmetricKey = SymmetricKey(size: size)

    let data = symmetricKey.withUnsafeBytes { pointer in
      Data(pointer)
    }

    self.set(data, for: key)
    return symmetricKey
  }
}
