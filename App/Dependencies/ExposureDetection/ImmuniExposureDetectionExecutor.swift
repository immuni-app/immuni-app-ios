// ImmuniExposureDetectionExecutor.swift
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

import ExposureNotification
import Extensions
import Foundation
import Hydra
import ImmuniExposureNotification
import Models

class ImmuniExposureDetectionExecutor: ExposureDetectionExecutor {
  /// The queue on which the exposure detection is run
  static let queue = DispatchQueue(label: "immuni.exposure_detection.queue", qos: .background)

  /// Pure function that, given the relevant parts of the `AppState` and the relevant managers, performs a cycle of exposure
  /// detection if necessary, and returns an `Outcome`.
  func execute(
    exposureDetectionPeriod: TimeInterval,
    lastExposureDetectionDate: Date?,
    latestProcessedKeyChunkIndex: Int?,
    exposureDetectionConfiguration: Configuration.ExposureDetectionConfiguration,
    exposureRiskScoreThreshold: Double,
    exposureWeightedDurationThreshold: Double,
    exposureDurationWeightsByAttenuation: [Double],
    userExplanationMessage: String,
    enManager: ExposureNotificationManager,
    tekProvider: TemporaryExposureKeyProvider,
    now: @escaping () -> Date,
    isUserCovidPositive: Bool,
    forceRun: Bool
  ) -> Promise<ExposureDetectionOutcome> {
    return Promise(in: .custom(queue: Self.queue)) { resolve, _, _ in
      guard #available(iOS 13.5, *) else {
        // No exposure detection to perform, ever.
        resolve(.noDetectionNecessary)
        return
      }

      let timeSinceLastDetection = now().timeIntervalSince(lastExposureDetectionDate ?? .distantPast)
      guard forceRun || timeSinceLastDetection >= exposureDetectionPeriod else {
        // Exposure detection was performed recently
        resolve(.noDetectionNecessary)
        return
      }

      // Check for authorization
      let status: ExposureNotificationStatus
      do {
        status = try await(enManager.getStatus())
      } catch {
        resolve(.error(.unableToRetrieveStatus(error)))
        return
      }

      guard status.canPerformDetection else {
        // No authorization
        resolve(.error(.notAuthorized))
        return
      }

      // Download the keys
      let keyChunks: [TemporaryExposureKeyChunk]
      do {
        keyChunks = try await(
          tekProvider
            .getLatestKeyChunks(latestKnownChunkIndex: latestProcessedKeyChunkIndex)
        )
      } catch {
        resolve(.error(.unableToRetrieveKeys(error)))
        return
      }

      defer {
        // Cleanup the local files of the downloaded chunks
        try? await(tekProvider.clearLocalResources(for: keyChunks))
      }

      guard !keyChunks.isEmpty else {
        // No new keys. There is not detection to perform.
        resolve(.noDetectionNecessary)
        return
      }

      let firstProcessedChunk = keyChunks.map { $0.index }.min()
        ?? AppLogger.fatalError("keyChunks cannot be empty at this stage")

      let lastProcessedChunk = keyChunks.map { $0.index }.max()
        ?? AppLogger.fatalError("keyChunks cannot be empty at this stage")

      // Retrieve the summary
      let summary: ExposureDetectionSummary
      do {
        summary = try await(enManager.getDetectionSummary(
          configuration: exposureDetectionConfiguration.toNative(),
          diagnosisKeyURLs: keyChunks.flatMap { $0.localUrls }
        ))
      } catch {
        resolve(.error(.unableToRetrieveSummary(error)))
        return
      }

      let shouldRetrieveInfo = Self.shouldRetrieveExposureInfo(
        summary: summary,
        riskScoreThreshold: exposureRiskScoreThreshold,
        weightedDurationThreshold: exposureWeightedDurationThreshold,
        durationWeightsByAttenuation: exposureDurationWeightsByAttenuation,
        isUserCovidPositive: isUserCovidPositive,
        isForceRun: forceRun
      )

      guard shouldRetrieveInfo else {
        // Stop at the summary
        resolve(.partialDetection(now(), summary, firstProcessedChunk, lastProcessedChunk))
        return
      }

      // Retrieve exposure info
      let exposureInfo: [ExposureInfo]
      do {
        exposureInfo = try await(enManager.getExposureInfo(
          from: summary,
          userExplanation: userExplanationMessage
        ))
      } catch {
        resolve(.error(.unableToRetrieveExposureInfo(error)))
        return
      }

      resolve(.fullDetection(now(), summary, exposureInfo, firstProcessedChunk, lastProcessedChunk))
    }
  }

  /// Returns `true` if only a full detection should be performed, `false` otherwise
  private static func shouldRetrieveExposureInfo(
    summary: ExposureDetectionSummary,
    riskScoreThreshold: Double,
    weightedDurationThreshold: Double,
    durationWeightsByAttenuation: [Double],
    isUserCovidPositive: Bool,
    isForceRun: Bool
  ) -> Bool {
    guard !isForceRun else {
      return true
    }

    guard !isUserCovidPositive else {
      // a user that is covid positive should never receive notifications.
      // To do this, we have to prevent the logic from accessing
      // exposure info
      return false
    }

    switch summary {
    case .noMatch:
      return false
    case .matches(let data):
      guard data.durationByAttenuationBucket.count <= durationWeightsByAttenuation.count else {
        // Broken configuration. Don't notify the user
        return false
      }

      let weightedDuration = zip(data.durationByAttenuationBucket, durationWeightsByAttenuation)
        .map { $0.0 * $0.1 }
        .reduce(0, +)

      let isAboveDurationThreshold = weightedDuration >= weightedDurationThreshold
      let isAboveRiskThreshold = Double(data.maximumRiskScore) >= riskScoreThreshold
      return isAboveRiskThreshold && isAboveDurationThreshold
    }
  }
}

// MARK: - Mappings

@available(iOS 13.5, *)
private extension Configuration.ExposureDetectionConfiguration {
  func toNative() -> ImmuniExposureNotification.ExposureDetectionConfiguration {
    var configuration: ExposureDetectionConfiguration
    #if targetEnvironment(simulator)
      configuration = ExposureDetectionConfigurationStub()
    #else
      configuration = ENExposureConfiguration()
    #endif

    configuration.attenuationBucketScores = self.attenuationBucketScores
    configuration.attenuationWeight = self.attenuationWeight
    configuration.daysSinceLastExposureBucketScores = self.daysSinceLastExposureBucketScores
    configuration.daysSinceLastExposureWeight = self.daysSinceLastExposureWeight
    configuration.durationBucketScores = self.durationBucketScores
    configuration.durationWeight = self.durationWeight
    configuration.transmissionRiskBucketScores = self.transmissionRiskBucketScores
    configuration.transmissionRiskWeight = self.transmissionRiskWeight
    configuration.minimumRiskScore = self.minimumRiskScore
    configuration.attenuationThresholds = self.attenuationThresholds
    return configuration
  }
}
