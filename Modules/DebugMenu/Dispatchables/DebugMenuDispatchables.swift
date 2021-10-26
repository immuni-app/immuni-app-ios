// DebugMenuDispatchables.swift
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
import Hydra
import Katana

public enum DebugMenuActions {
  /// Presents Debug Menu along with the authorized items.
  public struct ShowDebugMenu: DebugMenuSideEffect {
    public init() {}

    public func sideEffect(_ context: DebugMenuSideEffectContext) throws {
      let debugMenu = context.debugMenuConfiguration.debugMenu
      return debugMenu.presentDebugMenuItems()
    }
  }
}

// MARK: - Error

/// Errors that may arise during the processing of the side effect
enum DebugMenuError: Error {
  /// the side effect context is invalid (e.g.., it doesn't conform to the required protocols)
  case invalidSideEffectContext
}

// MARK: - State Updater

// MARK: - Side Effect Context

/// Helper for the contextes passed to `DebugMenuSideEffect`
public struct DebugMenuSideEffectContext: AnySideEffectContext {
  private let anyContext: AnySideEffectContext

  init?(_ anyContext: AnySideEffectContext) {
    guard anyContext.anyDependencies is DebugMenuConfigurationProvider else { return nil }
    self.anyContext = anyContext
  }

  /// The type-erased dependencies
  public var anyDependencies: SideEffectDependencyContainer {
    return self.anyContext.anyDependencies
  }

  /// The Debug Menu configuration provider
  public var debugMenuConfiguration: DebugMenuConfigurationProvider {
    guard let dependencies = self.anyDependencies as? DebugMenuConfigurationProvider else {
      LibLogger.fatalError("Dependencies must conform to DebugMenuConfigurationProvider")
    }

    return dependencies
  }

  /// Type erasure for the state retrival
  public func getAnyState() -> State {
    return self.anyContext.getAnyState()
  }

  /// Method to dispatch a `Dispatchable`
  public func anyDispatch(_ dispatchable: Dispatchable) -> Promise<Any> {
    return self.anyContext.anyDispatch(dispatchable)
  }
}

// MARK: - Side Effect

/// An helper protocol that simplify writing side effects for Debug Menu.
/// It takes care of abstracting the check of the confermances to the required protocols
public protocol DebugMenuSideEffect: AnySideEffect {
  func sideEffect(_ context: DebugMenuSideEffectContext) throws
}

// Conformance of `DebugMenuSideEffect` to `AnySideEffect`
public extension DebugMenuSideEffect {
  /// Implementation of the `sideEffect` requirement for `AnySideEffectContext`
  func anySideEffect(_ context: AnySideEffectContext) throws -> Any {
    guard let debugMenuContext = DebugMenuSideEffectContext(context) else {
      throw DebugMenuError.invalidSideEffectContext
    }

    try self.sideEffect(debugMenuContext)
    return ()
  }
}
