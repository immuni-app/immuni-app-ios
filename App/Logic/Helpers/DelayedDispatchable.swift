// DelayedDispatchable.swift
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

/// A wrapper around any `Dispatchable` that dispatches it after a given `delay`
struct DelayedDispatchable: AppSideEffect {
  let dispatchable: Dispatchable
  let delay: TimeInterval

  func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
    Promise<Void>.deferring(of: self.delay)
      .then(in: .background) { _ in context.anyDispatch(self.dispatchable) }
  }
}

extension Dispatchable {
  /// Defer the dispatch of this dispatchable for a given number of seconds
  func deferred(of seconds: TimeInterval) -> Dispatchable {
    return DelayedDispatchable(dispatchable: self, delay: seconds)
  }
}
