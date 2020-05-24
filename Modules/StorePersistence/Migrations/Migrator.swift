// Migrator.swift
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

/// A protocol that can be used to implement a store migrator
public protocol PersistStoreMigrator {
  /// Register a new migration
  /// - parameter named: the name of the migration. It must be unique
  /// - parameter handler: a closure that implements the migration
  func registerMigration(named: MigrationID, handler: @escaping MigrationHandler)

  /// Performs all the migrations on the state
  /// - parameter rawState: the state to migrate
  func performMigrations(on rawState: RawState) -> (RawState, [MigrationID])
}

class DefaultStoreMigrator: PersistStoreMigrator {
  private let migrationLog: MigrationLog
  private var migrations: [(MigrationID, MigrationHandler)] = []

  required init(migrationLog: MigrationLog) {
    self.migrationLog = migrationLog
  }

  func registerMigration(named id: MigrationID, handler: @escaping MigrationHandler) {
    #if DEBUG
      self.checkDuplicateMigration(id)
    #endif

    self.migrations.append((id, handler))
  }

  func performMigrations(on rawState: RawState) -> (RawState, [MigrationID]) {
    var migratedState = rawState

    let migrationsToPerform = self.migrations.filter { migrationID, _ in
      !self.migrationLog.isMigrationPerformed(migrationID)
    }

    for (_, migrationHandler) in migrationsToPerform {
      migrationHandler(&migratedState)
    }

    let performedMigrationIDs = migrationsToPerform.map { $0.0 }

    return (migratedState, performedMigrationIDs)
  }

  func markAllMigrationsPerformed() {
    self.migrations.forEach {
      let migrationName = $0.0
      self.migrationLog.markMigrationPerformed(migrationName)
    }
  }

  func markMigrationsPerformed(_ migrations: [MigrationID]) {
    migrations.forEach {
      self.migrationLog.markMigrationPerformed($0)
    }
  }

  private func checkDuplicateMigration(_ id: MigrationID) {
    let ids = self.migrations.map { $0.0 }
    if ids.contains(id) {
      LibLogger.fatalError("You already registered a migration named \(id)")
    }
  }
}
