// MockSideEffectContext.swift
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
import Hydra
@testable import Immuni
import Katana

struct MockSideEffectContext: AnySideEffectContext {
  var anyDependencies: SideEffectDependencyContainer

  var getState: GetState
  var dispatch: AnyDispatch

  func getAnyState() -> State {
    return self.getState()
  }

  func anyDispatch(_ dispatchable: Dispatchable) -> Promise<Any> {
    return self.dispatch(dispatchable)
  }

  init(getState: @escaping GetState, dispatch: @escaping AnyDispatch) {
    self.anyDependencies = EmptySideEffectDependencyContainer(dispatch: dispatch, getState: getState)
    self.getState = getState
    self.dispatch = dispatch
  }

  init(with mockAppDependencies: AppDependencies) {
    self.anyDependencies = mockAppDependencies
    self.getState = mockAppDependencies.getState
    self.dispatch = mockAppDependencies.dispatch
  }
}
