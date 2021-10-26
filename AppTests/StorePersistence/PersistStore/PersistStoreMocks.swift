// PersistStoreMocks.swift
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
import Extensions
import Foundation
import Katana
@testable import StorePersistence

class FakeStorage: PersistStoreInterceptorStorage, MigrationLog {
  private var statesLock = os_unfair_lock()

  var states: [String: [String]] = [:]
  var performedMigrations: [MigrationID] = []
  var delayOperation = false

  func persistState(_ state: String, for key: String) {
    if self.delayOperation {
      Thread.sleep(forTimeInterval: 0.5)
    }
    os_unfair_lock_lock(&self.statesLock)
    defer { os_unfair_lock_unlock(&self.statesLock) }

    if var oldValues = self.states[key] {
      oldValues.append(state)
      self.states[key] = oldValues
    } else {
      self.states[key] = [state]
    }
  }

  func getPersistedState(for key: String) -> String? {
    if self.delayOperation {
      Thread.sleep(forTimeInterval: 0.5)
    }

    os_unfair_lock_lock(&self.statesLock)
    defer { os_unfair_lock_unlock(&self.statesLock) }

    if let values = self.states[key] {
      return values.last
    }
    return nil
  }

  public var lastSnapshotKey: String? {
    guard let rawMetadata = self.getPersistedState(for: metadataKey)?.data(using: .utf8) else {
      return nil
    }

    guard let decodedMetadata = try? JSONDecoder().decode(StorageMetadata.self, from: rawMetadata) else {
      return nil
    }

    return self.computeSnapshotKey(for: decodedMetadata.lastStoredVersion)
  }

  public func computeSnapshotKey(for buildVersion: Int) -> String {
    return "\(interceptorStorageKey)_before_\(buildVersion)"
  }

  func markMigrationPerformed(_ migrationName: MigrationID) {
    self.performedMigrations.append(migrationName)
  }

  func isMigrationPerformed(_ migrationName: MigrationID) -> Bool {
    return self.performedMigrations.contains(migrationName)
  }
}

struct SerializableState: State, Equatable, Codable {
  let value: Int

  init() {
    self.value = -1
  }

  init(value: Int) {
    self.value = value
  }
}

struct ComplexPartialState: State, Codable {
  enum CodingKeys: String, CodingKey {
    case value
  }

  var value: Int = 1
  var aString: String = "aString"

  init() {}

  init(value: Int, aString: String) {
    self.value = value
    self.aString = aString
  }
}

struct AnAction: AnyStateUpdater {
  func updatedState(currentState: State) -> State {
    return currentState
  }
}

struct ASideEffect: AnySideEffect {
  func anySideEffect(_ context: AnySideEffectContext) throws -> Any { return () }
}

class PersistStoreInterceptorWithLog<S: State & Codable>: PersistStoreInterceptor<S> {
  var lastSubmittedState: S?

  override func appendPersistOperation(for state: S, encryptionKey: SymmetricKey) {
    self.lastSubmittedState = state
    super.appendPersistOperation(for: state, encryptionKey: encryptionKey)
  }
}
