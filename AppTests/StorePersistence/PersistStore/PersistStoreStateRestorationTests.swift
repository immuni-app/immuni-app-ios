// PersistStoreStateRestorationTests.swift
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
import Hydra
import Katana
@testable import StorePersistence
import XCTest

final class PersistStoreStateRestorationTests: XCTestCase {
  var fakeStorage: FakeStorage!
  var dispatch: AnyDispatch!
  var next: StoreInterceptorNext!
  var persistStore: PersistStore<SerializableState>!
  var store: Store<SerializableState, EmptySideEffectDependencyContainer>!
  var initStore: (() -> Void)!
  var mockMigrationManager: MockMigrationManager<SerializableState>!

  let encryptionKey = SymmetricKey(size: .bits256)
  let getState = { ComplexPartialState(value: 100, aString: "A weird string") }

  override func setUp() {
    super.setUp()

    self.fakeStorage = FakeStorage()
    self.dispatch = { _ in Promise(resolved: ()) }
    self.next = { _ in }
    self.mockMigrationManager = MockMigrationManager<SerializableState>()

    self.initStore = {
      self.persistStore = PersistStore<SerializableState>(
        storage: self.fakeStorage,
        encryptionKey: self.encryptionKey,
        currentBuildVersion: 0,
        migrationManager: self.mockMigrationManager
      )

      self.store = Store<SerializableState, EmptySideEffectDependencyContainer>(
        interceptors: [self.persistStore.katanaInterceptor],
        stateInitializer: self.persistStore.katanaStateInitializer
      )
    }
  }

  override func tearDown() {
    super.tearDown()

    self.fakeStorage = nil
    self.dispatch = nil
    self.next = nil
    self.persistStore = nil
    self.store = nil
    self.initStore = nil
    self.mockMigrationManager = nil
  }

  func testRestoresCorrectValue() throws {
    let encryptedState = ["value": 100].persistStoreEncrypted(with: self.encryptionKey)
    self.fakeStorage.states = [interceptorStorageKey: [encryptedState]]

    self.initStore()
    expectToEventually(self.store.state.value == 100)
  }

  func testUsesDefaultValueDuringFirstRun() throws {
    self.initStore()
    expectToEventually(self.store.state == SerializableState())
  }
}
