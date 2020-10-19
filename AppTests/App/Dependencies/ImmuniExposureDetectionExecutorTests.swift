// ImmuniExposureDetectionExecutorTests.swift
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
@testable import Immuni
import ImmuniExposureNotification
import Models
import XCTest

final class ImmuniExposureDetectionExecutorTests: XCTestCase {
  func testExposureDetectionConfigurationIsRelayedToTheExposureNotificationProvider() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let enProvider = MockExposureNotificationProvider(overriddenStatus: .authorizedAndActive)
    let enManager = ExposureNotificationManager(provider: enProvider)

    let exposureConfiguration = Configuration.ExposureDetectionConfiguration(
      attenuationBucketScores: [2, 2, 2, 2, 3, 3, 3, 3],
      attenuationWeight: 1,
      daysSinceLastExposureBucketScores: [3, 3, 3, 3, 5, 5, 5, 5],
      daysSinceLastExposureWeight: 2,
      durationBucketScores: [1, 2, 3, 4, 5, 6, 7, 8],
      durationWeight: 3,
      transmissionRiskBucketScores: [1, 2, 4, 4, 5, 6, 7, 7],
      transmissionRiskWeight: 4,
      minimumRiskScore: 1
    )

    let countriesOfInterest: [CountryOfInterest] = []

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: exposureConfiguration,
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "test",
      enManager: enManager,
      tekProvider: MockTemporaryExposureKeyProvider(urlsToReturn: 1),
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: true,
      countriesOfInterest: countriesOfInterest
    )
    promise.run()
    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)

    let (relayedConfiguration, _) = try XCTUnwrap(enProvider.detectExposuresMethodCalls.first)
    XCTAssertEqual(relayedConfiguration.attenuationBucketScores, exposureConfiguration.attenuationBucketScores)
    XCTAssertEqual(relayedConfiguration.attenuationWeight, exposureConfiguration.attenuationWeight)
    XCTAssertEqual(
      relayedConfiguration.daysSinceLastExposureBucketScores,
      exposureConfiguration.daysSinceLastExposureBucketScores
    )
    XCTAssertEqual(relayedConfiguration.daysSinceLastExposureWeight, exposureConfiguration.daysSinceLastExposureWeight)
    XCTAssertEqual(relayedConfiguration.durationBucketScores, exposureConfiguration.durationBucketScores)
    XCTAssertEqual(relayedConfiguration.durationWeight, exposureConfiguration.durationWeight)
    XCTAssertEqual(relayedConfiguration.transmissionRiskBucketScores, exposureConfiguration.transmissionRiskBucketScores)
    XCTAssertEqual(relayedConfiguration.transmissionRiskWeight, exposureConfiguration.transmissionRiskWeight)
    XCTAssertEqual(relayedConfiguration.minimumRiskScore, exposureConfiguration.minimumRiskScore)
  }

  func testUserExplanationIsCorrectlyRelayedToTheExposureNotificationProvider() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let enProvider = MatchingMockExposureNotificationProvider(overriddenStatus: .authorizedAndActive)
    let enManager = ExposureNotificationManager(provider: enProvider)

    let userExplanation = "user explanation"

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: userExplanation,
      enManager: enManager,
      tekProvider: MockTemporaryExposureKeyProvider(urlsToReturn: 1),
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: true,
      countriesOfInterest: []
    )

    promise.run()
    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)

    let (_, relayedUserExplanation) = try XCTUnwrap(enProvider.getExposureInfoMethodCalls.first)

    XCTAssertEqual(relayedUserExplanation, userExplanation)
  }

  func testIsSkippedIfNotEnoughTimeHasPassed() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let promise = executor.execute(
      exposureDetectionPeriod: 20,
      lastExposureDetectionDate: Date().addingTimeInterval(-10),
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "this is a test",
      enManager: .init(provider: MockExposureNotificationProvider(overriddenStatus: .authorizedAndActive)),
      tekProvider: MockTemporaryExposureKeyProvider(urlsToReturn: 1),
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: false,
      countriesOfInterest: []
    )
    promise.run()
    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let outcome = try XCTUnwrap(promise.result)

    XCTAssertEqual(outcome.rawCase, .noDetectionNecessary)
  }

  func testIsSkippedIfThereAreNoNewKeys() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "this is a test",
      enManager: .init(provider: MockExposureNotificationProvider(overriddenStatus: .authorized)),
      tekProvider: MockTemporaryExposureKeyProvider(urlsToReturn: 0),
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: true,
      countriesOfInterest: []
    )
    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let outcome = try XCTUnwrap(promise.result)

    XCTAssertEqual(outcome.rawCase, .noDetectionNecessary)
  }

  func testFullDetectionPerformedEvenIfNoMatchesWhenForceRun() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "this is a test",
      enManager: .init(provider: NoMatchMockExposureNotificationProvider(overriddenStatus: .authorized)),
      tekProvider: MockTemporaryExposureKeyProvider(urlsToReturn: 1),
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: true,
      countriesOfInterest: []
    )

    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let outcome = try XCTUnwrap(promise.result)

    XCTAssertEqual(outcome.rawCase, .fullDetection)
  }

  func testPartialDetectionPerformedIfNoMatchesWhenNotForceRun() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "this is a test",
      enManager: .init(provider: NoMatchMockExposureNotificationProvider(overriddenStatus: .authorized)),
      tekProvider: MockTemporaryExposureKeyProvider(urlsToReturn: 1),
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: false,
      countriesOfInterest: []
    )

    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let outcome = try XCTUnwrap(promise.result)

    XCTAssertEqual(outcome.rawCase, .partialDetection)
  }

  func testFullDetectionPerformedWhenMatchesWhenForceRun() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "this is a test",
      enManager: .init(provider: MatchingMockExposureNotificationProvider(overriddenStatus: .authorized)),
      tekProvider: MockTemporaryExposureKeyProvider(urlsToReturn: 1),
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: true,
      countriesOfInterest: []
    )

    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let outcome = try XCTUnwrap(promise.result)

    XCTAssertEqual(outcome.rawCase, .fullDetection)
  }

  func testFullDetectionPerformedWhenMatchesEvenWithoutForceRun() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "this is a test",
      enManager: .init(provider: MatchingMockExposureNotificationProvider(overriddenStatus: .authorized)),
      tekProvider: MockTemporaryExposureKeyProvider(urlsToReturn: 1),
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: false,
      countriesOfInterest: []
    )

    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let outcome = try XCTUnwrap(promise.result)

    XCTAssertEqual(outcome.rawCase, .fullDetection)
  }

  func testPartialDetectionPerformedBecauseOfThreshold() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 10, // note: 10 is above the max value (8) in any case
      userExplanationMessage: "this is a test",
      enManager: .init(provider: MatchingMockExposureNotificationProvider(overriddenStatus: .authorized)),
      tekProvider: MockTemporaryExposureKeyProvider(urlsToReturn: 1),
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: false,
      countriesOfInterest: []
    )

    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let outcome = try XCTUnwrap(promise.result)

    XCTAssertEqual(outcome.rawCase, .partialDetection)
  }

  func testLatestProcessedKeyChunkIndexIsRelayedToTheTEKProvider() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let latestProcessedKeyChunk = 42
    let tekProvider = MockTemporaryExposureKeyProvider(urlsToReturn: 1)

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: latestProcessedKeyChunk,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "this is a test",
      enManager: .init(provider: MatchingMockExposureNotificationProvider(overriddenStatus: .authorized)),
      tekProvider: tekProvider,
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: false,
      countriesOfInterest: []
    )

    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)

    let relayedLatestKeyChunk = try XCTUnwrap(tekProvider.getLatestKeyChunksMethodCalls.first)
    XCTAssertEqual(relayedLatestKeyChunk, latestProcessedKeyChunk)
  }

  func testTEKProviderClearResourcesIsCalled() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let tekProvider = MockTemporaryExposureKeyProvider(urlsToReturn: 1)

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "this is a test",
      enManager: .init(provider: MatchingMockExposureNotificationProvider(overriddenStatus: .authorized)),
      tekProvider: tekProvider,
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: true,
      countriesOfInterest: []
    )

    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)

    XCTAssertEqual(tekProvider.clearLocalResourcesMethodCalls.count, 1)
  }

  func testCorrectErrorIsThrownIfUnauthorized() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "this is a test",
      enManager: .init(provider: MatchingMockExposureNotificationProvider(overriddenStatus: .notAuthorized)),
      tekProvider: MockTemporaryExposureKeyProvider(urlsToReturn: 1),
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: false,
      countriesOfInterest: []
    )

    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let outcome = try XCTUnwrap(promise.result)

    let outcomeError = try XCTUnwrap(outcome.error)

    XCTAssertEqual(outcomeError.rawCase, .notAuthorized)
  }

  func testCorrectErrorIsThrownIfTEKThrowsError() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "this is a test",
      enManager: .init(provider: MatchingMockExposureNotificationProvider(overriddenStatus: .authorized)),
      tekProvider: ThrowingMockTemporaryExposureKeyProvider(urlsToReturn: 1),
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: false,
      countriesOfInterest: []
    )

    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let outcome = try XCTUnwrap(promise.result)

    let outcomeError = try XCTUnwrap(outcome.error)

    XCTAssertEqual(outcomeError.rawCase, .unableToRetrieveKeys)
  }

  func testCorrectErrorIsThrownIfDetectExposuresFails() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "this is a test",
      enManager: .init(provider: ThrowingOnDetectExposuresMockExposureNotificationProvider()),
      tekProvider: MockTemporaryExposureKeyProvider(urlsToReturn: 1),
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: false,
      countriesOfInterest: []
    )

    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let outcome = try XCTUnwrap(promise.result)

    let outcomeError = try XCTUnwrap(outcome.error)

    XCTAssertEqual(outcomeError.rawCase, .unableToRetrieveSummary)
  }

  func testCorrectErrorIsThrownIfGetExposureInfoFails() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "this is a test",
      enManager: .init(provider: ThrowingOnGetExposureInfoMockExposureNotificationProvider()),
      tekProvider: MockTemporaryExposureKeyProvider(urlsToReturn: 1),
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: false,
      countriesOfInterest: []
    )

    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let outcome = try XCTUnwrap(promise.result)

    let outcomeError = try XCTUnwrap(outcome.error)

    XCTAssertEqual(outcomeError.rawCase, .unableToRetrieveExposureInfo)
  }

  func testCorrectIndexBoundariesAreReturnedForPartialDetection() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let minIndex = ["IT": 4]
    let maxIndex = ["IT": 6]

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "this is a test",
      enManager: .init(provider: NoMatchMockExposureNotificationProvider(overriddenStatus: .authorized)),
      tekProvider: MockTemporaryExposureKeyProvider(minIndexToReturn: minIndex["IT"]!, maxIndexToReturn: maxIndex["IT"]!),
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: false,
      countriesOfInterest: []
    )

    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let outcome = try XCTUnwrap(promise.result)

    XCTAssertEqual(outcome.rawCase, .partialDetection)

    let (outcomeMinIndex, outcomeMaxIndex) = try XCTUnwrap(outcome.processedChunkBoundaries)
    XCTAssertEqual(outcomeMinIndex, minIndex)
    XCTAssertEqual(outcomeMaxIndex, maxIndex)
  }

  func testCorrectIndexBoundariesAreReturnedForFullDetection() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let minIndex = ["IT": 4]
    let maxIndex = ["IT": 6]

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "this is a test",
      enManager: .init(provider: MatchingMockExposureNotificationProvider(overriddenStatus: .authorized)),
      tekProvider: MockTemporaryExposureKeyProvider(minIndexToReturn: minIndex["IT"]!, maxIndexToReturn: maxIndex["IT"]!),
      now: { Date() },
      isUserCovidPositive: false,
      forceRun: true,
      countriesOfInterest: []
    )

    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let outcome = try XCTUnwrap(promise.result)

    XCTAssertEqual(outcome.rawCase, .fullDetection)

    let (outcomeMinIndex, outcomeMaxIndex) = try XCTUnwrap(outcome.processedChunkBoundaries)
    XCTAssertEqual(outcomeMinIndex, minIndex)
    XCTAssertEqual(outcomeMaxIndex, maxIndex)
  }

  func testPreventFullDetectionWhenPositive() throws {
    let executor = ImmuniExposureDetectionExecutor()

    let minIndex = ["IT": 4]
    let maxIndex = ["IT": 6]

    let promise = executor.execute(
      exposureDetectionPeriod: 0,
      lastExposureDetectionDate: nil,
      latestProcessedKeyChunkIndex: nil,
      exposureDetectionConfiguration: .init(),
      exposureInfoRiskScoreThreshold: 0,
      userExplanationMessage: "this is a test",
      enManager: .init(provider: MatchingMockExposureNotificationProvider(overriddenStatus: .authorized)),
      tekProvider: MockTemporaryExposureKeyProvider(minIndexToReturn: minIndex["IT"]!, maxIndexToReturn: maxIndex["IT"]!),
      now: { Date() },
      isUserCovidPositive: true,
      forceRun: false,
      countriesOfInterest: []
    )

    promise.run()

    expectToEventually(!promise.isPending)
    XCTAssertNil(promise.error)
    let outcome = try XCTUnwrap(promise.result)

    XCTAssertEqual(outcome.rawCase, .partialDetection)

    let (outcomeMinIndex, outcomeMaxIndex) = try XCTUnwrap(outcome.processedChunkBoundaries)
    XCTAssertEqual(outcomeMinIndex, minIndex)
    XCTAssertEqual(outcomeMaxIndex, maxIndex)
  }
}

