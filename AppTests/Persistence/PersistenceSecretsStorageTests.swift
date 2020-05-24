// PersistenceSecretsStorageTests.swift
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
import Persistence
import XCTest

private struct Dog: Codable, Equatable {
  let name: String
  let age: Int
}

final class PersistenceSecretsStorageTests: XCTestCase {
  var storage: SecretsStorage!

  override func setUp() {
    super.setUp()

    self.storage = SecretsStorage(bundle: .main)
  }

  override func tearDown() {
    super.tearDown()

    let secItemClasses = [
      kSecClassGenericPassword,
      kSecClassInternetPassword,
      kSecClassCertificate,
      kSecClassKey,
      kSecClassIdentity
    ]

    for secItemClass in secItemClasses {
      let spec = [kSecClass: secItemClass]
      SecItemDelete(spec as CFDictionary)
    }
  }

  func testCanWriteData() throws {
    let data = Data.randomData(with: 10)
    let key = SecretsStorageKey<Data>("key")

    XCTAssertNil(self.storage.get(key: key))

    self.storage.set(data, for: key)
    let retrievedData = self.storage.get(key: key)
    XCTAssert(retrievedData == data)
  }

  func testCanUpdateData() throws {
    let data = Data.randomData(with: 10)
    let data2 = Data.randomData(with: 10)
    let key = SecretsStorageKey<Data>("key")

    XCTAssertNil(self.storage.get(key: key))

    self.storage.set(data, for: key)
    let retrievedData = self.storage.get(key: key)
    XCTAssert(retrievedData == data)

    self.storage.set(data2, for: key)
    let retrievedData2 = self.storage.get(key: key)
    XCTAssert(retrievedData2 == data2)
  }

  func testCanDeleteData() throws {
    let data = Data.randomData(with: 10)
    let key = SecretsStorageKey<Data>("key")

    XCTAssertNil(self.storage.get(key: key))

    self.storage.set(data, for: key)
    let retrievedData = self.storage.get(key: key)
    XCTAssert(retrievedData == data)

    self.storage.delete(key)
    XCTAssertNil(self.storage.get(key: key))
  }

  func testCanWriteString() throws {
    let string = "hello world!"
    let key = SecretsStorageKey<String>("key")

    XCTAssertNil(self.storage.get(key: key))

    self.storage.set(string, for: key)
    let retrievedString = self.storage.get(key: key)
    XCTAssert(retrievedString == string)
  }

  func testCanUpdateString() throws {
    let string = "hello world!"
    let string2 = "another string"
    let key = SecretsStorageKey<String>("key")

    XCTAssertNil(self.storage.get(key: key))

    self.storage.set(string, for: key)
    let retrievedString = self.storage.get(key: key)
    XCTAssert(retrievedString == string)

    self.storage.set(string2, for: key)
    let retrievedString2 = self.storage.get(key: key)
    XCTAssert(retrievedString2 == string2)
  }

  func testCanDeleteString() throws {
    let string = "hello world!"
    let key = SecretsStorageKey<String>("key")

    XCTAssertNil(self.storage.get(key: key))

    self.storage.set(string, for: key)
    let retrievedString = self.storage.get(key: key)
    XCTAssert(retrievedString == string)

    self.storage.delete(key)
    XCTAssertNil(self.storage.get(key: key))
  }

  func testCanWriteCodable() throws {
    let model = Dog(name: "Rex", age: 1)
    let key = SecretsStorageKey<Dog>("key")

    XCTAssertNil(self.storage.get(key: key))

    self.storage.set(model, for: key)
    let retrievedModel = self.storage.get(key: key)
    XCTAssert(retrievedModel == model)
  }

  func testCanUpdateCodable() throws {
    let model = Dog(name: "Rex", age: 1)
    let model2 = Dog(name: "Rex", age: 10)
    let key = SecretsStorageKey<Dog>("key")

    XCTAssertNil(self.storage.get(key: key))

    self.storage.set(model, for: key)
    let retrievedModel = self.storage.get(key: key)
    XCTAssert(retrievedModel == model)

    self.storage.set(model2, for: key)
    let retrievedModel2 = self.storage.get(key: key)
    XCTAssert(retrievedModel2 == model2)
  }

  func testCanDeleteModel() throws {
    let model = Dog(name: "Rex", age: 1)
    let key = SecretsStorageKey<Dog>("key")

    XCTAssertNil(self.storage.get(key: key))

    self.storage.set(model, for: key)
    let retrievedModel = self.storage.get(key: key)
    XCTAssert(retrievedModel == model)

    self.storage.delete(key)
    XCTAssertNil(self.storage.get(key: key))
  }

  func testCanGenerateSymmetricKey() throws {
    let key = SecretsStorageKey<Data>("key")

    XCTAssertNil(self.storage.get(key: key))

    let firstKey = self.storage.getOrCreateSymmetricKey(for: key)
    let secondKey = self.storage.getOrCreateSymmetricKey(for: key)
    XCTAssert(firstKey == secondKey)
  }
}
