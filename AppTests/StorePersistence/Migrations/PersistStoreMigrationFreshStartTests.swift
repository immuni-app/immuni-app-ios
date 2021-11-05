// PersistStoreMigrationFreshStartTests.swift
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

final class PersistStoreMigrationFreshStartTests: XCTestCase {
  var fakeStorage: FakeStorage!
  var persistStore: PersistStore<MockStateC>!
  var initStore: (() -> Void)!
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

    self.initStore = {
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

  func testDoesNotPerformMigrations() throws {
    var migration1Performed = false
    var migration2Performed = false

    self.mockMigrationManager.migrations = [
      ("migration-1", { _ in migration1Performed = true }),
      ("migration-2", { _ in migration2Performed = true })
    ]

    self.initStore()

    expectToEventually(migration1Performed == false)
    expectToEventually(migration2Performed == false)
  }

  func testMarkMigrationsAsDone() throws {
    self.mockMigrationManager.migrations = [
      ("migration-1", { _ in }),
      ("migration-2", { _ in })
    ]

    XCTAssertFalse(self.fakeStorage.isMigrationPerformed("migration-1"))
    XCTAssertFalse(self.fakeStorage.isMigrationPerformed("migration-2"))

    self.initStore()

    expectToEventually(self.fakeStorage.isMigrationPerformed("migration-1") == true)
    expectToEventually(self.fakeStorage.isMigrationPerformed("migration-2") == true)
  }
}
