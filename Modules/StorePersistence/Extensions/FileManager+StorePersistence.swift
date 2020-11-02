// FileManager+StorePersistence.swift
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

/// Implementation of `PersistStoreInterceptorStorage` for `FileManager`
extension FileManager: PersistStoreInterceptorStorage {
  public func persistState(_ state: String, for key: String) {
    let persistenceFolder = self.persistenceFolderURL()
    let fullURL = persistenceFolder.appendingPathComponent(key, isDirectory: false)
    self.createFile(atPath: fullURL.path, contents: state.data(using: .utf8), attributes: Self.fileAttributes)
  }

  public func getPersistedState(for key: String) -> String? {
    let persistenceFolder = self.persistenceFolderURL()
    let fullURL = persistenceFolder.appendingPathComponent(key, isDirectory: false)
    return self.contents(atPath: fullURL.path).flatMap { String(data: $0, encoding: .utf8) }
  }
}

/// Implementation of `MigrationLog` for `FileManager`
extension FileManager: MigrationLog {
  private static let migrationFileName: String = "persist_store_migrations_performed"

  public func markMigrationPerformed(_ migrationName: MigrationID) {
    let currentModel = self.currentMigrationModel() ?? MigrationsPerformed(migratedKeys: [])
    let newModel = currentModel.byAdding(migratedKey: migrationName)
    let encoder = JSONEncoder()

    guard let data = try? encoder.encode(newModel) else {
      LibLogger.fatalError("Cannot write migration log. This error cannot be recovered")
    }

    self.createFile(atPath: self.migrationFileURL.path, contents: data, attributes: Self.fileAttributes)
  }

  public func isMigrationPerformed(_ migrationName: MigrationID) -> Bool {
    guard let model = self.currentMigrationModel() else {
      return false
    }

    return model.migratedKeys.contains(migrationName)
  }

  private func currentMigrationModel() -> MigrationsPerformed? {
    let decoder = JSONDecoder()

    guard
      let content = self.contents(atPath: self.migrationFileURL.path),
      let model = try? decoder.decode(MigrationsPerformed.self, from: content)

    else {
      return nil
    }

    return model
  }

  var migrationFileURL: URL {
    self.persistenceFolderURL().appendingPathComponent(Self.migrationFileName, isDirectory: false)
  }
}

// MARK: Helpers

extension FileManager {
  private static let statePersistenceFolder: String = "state_persistence"

  private static let fileAttributes: [FileAttributeKey: Any] = [
    .protectionKey: FileProtectionType.completeUntilFirstUserAuthentication
  ]

  func persistenceFolderURL() -> URL {
    /**
     Only documents and other data that is user-generated, or that cannot otherwise be recreated by your application,
     should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud.
     */
    guard let documentsURL = self.urls(for: .documentDirectory, in: .userDomainMask).first else {
      LibLogger.fatalError("Cannot retrieve the document folder, this is a programmatic error")
    }

    let persistenceFolder = documentsURL.appendingPathComponent(Self.statePersistenceFolder, isDirectory: true)

    // create if it doesn't exist
    var isDir: ObjCBool = false

    guard !self.fileExists(atPath: persistenceFolder.path, isDirectory: &isDir) else {
      assert(isDir.boolValue, "\(persistenceFolder.path) should be a folder")
      return persistenceFolder
    }

    do {
      try self
        .createDirectory(at: persistenceFolder, withIntermediateDirectories: true, attributes: Self.fileAttributes)
    } catch {
      // not being able to create a folder is something we cannot recover
      LibLogger.fatalError("State persistence folder cannot be created \(error)")
    }

    return persistenceFolder
  }
}

// MARK: Models

/// Struct used to persist the migrations that have been performed
struct MigrationsPerformed: Codable {
  /// the keys that have been migrated
  let migratedKeys: [String]

  /**
   Create a verison of the struct by adding the passed migrated key
   - parameter migratedKey: the key to add
   */
  func byAdding(migratedKey: String) -> MigrationsPerformed {
    return MigrationsPerformed(migratedKeys: self.migratedKeys + [migratedKey])
  }
}
