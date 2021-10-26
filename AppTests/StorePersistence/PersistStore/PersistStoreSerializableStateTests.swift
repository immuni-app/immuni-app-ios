// PersistStoreSerializableStateTests.swift
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

final class PersistStoreSerializableStateTests: XCTestCase {
  var fakeStorage: FakeStorage!
  var dispatch: AnyDispatch!
  var next: StoreInterceptorNext!
  let encryptionKey = SymmetricKey(size: .bits256)

  override func setUp() {
    super.setUp()

    self.fakeStorage = FakeStorage()
    self.dispatch = { _ in Promise(resolved: ()) }
    self.next = { _ in }
  }

  override func tearDown() {
    super.tearDown()

    self.fakeStorage = nil
    self.dispatch = nil
    self.next = nil
  }

  func testInvokesNext() throws {
    let interceptor = PersistStore<SerializableState>(
      storage: self.fakeStorage,
      encryptionKey: self.encryptionKey,
      currentBuildVersion: 0
    ).katanaInterceptor

    var invoked = false

    let sideEffectContext = MockSideEffectContext(getState: { SerializableState(value: 1) }, dispatch: self.dispatch)

    try! interceptor(sideEffectContext)({ _ in invoked = true })(AnAction())

    XCTAssertTrue(invoked)
  }

  func testSavesValues() throws {
    let interceptor = PersistStore<SerializableState>(
      storage: fakeStorage,
      encryptionKey: encryptionKey,
      currentBuildVersion: 0
    ).katanaInterceptor

    let sideEffectContext = MockSideEffectContext(getState: { SerializableState(value: 10) }, dispatch: self.dispatch)

    try! interceptor(sideEffectContext)(self.next)(AnAction())

    expectToEventually(self.fakeStorage.states.count == 1, "", 5)

    expectToEventually(
      self.fakeStorage.states[interceptorStorageKey]?.first?
        .persistStoreDecrypted(with: self.encryptionKey)["value"] as? Int == 10,
      "",
      5
    )
  }

  func testSavesValuesEfficiently() throws {
    self.fakeStorage.delayOperation = true

    let interceptor = PersistStore<SerializableState>(
      storage: fakeStorage,
      encryptionKey: encryptionKey,
      currentBuildVersion: 0
    ).katanaInterceptor

    var counter = 1

    let getState: () -> State = {
      SerializableState(value: counter)
    }

    let sideEffectContext = MockSideEffectContext(getState: getState, dispatch: self.dispatch)

    let initializedInterceptor = interceptor(sideEffectContext)(self.next)
    try! initializedInterceptor(AnAction())

    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
      // give time to the interceptor to store the first dispatchable
      for index in 2 ... 10 {
        counter = index
        try! initializedInterceptor(AnAction())
      }
    }

    expectToEventually(
      self.fakeStorage.states[interceptorStorageKey]?.last?
        .persistStoreDecrypted(with: self.encryptionKey)["value"] as? Int == 10,
      "",
      5
    )
    expectToEventually(self.fakeStorage.states[interceptorStorageKey]?.count == 2, "", 5)
  }

  func testRespectsCodableImplementation() throws {
    let interceptor = PersistStore<ComplexPartialState>(
      storage: fakeStorage,
      encryptionKey: encryptionKey,
      currentBuildVersion: 0
    ).katanaInterceptor

    let getState = {
      ComplexPartialState(value: 100, aString: "A weird string")
    }

    let sideEffectContext = MockSideEffectContext(getState: getState, dispatch: self.dispatch)
    try! interceptor(sideEffectContext)(self.next)(AnAction())

    expectToEventually(self.fakeStorage.states.count == 1, "", 5)

    // if the following is true, it means that `aString` is never added to the store
    let expected = ["value": 100]

    expectToEventually(
      self.fakeStorage.states[interceptorStorageKey]?.first?
        .persistStoreDecrypted(with: self.encryptionKey) as? [String: Int] == expected,
      "",
      5
    )
  }
}
