// PersistStoreFileManagerTests.swift
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

import Foundation
@testable import StorePersistence
import XCTest

final class PersistStoreFileManagerTests: XCTestCase {
  override func tearDown() {
    super.tearDown()

    let manager = FileManager.default
    try! manager.removeItem(at: manager.persistenceFolderURL())
  }

  func testStateIsCreated() throws {
    let manager = FileManager.default
    let content = "This is a fake state"
    let key = "a_path"

    manager.persistState(content, for: key)

    let retrievedState = manager.contents(atPath: manager.persistenceFolderURL().appendingPathComponent(key).path)

    XCTAssertNotNil(retrievedState)
    XCTAssertEqual(String(data: retrievedState!, encoding: .utf8), content)
  }

  #if !targetEnvironment(simulator)
    // this test is disabled for simulator as the protection keys are not sat there
    func testFilesHaveCorrectAttributes() throws {
      let manager = FileManager.default
      let content = "This is a fake state"
      let key = "a_path"

      manager.persistState(content, for: key)

      let folderAttributes = try! manager.attributesOfItem(atPath: manager.persistenceFolderURL().path)
      XCTAssertEqual(
        folderAttributes[.protectionKey] as? FileProtectionType,
        FileProtectionType.completeUntilFirstUserAuthentication
      )

      let fileAttributes = try! manager.attributesOfItem(atPath: manager.persistenceFolderURL().appendingPathComponent(key).path)
      XCTAssertEqual(
        fileAttributes[.protectionKey] as? FileProtectionType,
        FileProtectionType.completeUntilFirstUserAuthentication
      )
    }
  #endif

  func testRetrivalState() throws {
    let manager = FileManager.default
    let content = "This is a fake state"
    let key = "a_path"
    let filePath = manager.persistenceFolderURL().appendingPathComponent(key).path

    manager.createFile(atPath: filePath, contents: content.data(using: .utf8)!, attributes: nil)

    let state = manager.getPersistedState(for: key)

    XCTAssertEqual(state, content)
  }

  func testAddFirstMigration() throws {
    let manager = FileManager.default
    let migration = "m1"

    manager.markMigrationPerformed(migration)

    let data = manager.contents(atPath: manager.migrationFileURL.path)
    let model = try! JSONDecoder().decode(MigrationsPerformed.self, from: data!)

    XCTAssertTrue(model.migratedKeys == [migration])
  }

  func testAddMigration() throws {
    let manager = FileManager.default
    let migration = "m1"
    let oldMigration = "old"

    let model = MigrationsPerformed(migratedKeys: [oldMigration])
    let data = try! JSONEncoder().encode(model)
    manager.createFile(atPath: manager.migrationFileURL.path, contents: data, attributes: nil)

    manager.markMigrationPerformed(migration)
    let afterMarkData = manager.contents(atPath: manager.migrationFileURL.path)
    let afterMarkModel = try! JSONDecoder().decode(MigrationsPerformed.self, from: afterMarkData!)

    XCTAssertTrue(afterMarkModel.migratedKeys == [oldMigration, migration])
  }

  func testCheckMigration() throws {
    let manager = FileManager.default
    let migration = "m1"

    let model = MigrationsPerformed(migratedKeys: [migration])
    let data = try! JSONEncoder().encode(model)
    manager.createFile(atPath: manager.migrationFileURL.path, contents: data, attributes: nil)

    XCTAssert(manager.isMigrationPerformed(migration))
  }
}
