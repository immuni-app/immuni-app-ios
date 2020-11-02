// DebugMenuDispatchables+Resetters.swift
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

extension DebugMenuActions {
  /// Resets user defaults of the given bundle.
  private static func resetUserDefaults(bundle: Bundle) {
    guard let bundleIdentifier = bundle.bundleIdentifier else { return }
    UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
    UserDefaults.standard.synchronize()
  }

  /// Resets selected classes from keychain.
  private static func resetKeychain() {
    let secItemClasses = [
      kSecClassGenericPassword,
      kSecClassInternetPassword,
      kSecClassCertificate,
      kSecClassKey,
      kSecClassIdentity
    ]

    for secItemClass in secItemClasses {
      let spec = [kSecClass: secItemClass]
      SecItemDelete(spec as CFDictionary)
    }
  }

  private static func emptyDocumentsFolder(fileManager: FileManager) {
    guard
      let docFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
      let items = try? fileManager
      .contentsOfDirectory(at: docFolderURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)

    else {
      return
    }

    for itemURL in items {
      try? fileManager.removeItem(at: itemURL)
    }
  }

  /// Resets the app keychain storage.
  ///
  /// This is conforming to AnyStateUpdater due to its particular purpose:
  ///   making it a state updater blocks the state updaters queue (since it is serial)
  ///   while it is performing.
  /// This prevents other state changing while the keychain reset is ongoing,
  ///   situation that could happen if it would be a side effect.
  public struct ResetKeychain: AnyStateUpdater {
    public init() {}

    public func updatedState(currentState: State) -> State {
      resetKeychain()
      exit(0)
    }
  }

  /// Resets user defaults and keychain storages.
  ///
  /// This is conforming to AnyStateUpdater due to its particular purpose:
  ///   making it a state updater blocks the state updaters queue (since it is serial)
  ///   while it is performing.
  /// This prevents other state changing while the app clean is ongoing,
  ///   situation that could happen if it would be a side effect.
  public struct CleanApp: AnyStateUpdater {
    private let bundle: Bundle
    private let fileManager: FileManager

    public init(bundle: Bundle, fileManager: FileManager) {
      self.bundle = bundle
      self.fileManager = fileManager
    }

    public func updatedState(currentState: State) -> State {
      resetUserDefaults(bundle: self.bundle)
      resetKeychain()
      emptyDocumentsFolder(fileManager: self.fileManager)
      exit(0)
    }
  }
}
