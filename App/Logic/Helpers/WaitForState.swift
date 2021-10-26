// WaitForState.swift
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

/// Side effect that can be used to block the execution while waiting for a specific state
struct WaitForState: AppSideEffect {
  let closure: (AppState) throws -> Bool

  func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
    let promise = Promise<Void> { resolve, reject, _ in
      self.checkClosure(context: context, resolve: resolve, reject: reject)
    }

    try Hydra.await(promise)
  }

  private func checkClosure(
    context: SideEffectContext<AppState, AppDependencies>,
    resolve: @escaping Promise<Void>.Resolved,
    reject: @escaping Promise<Void>.Rejector
  ) {
    do {
      if try self.closure(context.getState()) {
        resolve(())
      } else {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
          self.checkClosure(context: context, resolve: resolve, reject: reject)
        }
      }
    } catch {
      reject(error)
    }
  }
}
