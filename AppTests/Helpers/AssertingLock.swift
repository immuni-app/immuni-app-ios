// AssertingLock.swift
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
import XCTest

/// Implementation of the `NSLocking` protocol that throws `XCTFail` instead of blocking on a lock. It can be used to test if
/// pieces of code are being called in mutual exclusion.
class AssertingLock: NSLocking {
  private static let queue = DispatchQueue(label: "immuni.asserting_lock")

  /// Whether the lock has been acquired or not
  var isLocked = false

  /// Tries to acquire the lock. If it's already been acquired, it immediately throws an `XCTFail`
  func lock() {
    Self.queue.sync {
      guard !self.isLocked else {
        XCTFail("Trying to lock a locked lock")
        return
      }

      self.isLocked = true
    }
  }

  /// Tries to release the lock. If it's already been released, it immediately throws an `XCTFail`
  func unlock() {
    Self.queue.sync {
      guard self.isLocked else {
        XCTFail("Trying to unlock an unlocked lock")
        return
      }

      self.isLocked = false
    }
  }
}
