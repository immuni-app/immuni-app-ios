// DebugMenuMenuItem.swift
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

/// An item shown in the Debug Menu
public struct DebugMenuItem {
  /// The task to perform when the item is picked
  enum Task {
    /// performs a closure
    case perform(() -> Void)

    /// dispatches a `Dispatchable` item
    case dispatchable(Dispatchable)
  }

  /// the title of the item
  var title: String

  /// the task to perform when the item is picked
  var task: Task

  /// Creates an item with the given title and that executes the given closure when picked
  public init(title: String, closure: @escaping () -> Void) {
    self.title = title
    self.task = .perform(closure)
  }

  /// Creates an item with the given title and that dispatches the given `Dispatchable` when picked
  public init(title: String, dispatchable: Dispatchable) {
    self.title = title
    self.task = .dispatchable(dispatchable)
  }
}
