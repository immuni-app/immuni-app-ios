// StateInitializer.swift
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

import Foundation
import Katana

class PersistStoreStateInitializer<StateType: CodableState> {
  typealias StateInitializer = PartialStore<StateType>.StateInitializer<StateType>

  private let getLatestStoredState: () -> RawState?
  private let migrationLog: MigrationLog
  private let migrationManager: PersistStoreMigrationManager<StateType>
  private let migrator: DefaultStoreMigrator

  init(
    getLatestStoredState: @escaping () -> RawState?,
    migrationLog: MigrationLog,
    migrationManager: PersistStoreMigrationManager<StateType>
  ) {
    self.getLatestStoredState = getLatestStoredState
    self.migrationLog = migrationLog
    self.migrationManager = migrationManager
    self.migrator = DefaultStoreMigrator(migrationLog: migrationLog)
  }

  var stateInitializer: StateInitializer {
    let migrationManager = self.migrationManager
    let migrator = self.migrator

    return {
      migrationManager.registerMigrations(migrator: migrator)

      // if there is no stored state this is a fresh install,
      // so we can return a new state and mark all migrations as performed
      guard let rawState = self.getLatestStoredState() else {
        migrator.markAllMigrationsPerformed()
        return StateType()
      }

      let (migratedRawState, performedMigrations) = migrator.performMigrations(on: rawState)

      do {
        let decodedState = try self.decode(rawState: migratedRawState, mergeEmptyStateOnError: true)
        migrator.markMigrationsPerformed(performedMigrations)
        return decodedState
      } catch {
        // for Immuni, we don't want to store backups of the state to avoid
        // data retention issues. Therefore, we cannot really recover from this error.
        // Instead of returning an empty state, it's better to crash. It's a bad experience
        // but at least we will notice this issue and users won't lose their data
        LibLogger.fatalError("Cannot recover from this error. Crashing")
      }
    }
  }

  /// Tries to decode the raw state and returns the decoded state
  /// If an error occurs, and `mergeEmptyStateOnError` is true, then the method merges
  /// the missing values, taken from the empty init of the state type and tries again once.
  /// If the method fails again, the error is simply forwarded to the caller
  func decode(rawState: RawState, mergeEmptyStateOnError: Bool) throws -> StateType {
    let jsonData = try JSONSerialization.data(withJSONObject: rawState, options: [])

    do {
      let decodedState = try JSONDecoder().decode(StateType.self, from: jsonData)
      return decodedState
    } catch {
      guard mergeEmptyStateOnError else {
        throw error
      }

      let newRawState = rawState.rawStateByMerging(with: StateType())
      return try self.decode(rawState: newRawState, mergeEmptyStateOnError: false)
    }
  }
}

private extension Dictionary where Key == String, Value == Any {
  /// Merges the raw state with the default values taken from the given state.
  /// Note that this is not full fledged merge but rather a fallback to the
  /// given state values when keys are missing from `self`
  func rawStateByMerging<T: Encodable>(with state: T) -> RawState {
    guard
      let stateData = try? JSONEncoder().encode(state),
      let stateJSON = try? JSONSerialization.jsonObject(with: stateData),
      let typedStateJSON = stateJSON as? [String: Any]
    else {
      return self
    }

    return self.deepMerged(with: typedStateJSON)
  }

  private func deepMerged(with anotherDictionary: [Key: Value]) -> [Key: Value] {
    var merged = self.merging(anotherDictionary, uniquingKeysWith: { current, _ -> Value in
      current
    })

    // deep merge
    for (key, value) in merged {
      guard
        let currValue = value as? [String: Any],
        let anotherValue = anotherDictionary[key] as? [String: Any]

      else {
        continue
      }

      merged[key] = currValue.deepMerged(with: anotherValue)
    }

    return merged
  }
}
