// PersistStoreMigrationStateChangesTests.swift
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

struct InternalV1: Codable {
  let internalValue: Double
}

struct StateV1: Codable {
  let intVariable: Int
  let complexVariable: InternalV1
}

struct InternalV2: State, Codable {
  let internalValue: Double
  let missingKey: Bool
}

struct StateV2: Codable, State {
  let intVariable: Int
  let stringVariable: String
  let complexVariable: InternalV2
}

extension InternalV1 {
  init() {
    self.internalValue = 99
  }
}

extension StateV1 {
  init() {
    self.intVariable = 16
    self.complexVariable = InternalV1()
  }
}

extension InternalV2 {
  init() {
    self.internalValue = 10.1
    self.missingKey = true
  }
}

extension StateV2 {
  init() {
    self.intVariable = 200
    self.stringVariable = "a migrated value"
    self.complexVariable = InternalV2()
  }
}

final class PersistStoreMigrationStateChangesTests: XCTestCase {
  let encryptionKey = SymmetricKey(size: .bits256)

  func testHandlesMissingValuesWithDefaults() throws {
    let mockMigrationManager = MockMigrationManager<InternalV2>()
    let fakeStorage = FakeStorage()
    var store: Store<InternalV2, EmptySideEffectDependencyContainer>!
    var persistStore: PersistStore<InternalV2>!

    let initStore: ((_ buildNumber: Int) -> Void) = { buildNumber in
      persistStore = PersistStore<InternalV2>(
        storage: fakeStorage,
        encryptionKey: self.encryptionKey,
        currentBuildVersion: buildNumber,
        migrationManager: mockMigrationManager
      )

      store = Store<InternalV2, EmptySideEffectDependencyContainer>(
        interceptors: [persistStore.katanaInterceptor],
        stateInitializer: persistStore.katanaStateInitializer
      )
    }

    let v1State = InternalV1(internalValue: 10.99)
    let v1Data = try! JSONEncoder().encode(v1State)
    let defaultStateV2 = InternalV2()

    let encryptedState = v1Data.persistStoreEncrypted(with: self.encryptionKey)
    fakeStorage.states = [interceptorStorageKey: [encryptedState]]

    initStore(0)

    expectToEventually(store.state.internalValue == v1State.internalValue)
    expectToEventually(store.state.missingKey == defaultStateV2.missingKey)
  }

  func testAutomaticallyHandlesMissingValuesNestedStates() throws {
    let mockMigrationManager = MockMigrationManager<StateV2>()
    let fakeStorage = FakeStorage()
    var store: Store<StateV2, EmptySideEffectDependencyContainer>!
    var persistStore: PersistStore<StateV2>!

    let initStore: ((_ buildNumber: Int) -> Void) = { buildNumber in
      persistStore = PersistStore<StateV2>(
        storage: fakeStorage,
        encryptionKey: self.encryptionKey,
        currentBuildVersion: buildNumber,
        migrationManager: mockMigrationManager
      )

      store = Store<StateV2, EmptySideEffectDependencyContainer>(
        interceptors: [persistStore.katanaInterceptor],
        stateInitializer: persistStore!.katanaStateInitializer
      )
    }

    let v1State = StateV1(intVariable: 96, complexVariable: InternalV1(internalValue: 96.10))
    let v1Data = try! JSONEncoder().encode(v1State)
    let defaultStateV2 = StateV2()

    let encryptedState = v1Data.persistStoreEncrypted(with: self.encryptionKey)
    fakeStorage.states = [interceptorStorageKey: [encryptedState]]

    initStore(0)

    expectToEventually(store.state.intVariable == v1State.intVariable)
    expectToEventually(store.state.stringVariable == defaultStateV2.stringVariable)

    expectToEventually(store.state.complexVariable.internalValue == v1State.complexVariable.internalValue)
    expectToEventually(store.state.complexVariable.missingKey == defaultStateV2.complexVariable.missingKey)
  }
}