// MARK: - Private mocks

class NoMatchMockExposureNotificationProvider: MockExposureNotificationProvider {
  override func detectExposures(
    configuration: ExposureDetectionConfiguration,
    diagnosisKeyURLs: [URL]
  ) -> Promise<ExposureDetectionSummary> {
    return .init(resolved: .noMatch)
  }
}

class MatchingMockExposureNotificationProvider: MockExposureNotificationProvider {
  override func detectExposures(
    configuration: ExposureDetectionConfiguration,
    diagnosisKeyURLs: [URL]
  ) -> Promise<ExposureDetectionSummary> {
    return .init(resolved: .matches(data: MockExposureDetectionSummaryData(
      durationByAttenuationBucket: [300, 300, 300],
      daysSinceLastExposure: 0,
      matchedKeyCount: 1,
      maximumRiskScore: 8,
      metadata: nil
    )))
  }
}

class ThrowingMockTemporaryExposureKeyProvider: MockTemporaryExposureKeyProvider {
  override func getLatestKeyChunks(
    latestKnownChunkIndex: Int?,
    country: Country?,
    isFirstFlow: Bool?
  ) -> Promise<[TemporaryExposureKeyChunk]> {
    return .init(rejected: NSError(domain: "Some Error", code: 1, userInfo: nil))
  }
}

