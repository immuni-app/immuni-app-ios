// AppMigrationManager.swift
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
import StorePersistence

/// The app's migration manager
class AppMigrationManager: PersistStoreMigrationManager<AppState> {
  override func registerMigrations(migrator: PersistStoreMigrator) {
    super.registerMigrations(migrator: migrator)

    // First migration
    migrator.registerMigration(
      named: "migration_1:add_duration_threshold",
      handler: Migration1.migration
    )
  }
}

/// The namespace for each migration
private extension AppMigrationManager {
  enum Migration1 {}
}

// MARK: - Migration 1

extension AppMigrationManager.Migration1 {
  private static let configurationKey = "configuration"

  static let migration: MigrationHandler = { rawState in
    guard var configuration = rawState[Self.configurationKey] as? RawState else {
      return
    }

    configuration["attenuation_durations_weights"] = [1.0, 1.0, 1.0]
    configuration["attenuation_durations_threshold"] = 0

    rawState[Self.configurationKey] = configuration
  }
}
