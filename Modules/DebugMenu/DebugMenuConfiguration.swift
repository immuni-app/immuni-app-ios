// DebugMenuConfiguration.swift
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

/// Configuration provider for `DebugMenu`.
public protocol DebugMenuConfigurationProvider: AnyObject {
  /// The window on which the menu is shown
  var window: UIWindow { get }

  /// The store dispatch function of the app.
  /// Will be used for dispatching state updates and side effects from the menu.
  var dispatch: AnyDispatch { get }

  /// The getState for the Katana store.
  var getState: () -> State { get }

  /// Items, shown when the menu is visible
  func items(state: State) -> [DebugMenuItem]

  /// The application's bundle
  var bundle: Bundle { get }

  /// The debug menu instance.
  var debugMenu: DebugMenu { get }
}

// MARK: - Utilities

extension DebugMenuConfigurationProvider {
  /// Whether the window is currently presenting a Debug Menu.
  /// Call it from main thread.
  var isPresentingDebugMenu: Bool {
    return self.window.topViewController is DebugMenuViewController
      || self.window.topViewController is StateExplorerTableController
  }
}

// MARK: - Default values

public extension DebugMenuConfigurationProvider {
  var window: UIWindow {
    guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
      LibLogger.fatalError("""
      [DebugMenu]: Cannot find the key window.
      [DebugMenu]: You are likely instantiating the dependency container
                    (and DebugMenu) before calling window.makeKeyAndVisible()
                    in your AppDelegate.
      """)
    }

    return keyWindow
  }
}