class ThrowingOnDetectExposuresMockExposureNotificationProvider: MockExposureNotificationProvider {
  override var status: ExposureNotificationStatus {
    return .authorized
  }

  override func detectExposures(
    configuration: ExposureDetectionConfiguration,
    diagnosisKeyURLs: [URL]
  ) -> Promise<ExposureDetectionSummary> {
    return .init(rejected: NSError(domain: "Some Error", code: 1, userInfo: nil))
  }
}

class ThrowingOnGetExposureInfoMockExposureNotificationProvider: MockExposureNotificationProvider {
  override var status: ExposureNotificationStatus {
    return .authorized
  }

  override func detectExposures(
    configuration: ExposureDetectionConfiguration,
    diagnosisKeyURLs: [URL]
  ) -> Promise<ExposureDetectionSummary> {
    return .init(resolved: .matches(data: MockExposureDetectionSummaryData(
      durationByAttenuationBucket: [300, 300],
      daysSinceLastExposure: 0,
      matchedKeyCount: 2,
      maximumRiskScore: 8,
      metadata: nil
    )))
  }

  override func getExposureInfo(from summary: ExposureDetectionSummaryData, userExplanation: String) -> Promise<[ExposureInfo]> {
    return .init(rejected: NSError(domain: "Some Error", code: 1, userInfo: nil))
  }
}
