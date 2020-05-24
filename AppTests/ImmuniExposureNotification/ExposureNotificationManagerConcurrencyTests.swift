// ExposureNotificationManagerConcurrencyTests.swift
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
@testable import ImmuniExposureNotification
import XCTest

final class ExposureNotificationManagerConcurrencyTests: XCTestCase {
  func testAnyMethodCallWaitsForActivationFirst() throws {
    let provider = ActivationSpyExposureNotificationProvider()
    let manager = ExposureNotificationManager(provider: provider)

    let promise = all(
      manager.getStatus().void,
      manager.askAuthorizationAndStart().void,
      manager.startIfAuthorized().void,
      manager.getDetectionSummary(
        configuration: MockExposureDetectionConfiguration.mock(),
        diagnosisKeyURLs: URL.mockTemporaryExposureKeyUrls(5)
      ).void,
      manager.getExposureInfo(from: .matches(data: MockExposureDetectionSummaryData.mock()), userExplanation: "asd").void,
      manager.getDiagnosisKeys().void,
      manager.deactivate().void
    )
    promise.run()

    expectToEventually(!promise.isPending, "", 5)
    XCTAssert(provider.activated)
    XCTAssert(provider.otherMethodsCalled)
  }

  func testProviderMethodsAreCalledInMutualExclusion() throws {
    let provider = MutualExclusionSpyExposureNotificationProvider()
    let manager = ExposureNotificationManager(provider: provider)

    var pendingPromises: [Promise<Void>] = []
    for _ in 0 ..< 100 {
      let promise: Promise<Void>
      switch Int.random(in: 0 ... 6) {
      case 0:
        promise = manager.getStatus().void
      case 1:
        promise = manager.askAuthorizationAndStart().void
      case 2:
        promise = manager.startIfAuthorized().void
      case 3:
        promise = manager.getDetectionSummary(configuration: MockExposureDetectionConfiguration.mock(), diagnosisKeyURLs: [])
          .void
      case 4:
        promise = manager.getExposureInfo(
          from: .matches(data: MockExposureDetectionSummaryData.mock()),
          userExplanation: "test"
        ).void
      case 5:
        promise = manager.getDiagnosisKeys().void
      default:
        promise = manager.deactivate().void
      }
      pendingPromises.append(promise)
      promise.run()
    }

    let cumulativePromise = all(pendingPromises)
    cumulativePromise.run()
    expectToEventually(!cumulativePromise.isPending, "", 10)
  }
}

// MARK: - Test-specific mocks

extension ExposureNotificationManagerConcurrencyTests {
  /// Mock of `ExposureNotificationProvider` that has a particularly slow activation (artificial 2 seconds delay) and asserts that
  /// it has been activated in all other method calls.
  /// It can be used to check whether all methods are synchronized on activation.
  private class ActivationSpyExposureNotificationProvider: ExposureNotificationProvider {
    var activated = false
    var otherMethodsCalled = false

    var status: ExposureNotificationStatus {
      self.otherMethodsCalled = true
      return .unknown
    }

    func activate() -> Promise<Void> {
      return Promise { resolve, _, _ in
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
          self.activated = true
          resolve(())
        }
      }
    }

    func setExposureNotificationEnabled(_ enabled: Bool) -> Promise<Void> {
      return Promise { resolve, _, _ in
        self.otherMethodsCalled = true
        XCTAssert(self.activated)
        resolve(())
      }
    }

    func detectExposures(
      configuration: ExposureDetectionConfiguration,
      diagnosisKeyURLs: [URL]
    ) -> Promise<ExposureDetectionSummary> {
      return Promise { resolve, _, _ in
        self.otherMethodsCalled = true
        XCTAssert(self.activated)
        resolve(.noMatch)
      }
    }

    func getExposureInfo(from summary: ExposureDetectionSummaryData, userExplanation: String) -> Promise<[ExposureInfo]> {
      return Promise { resolve, _, _ in
        self.otherMethodsCalled = true
        XCTAssert(self.activated)
        resolve([])
      }
    }

    func getDiagnosisKeys() -> Promise<[TemporaryExposureKey]> {
      return Promise { resolve, _, _ in
        self.otherMethodsCalled = true
        XCTAssert(self.activated)
        resolve([])
      }
    }

    func deactivate() -> Promise<Void> {
      return Promise { resolve, _, _ in
        self.otherMethodsCalled = true
        XCTAssert(self.activated)
        resolve(())
      }
    }
  }

  /// Mock of `ExposureNotificationProvider` that uses an `AssertingLock` and an artificial delay to check that its method are
  /// being accessed in mutual exclusion, throwing `XCTFail`s otherwise.
  private class MutualExclusionSpyExposureNotificationProvider: ExposureNotificationProvider {
    var lock = AssertingLock()

    var status: ExposureNotificationStatus { return .unknown }

    func activate() -> Promise<Void> {
      return simulateLongOperation(lock: self.lock, returning: ())
    }

    func setExposureNotificationEnabled(_ enabled: Bool) -> Promise<Void> {
      return simulateLongOperation(lock: self.lock, returning: ())
    }

    func detectExposures(
      configuration: ExposureDetectionConfiguration,
      diagnosisKeyURLs: [URL]
    ) -> Promise<ExposureDetectionSummary> {
      return simulateLongOperation(lock: self.lock, returning: .noMatch)
    }

    func getExposureInfo(from summary: ExposureDetectionSummaryData, userExplanation: String) -> Promise<[ExposureInfo]> {
      return simulateLongOperation(lock: self.lock, returning: [])
    }

    func getDiagnosisKeys() -> Promise<[TemporaryExposureKey]> {
      return simulateLongOperation(lock: self.lock, returning: [])
    }

    func deactivate() -> Promise<Void> {
      return simulateLongOperation(lock: self.lock, returning: ())
    }
  }
}

/// Simulates a long operation on a shared `AssertingLock` and returns a promise resolved with predefined value after a random
/// delay.
private func simulateLongOperation<T>(lock: AssertingLock, returning returnValue: T) -> Promise<T> {
  return Promise { resolve, _, _ in
    lock.lock()
    DispatchQueue.global().asyncAfter(deadline: .now() + Double.random(in: 0 ... 0.1)) {
      lock.unlock()
      resolve(returnValue)
    }
  }
}
