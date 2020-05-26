// Promise+Utilities.swift
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

public extension Promise {
  /// Crestes a promise starting from a function to wrap
  convenience init(wrapping function: @escaping (@escaping (Value?, Swift.Error?) -> Void) -> Void) {
    self.init { resolve, reject, _ in
      function { result, error in
        guard let result = result else {
          reject(error ?? LibLogger.fatalError("Both value and error cannot be nil"))
          return
        }

        resolve(result)
      }
    }
  }

  /// Creates a promise that defers the chain of the given amount of seconds
  static func deferring(of seconds: TimeInterval) -> Promise<Void> {
    return Promise<Void>(resolved: ()).defer(seconds)
  }

  /// Forces a promise to run even if no other entity is waiting on it.
  @discardableResult
  func run() -> Promise<Value> {
    return self.pass { _ in }
  }

  /// Safer version of `.void` that doesn't run the body of the `.then` in the main thread (which is the default behavior).
  /// This is to avoid having a deadlock if the main thread is `await`ing on a Promise, for instance in tests.
  var safeVoid: Promise<Void> {
    return self.then(in: .background) { _ in }
  }
}

public extension Promise where Value == Void {
  /// Crestes a promise starting from a function to wrap
  convenience init(wrapping function: @escaping (@escaping (Swift.Error?) -> Void) -> Void) {
    self.init { resolve, reject, _ in
      function { error in
        if let error = error {
          reject(error)
          return
        }

        resolve(())
      }
    }
  }
}
