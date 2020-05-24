// ExposureNotificationManagerTests.swift
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
@testable import ImmuniExposureNotification
import XCTest

final class ExposureNotificationManagerTests: XCTestCase {
  func testProviderActivateInvoked() throws {
    let provider = MockExposureNotificationProvider()
    _ = ExposureNotificationManager(provider: provider)

    expectToEventually(provider.activateMethodCalls == 1)
  }

  func testSilentStartDoesNotEnableProviderIfNotAuthorized() throws {
    let provider = MockExposureNotificationProvider(overriddenStatus: .notAuthorized)
    let manager = ExposureNotificationManager(provider: provider)

    let promise = manager.startIfAuthorized()
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    XCTAssertNotEqual(provider.setExposureNotificationEnabledMethodCalls.last, true)
  }

  func testSilentStartDoesEnableProviderIfAuthorized() throws {
    let provider = MockExposureNotificationProvider(overriddenStatus: .authorized)
    let manager = ExposureNotificationManager(provider: provider)

    let promise = manager.startIfAuthorized()
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let isEnabled = try XCTUnwrap(provider.setExposureNotificationEnabledMethodCalls.last)
    XCTAssertEqual(isEnabled, true)
  }

  func testExplicitStartStartDoesEnablesProviderIfNotAuthorized() throws {
    let provider = MockExposureNotificationProvider(overriddenStatus: .notAuthorized)
    let manager = ExposureNotificationManager(provider: provider)

    let promise = manager.askAuthorizationAndStart()
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let isEnabled = try XCTUnwrap(provider.setExposureNotificationEnabledMethodCalls.last)
    XCTAssertEqual(isEnabled, true)
  }

  func testExplicitStartStartDoesEnablesProviderIfAuthorized() throws {
    let provider = MockExposureNotificationProvider(overriddenStatus: .authorized)
    let manager = ExposureNotificationManager(provider: provider)

    let promise = manager.askAuthorizationAndStart()
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let isEnabled = try XCTUnwrap(provider.setExposureNotificationEnabledMethodCalls.last)
    XCTAssertEqual(isEnabled, true)
  }

  func testAuthorizationStatusCoincidesWithExposureProviderStatus() throws {
    let provider = MockExposureNotificationProvider()
    let manager = ExposureNotificationManager(provider: provider)

    let possibleStatuses: [ExposureNotificationStatus] = [
      .authorized,
      .authorizedAndActive,
      .authorizedAndInactive,
      .authorizedAndBluetoothOff,
      .unknown,
      .restricted,
      .notAuthorized
    ]

    for status in possibleStatuses {
      provider.overriddenStatus = status
      let promise = manager.getStatus()
      promise.run()
      expectToEventually(!promise.isPending)
      XCTAssertNil(promise.error)
      XCTAssertEqual(promise.result, status)
    }
  }

  func testGetDiagnosisKeysQueriesTheProvider() throws {
    let provider = MockExposureNotificationProvider()
    let manager = ExposureNotificationManager(provider: provider)

    let promise = manager.getDiagnosisKeys()
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    XCTAssertEqual(provider.getDiagnosisKeysMethodCalls, 1)
  }

  func testGetDetectionSummaryPassesAllUrlsToTheProvider() throws {
    let provider = MockExposureNotificationProvider()
    let manager = ExposureNotificationManager(provider: provider)

    let keyUrls = URL.mockTemporaryExposureKeyUrls(10000)
    let promise = manager.getDetectionSummary(
      configuration: MockExposureDetectionConfiguration.mock(),
      diagnosisKeyURLs: keyUrls
    )
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    XCTAssertEqual(provider.detectExposuresMethodCalls.count, 1)
    let (_, relayedUrls) = try XCTUnwrap(provider.detectExposuresMethodCalls.first)
    XCTAssertEqual(relayedUrls, keyUrls)
  }

  func testGetDetectionSummaryPassesTheConfigurationToTheProvider() throws {
    let provider = MockExposureNotificationProvider()
    let manager = ExposureNotificationManager(provider: provider)

    let configuration = MockExposureDetectionConfiguration.mock()
    let promise = manager.getDetectionSummary(
      configuration: configuration,
      diagnosisKeyURLs: []
    )
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    XCTAssertEqual(provider.detectExposuresMethodCalls.count, 1)
    let (relayedConfiguration, _) = try XCTUnwrap(provider.detectExposuresMethodCalls.first)
    try XCTAssertType(relayedConfiguration, MockExposureDetectionConfiguration.self)
    XCTAssertEqual(relayedConfiguration as? MockExposureDetectionConfiguration, configuration)
  }

  func testGetExposureInfoPassesTheSummaryDataToTheProvider() throws {
    let provider = MockExposureNotificationProvider()
    let manager = ExposureNotificationManager(provider: provider)

    let summaryData = MockExposureDetectionSummaryData.mock()
    let promise = manager.getExposureInfo(from: .matches(data: summaryData), userExplanation: "test")
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    XCTAssertEqual(provider.getExposureInfoMethodCalls.count, 1)
    let (relayedSummaryData, _) = try XCTUnwrap(provider.getExposureInfoMethodCalls.first)

    try XCTAssertType(relayedSummaryData, MockExposureDetectionSummaryData.self)
    XCTAssertEqual(relayedSummaryData as? MockExposureDetectionSummaryData, summaryData)
  }

  func testGetExposureInfoReturnsNoElementsForEmptySummaryData() throws {
    let provider = MockExposureNotificationProvider()
    let manager = ExposureNotificationManager(provider: provider)

    let promise = manager.getExposureInfo(from: .noMatch, userExplanation: "test")
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let exposureInfo = try XCTUnwrap(promise.result)
    XCTAssertEqual(exposureInfo.count, 0)
  }

  func testGetExposureInfoPassesTheUserMessageToTheProvider() throws {
    let provider = MockExposureNotificationProvider()
    let manager = ExposureNotificationManager(provider: provider)

    let userMessage = "test"
    let promise = manager
      .getExposureInfo(from: .matches(data: MockExposureDetectionSummaryData.mock()), userExplanation: userMessage)
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    XCTAssertEqual(provider.getExposureInfoMethodCalls.count, 1)
    let (_, relayedUserMessage) = try XCTUnwrap(provider.getExposureInfoMethodCalls.first)
    XCTAssertEqual(relayedUserMessage, userMessage)
  }

  func testDeactivateCallsTheProvider() throws {
    let provider = MockExposureNotificationProvider()
    let manager = ExposureNotificationManager(provider: provider)

    let promise = manager.deactivate()
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    XCTAssertEqual(provider.deactivateMethodCalls, 1)
  }
}
