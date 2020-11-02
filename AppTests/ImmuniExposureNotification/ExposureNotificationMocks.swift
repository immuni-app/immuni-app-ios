// ExposureNotificationMocks.swift
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

// MARK: - ExposureNotificationProvider

class MockExposureNotificationProvider: ExposureNotificationProvider {
  var overriddenStatus: ExposureNotificationStatus

  init(overriddenStatus: ExposureNotificationStatus = .unknown) {
    self.overriddenStatus = overriddenStatus
  }

  var activateMethodCalls = 0
  // swiftlint:disable:next identifier_name
  var setExposureNotificationEnabledMethodCalls: [Bool] = []
  var detectExposuresMethodCalls: [(ExposureDetectionConfiguration, [URL])] = []
  var getExposureInfoMethodCalls: [(ExposureDetectionSummaryData, String)] = []
  var getDiagnosisKeysMethodCalls = 0
  var deactivateMethodCalls = 0

  var status: ExposureNotificationStatus { return self.overriddenStatus }

  func activate() -> Promise<Void> {
    self.activateMethodCalls += 1
    return .init(resolved: ())
  }

  func setExposureNotificationEnabled(_ enabled: Bool) -> Promise<Void> {
    self.setExposureNotificationEnabledMethodCalls.append(enabled)
    return .init(resolved: ())
  }

  func detectExposures(
    configuration: ExposureDetectionConfiguration,
    diagnosisKeyURLs: [URL]
  ) -> Promise<ExposureDetectionSummary> {
    self.detectExposuresMethodCalls.append((configuration, diagnosisKeyURLs))
    return .init(resolved: .noMatch)
  }

  func getExposureInfo(from summary: ExposureDetectionSummaryData, userExplanation: String) -> Promise<[ExposureInfo]> {
    self.getExposureInfoMethodCalls.append((summary, userExplanation))
    return .init(resolved: [])
  }

  func getDiagnosisKeys() -> Promise<[TemporaryExposureKey]> {
    self.getDiagnosisKeysMethodCalls += 1
    return .init(resolved: [])
  }

  func deactivate() -> Promise<Void> {
    self.deactivateMethodCalls += 1
    return .init(resolved: ())
  }
}

// MARK: - TemporaryExposureKey URLs

struct MockTemporaryExposureKey: TemporaryExposureKey {
  var keyData: Data
  var rollingPeriod: UInt32
  var rollingStartNumber: UInt32
  var transmissionRisk: RiskLevel

  static func mock() -> Self {
    return .init(
      keyData: .randomData(with: 128),
      rollingPeriod: .random(in: 0 ... 100),
      rollingStartNumber: .random(in: 0 ... 100),
      transmissionRisk: .medium
    )
  }
}

extension URL {
  static func mockTemporaryExposureKeyUrls(_ count: Int) -> [URL] {
    return (0 ..< count).compactMap { index in
      URL(string: "https://example.com/\(index)")
    }
  }
}

// MARK: - ExposureDetectionConfiguration

struct MockExposureDetectionConfiguration: ExposureDetectionConfiguration, Equatable {
  var attenuationBucketScores: [RiskScore]
  var attenuationWeight: Double
  var daysSinceLastExposureBucketScores: [RiskScore]
  var daysSinceLastExposureWeight: Double
  var durationBucketScores: [RiskScore]
  var durationWeight: Double
  var transmissionRiskBucketScores: [RiskScore]
  var transmissionRiskWeight: Double
  var minimumRiskScore: RiskScore
  var attenuationThresholds: [Int]

  static func mock() -> Self {
    return MockExposureDetectionConfiguration(
      attenuationBucketScores: [1, 2, 3, 4, 5, 6, 7, 8],
      attenuationWeight: 1,
      daysSinceLastExposureBucketScores: [1, 2, 3, 4, 5, 6, 7, 8],
      daysSinceLastExposureWeight: 1,
      durationBucketScores: [1, 2, 3, 4, 5, 6, 7, 8],
      durationWeight: 1,
      transmissionRiskBucketScores: [1, 2, 3, 4, 5, 6, 7, 8],
      transmissionRiskWeight: 1,
      minimumRiskScore: 0,
      attenuationThresholds: [50, 70]
    )
  }
}

// MARK: - ExposureDetectionSummaryData

struct MockExposureDetectionSummaryData: ExposureDetectionSummaryData, Equatable {
  var durationByAttenuationBucket: [TimeInterval]
  var daysSinceLastExposure: Int
  var matchedKeyCount: UInt64
  var maximumRiskScore: RiskScore
  // swiftlint:disable:next discouraged_optional_collection
  var metadata: [AnyHashable: Any]?

