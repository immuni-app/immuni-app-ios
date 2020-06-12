//
//  ImmuniMigrationManager.swift
//  Immuni
//
//  Created by LorDisturbia on 12/06/2020.
//

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

