// PersistStoreMigrationStoredStateTests.swift
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
import Katana
@testable import StorePersistence
import XCTest

final class PersistStoreMigrationStoredStateTests: XCTestCase {
  var fakeStorage: FakeStorage!
  var persistStore: PersistStore<MockStateC>!
  var initStore: ((_ initialState: RawState) -> Void)!
  var mockMigrationManager: MockMigrationManager<MockStateC>!
  var store: Store<MockStateC, EmptySideEffectDependencyContainer>!

  let encryptionKey = SymmetricKey(size: .bits256)

  override func setUp() {
    super.setUp()

    self.mockMigrationManager = MockMigrationManager<MockStateC>()
    self.fakeStorage = FakeStorage()
    self.persistStore = PersistStore<MockStateC>(
      storage: self.fakeStorage,
      encryptionKey: self.encryptionKey,
      currentBuildVersion: 0,
      migrationManager: self.mockMigrationManager
    )

    self.initStore = { initialState in
      let encrypted = initialState.toJSONData().persistStoreEncrypted(with: self.encryptionKey)
      self.fakeStorage.persistState(encrypted, for: interceptorStorageKey)

      self.store = Store<MockStateC, EmptySideEffectDependencyContainer>(
        interceptors: [self.persistStore.katanaInterceptor],
        stateInitializer: self.persistStore.katanaStateInitializer
      )
    }
  }

  override func tearDown() {
    super.tearDown()

    self.fakeStorage = nil
    self.persistStore = nil
    self.initStore = nil
    self.mockMigrationManager = nil
    self.store = nil
  }

  func testPerformsMigrationsInOrder() throws {
    var performOrder = 0

    var migration1PerformedOrder = 0
    var migration2PerformedOrder = 0
    var migration3PerformedOrder = 0

    self.mockMigrationManager.migrations = [
      ("migration-1", { _ in
        performOrder += 1
        migration1PerformedOrder = performOrder
      }),
      ("migration-2", { _ in
        performOrder += 1
        migration2PerformedOrder = performOrder
      }),
      ("migration-3", { _ in
        performOrder += 1
        migration3PerformedOrder = performOrder
      })
    ]

    self.initStore(["c": 1])

    expectToEventually(migration1PerformedOrder == 1)
    expectToEventually(migration2PerformedOrder == 2)
    expectToEventually(migration3PerformedOrder == 3)
  }

  func testDoesNotPerformSameMigrationTwice() throws {
    var performedMigrationsCount = 0

    self.mockMigrationManager.migrations = [
      ("migration-1", { _ in performedMigrationsCount += 1 })
    ]

    // at the first store init the migration is run
    self.initStore(["c": 1])
    expectToEventually(performedMigrationsCount == 1)

    // at the second store init the migration should not be run again
    self.persistStore = PersistStore<MockStateC>(
      storage: self.fakeStorage,
      encryptionKey: self.encryptionKey,
      currentBuildVersion: 0,
      migrationManager: self.mockMigrationManager
    )
    self.initStore(["c": 1])
    expectToEventually(performedMigrationsCount == 1)
  }

  func testPerformsMigrationWhenRenamingVariables() throws {
    let storedState = MockStateA(aVariable: 3) // ["a": 3]
    let finalExpectedState = MockStateC(aVariable: 3) // ["c": 3]

    mockMigrationManager.migrations = [
      ("rename_a_to_c", { rawState in
        rawState["c"] = rawState["a"]
      })
    ]

    self.initStore(storedState.toJSON())
    expectToEventually(self.store.state == finalExpectedState)
  }
}
