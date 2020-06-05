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
    exposureInfoRiskScoreThreshold: Int,
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
        AppLogger.debug("[EDExecutor] iOS version too low")
        resolve(.noDetectionNecessary)
        return
      }

      AppLogger.debug(
        """
        [EDExecutor] Start exposure detection execution:
          lastDetectionDate: \(String(describing: lastExposureDetectionDate)),
          latestProcessedChunk: \(String(describing: latestProcessedKeyChunkIndex)),
          fullDetectionThreshold: \(exposureInfoRiskScoreThreshold),
          configuration: \(exposureDetectionConfiguration.toNative())
          isForceRun: \(forceRun)
        """
      )

      let timeSinceLastDetection = now().timeIntervalSince(lastExposureDetectionDate ?? .distantPast)
      guard forceRun || timeSinceLastDetection >= exposureDetectionPeriod else {
        // Exposure detection was performed recently
        AppLogger
          .debug("[EDExecutor] Not enough time since last detection (\(timeSinceLastDetection) < \(exposureDetectionPeriod))")
          resolve(.noDetectionNecessary)
          return
      }

      AppLogger.debug("[EDExecutor] Check EN status")

      // Check for authorization
      let status: ExposureNotificationStatus
      do {
        status = try await(enManager.getStatus())
        AppLogger.debug("[EDExecutor] Got EN status \(status)")
      } catch {
        AppLogger.debug("[EDExecutor] Error getting EN status \(error)")
        resolve(.error(.unableToRetrieveStatus(error)))
        return
      }

      guard status.canPerformDetection else {
        // No authorization
        AppLogger.debug("[EDExecutor] Can't perform detection with status \(status)")
        resolve(.error(.notAuthorized))
        return
      }

      AppLogger.debug("[EDExecutor] Start downloading key chunks (latest: \(String(describing: latestProcessedKeyChunkIndex)))")

      // Download the keys
      let keyChunks: [TemporaryExposureKeyChunk]
      do {
        keyChunks = try await(
          tekProvider
            .getLatestKeyChunks(latestKnownChunkIndex: latestProcessedKeyChunkIndex)
        )
        AppLogger.debug("[EDExecutor] Got \(keyChunks.count) chunks")
      } catch {
        AppLogger.debug("[EDExecutor] Error getting chunks \(error)")
        resolve(.error(.unableToRetrieveKeys(error)))
        return
      }

      defer {
        AppLogger.debug("[EDExecutor] Cleanup")
        // Cleanup the local files of the downloaded chunks
        try? await(tekProvider.clearLocalResources(for: keyChunks))
      }

      guard !keyChunks.isEmpty else {
        // No new keys. There is not detection to perform.
        AppLogger.debug("[EDExecutor] No chunks downloaded")
        resolve(.noDetectionNecessary)
        return
      }

      let firstProcessedChunk = keyChunks.map { $0.index }.min()
        ?? AppLogger.fatalError("keyChunks cannot be empty at this stage")

      let lastProcessedChunk = keyChunks.map { $0.index }.max()
        ?? AppLogger.fatalError("keyChunks cannot be empty at this stage")

      AppLogger.debug("[EDExecutor] Start getting summary")
      // Retrieve the summary
      let summary: ExposureDetectionSummary
      do {
        summary = try await(enManager.getDetectionSummary(
          configuration: exposureDetectionConfiguration.toNative(),
          diagnosisKeyURLs: keyChunks.flatMap { $0.localUrls }
        ))
        AppLogger.debug("[EDExecutor] Got summary \(summary)")
      } catch {
        AppLogger.debug("[EDExecutor] Error getting summary \(error)")
        resolve(.error(.unableToRetrieveSummary(error)))
        return
      }

      let shouldRetrieveInfo = Self.shouldRetrieveExposureInfo(
        summary: summary,
        riskScoreThreshold: exposureInfoRiskScoreThreshold,
        isUserCovidPositive: isUserCovidPositive,
        isForceRun: forceRun
      )

      guard shouldRetrieveInfo else {
        AppLogger.debug("[EDExecutor] Avoiding full detection")
        // Stop at the summary
        resolve(.partialDetection(now(), summary, firstProcessedChunk, lastProcessedChunk))
        return
      }

      AppLogger.debug("[EDExecutor] Continuing with full detection")

      // Retrieve exposure info
      let exposureInfo: [ExposureInfo]
      do {
        exposureInfo = try await(enManager.getExposureInfo(
          from: summary,
          userExplanation: userExplanationMessage
        ))
        AppLogger.debug("[EDExecutor] Got exposure info: \(exposureInfo)")
      } catch {
        AppLogger.debug("[EDExecutor] Error getting exposure info \(error)")
        resolve(.error(.unableToRetrieveExposureInfo(error)))
        return
      }

      AppLogger.debug("[EDExecutor] Detection completed")
      resolve(.fullDetection(now(), summary, exposureInfo, firstProcessedChunk, lastProcessedChunk))
    }
  }

  /// Returns `true` if only a full detection should be performed, `false` otherwise
  private static func shouldRetrieveExposureInfo(
    summary: ExposureDetectionSummary,
    riskScoreThreshold: Int,
    isUserCovidPositive: Bool,
    isForceRun: Bool
  ) -> Bool {
    AppLogger.debug("[EDExecutor] Start check if full detection")
    guard !isForceRun else {
      AppLogger.debug("[EDExecutor] Continue because force run")
      return true
    }

    guard !isUserCovidPositive else {
      // a user that is covid positive should never receive notifications.
      // To do this, we have to prevent the logic from accessing
      // exposure info
      AppLogger.debug("[EDExecutor] Stop because user positive")
      return false
    }

    switch summary {
    case .noMatch:
      AppLogger.debug("[EDExecutor] Stop because no matches")
      return false
    case .matches(let data):
      AppLogger.debug("[EDExecutor] Summary risk score: \(data.maximumRiskScore), threshold: \(riskScoreThreshold)")
      return data.maximumRiskScore >= riskScoreThreshold
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
