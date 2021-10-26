// PersistStoreInterceptTests.swift
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

import CryptoKit
import Foundation
import Hydra
import Katana
@testable import StorePersistence
import XCTest

final class PersistStoreInterceptTests: XCTestCase {
  var fakeStorage: FakeStorage!
  var dispatch: AnyDispatch!
  var next: StoreInterceptorNext!
  var persistStoreInterceptor: PersistStoreInterceptorWithLog<ComplexPartialState>!
  var persistStore: PersistStore<ComplexPartialState>!
  var interceptor: StoreInterceptor!

  let encryptionKey = SymmetricKey(size: .bits256)
  let getState = { ComplexPartialState(value: 100, aString: "A weird string") }

  override func setUp() {
    super.setUp()

    self.fakeStorage = FakeStorage()
    self.dispatch = { _ in Promise(resolved: ()) }
    self.next = { _ in }

    self.persistStoreInterceptor = PersistStoreInterceptorWithLog<ComplexPartialState>(
      storage: self.fakeStorage,
      currentBuildVersion: 0
    )

    self.persistStore = PersistStore(
      storage: self.fakeStorage,
      encryptionKey: self.encryptionKey,
      currentBuildVersion: 0,
      persistStoreInterceptor: self.persistStoreInterceptor
    )

    self.interceptor = self.persistStore.katanaInterceptor
  }

  override func tearDown() {
    super.tearDown()

    self.fakeStorage = nil
    self.dispatch = nil
    self.next = nil
    self.persistStoreInterceptor = nil
    self.persistStore = nil
    self.interceptor = nil
  }

  func testSkipsSideEffects() throws {
    let context = MockSideEffectContext(getState: self.getState, dispatch: self.dispatch)
    try! self.interceptor(context)(self.next)(ASideEffect())
    XCTAssertNil(self.persistStoreInterceptor.lastSubmittedState)
  }
}