  static func mock() -> Self {
    return MockExposureDetectionSummaryData(
      durationByAttenuationBucket: [300, 600],
      daysSinceLastExposure: 3,
      matchedKeyCount: 4,
      maximumRiskScore: 6,
      metadata: nil
    )
  }

  /// Ignore metadata because it might not be equatable
  static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.durationByAttenuationBucket == rhs.durationByAttenuationBucket
      && lhs.daysSinceLastExposure == rhs.daysSinceLastExposure
      && lhs.matchedKeyCount == rhs.matchedKeyCount
      && lhs.maximumRiskScore == rhs.maximumRiskScore
  }
}

// MARK: - ExposureInfo

struct MockExposureInfo: ExposureInfo, Equatable {
  var attenuationValue: UInt8
  var durationByAttenuationBucket: [TimeInterval]
  var date: Date
  var duration: TimeInterval
  var transmissionRisk: RiskLevel
  var totalRiskScore: RiskScore
  // swiftlint:disable:next discouraged_optional_collection
  var metadata: [AnyHashable: Any]?

  static func mock(
    attenuationValue: UInt8 = 5,
    durationByAttenuationBucket: [TimeInterval] = [300, 600, 300],
    date: Date = Date(),
    duration: TimeInterval = 300,
    transmissionRisk: RiskLevel = .high,
    totalRiskScore: RiskScore = 100,
    metadata: [AnyHashable: Any]? = nil
  ) -> Self {
    return MockExposureInfo(
      attenuationValue: attenuationValue,
      durationByAttenuationBucket: durationByAttenuationBucket,
      date: date,
      duration: duration,
      transmissionRisk: transmissionRisk,
      totalRiskScore: totalRiskScore,
      metadata: metadata
    )
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.attenuationValue == rhs.attenuationValue
      && lhs.date == rhs.date
      && lhs.duration == rhs.duration
      && lhs.transmissionRisk == rhs.transmissionRisk
      && lhs.totalRiskScore == rhs.totalRiskScore
  }
}

// MARK: - TemporaryExposureKeyProvider

class MockTemporaryExposureKeyProvider: TemporaryExposureKeyProvider {
  var indexesToReturn: [Int]

  var getLatestKeyChunksMethodCalls: [Int?] = []
  var clearLocalResourcesMethodCalls: [[TemporaryExposureKeyChunk]] = []

  init(urlsToReturn: Int) {
    self.indexesToReturn = Array(0 ..< urlsToReturn)
  }

  init(minIndexToReturn: Int, maxIndexToReturn: Int) {
    self.indexesToReturn = Array(minIndexToReturn ... maxIndexToReturn)
  }

  func getLatestKeyChunks(
    latestKnownChunkIndex: Int?,
    country: Country?,
    isFirstFlow: Bool?
  ) -> Promise<[TemporaryExposureKeyChunk]> {
    self.getLatestKeyChunksMethodCalls.append(latestKnownChunkIndex)
    // swiftlint:disable force_unwrapping
    return .init(
      resolved: self.indexesToReturn
        .map { .init(localUrls: [URL(string: "http://example.com/\($0)")!], index: $0) }
    )
    // swiftlint:enable force_unwrapping
  }

  func clearLocalResources(for chunks: [TemporaryExposureKeyChunk]) -> Promise<Void> {
    self.clearLocalResourcesMethodCalls.append(chunks)
    return .init(resolved: ())
  }
}

// MARK: - ExposureDetectionExecutor

class MockExposureDetectionExecutor: ExposureDetectionExecutor {
  let outcome: ExposureDetectionOutcome

  var executeMethodCalls = 0
  var detectionPeriods: [TimeInterval] = []

  init(outcome: ExposureDetectionOutcome = .noDetectionNecessary) {
    self.outcome = outcome
  }

  func execute(
    exposureDetectionPeriod: TimeInterval,
    lastExposureDetectionDate: Date?,
    latestProcessedKeyChunkIndex: Int?,
    exposureDetectionConfiguration: Configuration.ExposureDetectionConfiguration,
    exposureInfoRiskScoreThreshold: Int,
    userExplanationMessage: String,
    enManager: ExposureNotificationManager,
    tekProvider: TemporaryExposureKeyProvider,
    now: @escaping () -> Date,
    isUserCovidPositive: Bool,
    forceRun: Bool,
    countriesOfInterest: [CountryOfInterest]
  ) -> Promise<ExposureDetectionOutcome> {
    self.executeMethodCalls += 1
    self.detectionPeriods.append(exposureDetectionPeriod)
    return .init(resolved: self.outcome)
  }
}
