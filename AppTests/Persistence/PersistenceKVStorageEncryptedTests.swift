// PersistenceKVStorageEncryptedTests.swift
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

import CryptoKit
import Foundation
import Persistence
import XCTest

private struct Dog: Codable, Equatable {
  let name: String
  let age: Int
}

private struct Person: Codable, Equatable {
  let name: String
  let age: Int
  let height: Double
  let isMale: Bool
  let dog: Dog?
}

final class PersistenceKVStorageEncryptedTests: XCTestCase {
  var storage: KVStorage!
  var userDefaults: UserDefaults!

  override func setUp() {
    super.setUp()

    self.userDefaults = UserDefaults(suiteName: "com.test")
    self.storage = KVStorage(userDefaults: self.userDefaults, encryptionKey: SymmetricKey(size: .bits256))
  }

  override func tearDown() {
    super.tearDown()

    self.userDefaults.removeSuite(named: "com.test")
    self.userDefaults = nil
    self.storage = nil
  }

  func testCorrectlyPersistCodableStruct() throws {
    let personKey = KVStorageKey<Person>("personKey")
    let model = Person(name: "Ricky", age: 30, height: 1.85, isMale: true, dog: Dog(name: "Rocky", age: 12))

    XCTAssertNil(self.storage.get(personKey))

    self.storage.set(model, for: personKey)
    let retrievedPerson = self.storage.get(personKey)
    XCTAssert(retrievedPerson == model)
  }

  func testCorrectlyOverwriteCodableStruct() throws {
    let personKey = KVStorageKey<Person>("personKey")
    let model = Person(name: "Ricky", age: 30, height: 1.85, isMale: true, dog: Dog(name: "Rocky", age: 12))
    let anotherModel = Person(name: "Luke", age: 30, height: 1.85, isMale: true, dog: Dog(name: "Skywalker", age: 12))

    XCTAssertNil(self.storage.get(personKey))

    self.storage.set(model, for: personKey)
    self.storage.set(anotherModel, for: personKey)
    let retrievedPerson = self.storage.get(personKey)
    XCTAssert(retrievedPerson == anotherModel)
  }

  func testCorrectlyDeletesCodableStruct() throws {
    let personKey = KVStorageKey<Person>("personKey")
    let model = Person(name: "Ricky", age: 30, height: 1.85, isMale: true, dog: Dog(name: "Rocky", age: 12))
    storage.set(model, for: personKey)

    self.storage.delete(personKey)
    let retrievedPerson = self.storage.get(personKey)
    XCTAssertNil(retrievedPerson)
  }
}
