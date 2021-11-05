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
    forceRun: Bool,
    countriesOfInterest: [CountryOfInterest]
  ) -> Promise<ExposureDetectionOutcome> {
    return Promise(in: .custom(queue: Self.queue)) { resolve, _, _ in
      guard #available(iOS 13.5, *) else {
        // No exposure detection to perform, ever.
        resolve(.noDetectionNecessary)
        return
      }

      var isFirstFlow: Bool?

      let order = Calendar.current.compare(now(), to: lastExposureDetectionDate ?? .distantPast, toGranularity: .day)

      if order == .orderedDescending {
        isFirstFlow = true
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
        status = try Hydra.await(enManager.getStatus())
      } catch {
        resolve(.error(.unableToRetrieveStatus(error)))
        return
      }

      guard status.canPerformDetection else {
        // No authorization
        resolve(.error(.notAuthorized))
        return
      }
      var keyChunksMatrix: [Country: [TemporaryExposureKeyChunk]] = [:]

      // Download the italian keys
      var keyChunks: [TemporaryExposureKeyChunk] = []
      do {
        keyChunks = try Hydra.await(
          tekProvider
            .getLatestKeyChunks(
              latestKnownChunkIndex: latestProcessedKeyChunkIndex,
              country: nil,
              isFirstFlow: isFirstFlow
            )
        )
        keyChunksMatrix[Country(countryId: Country.italyId, countryHumanReadableName: Country.italyHumanReadableName)] = keyChunks
      } catch {
        resolve(.error(.unableToRetrieveKeys(error)))
        return
      }

      // Download the foreign keys
      for countryOfInterest in countriesOfInterest {
        do {
          let keyChunksTemp = try Hydra.await(
            tekProvider.getLatestKeyChunks(
              latestKnownChunkIndex: countryOfInterest.latestProcessedKeyChunkIndex,
              country: countryOfInterest.country,
              isFirstFlow: nil
            )
          )
          keyChunks.append(contentsOf: keyChunksTemp)
          keyChunksMatrix[countryOfInterest.country] = keyChunksTemp
        } catch {
          continue
        }
      }
      defer {
        // Cleanup the local files of the downloaded chunks
        try? Hydra.await(tekProvider.clearLocalResources(for: keyChunks))
      }

      guard !keyChunks.isEmpty else {
        // No new keys. There is not detection to perform.
        resolve(.noDetectionNecessary)
        return
      }

      var firstProcessedChunk: [String: Int] = [:]
      var lastProcessedChunk: [String: Int] = [:]

      for (key, value) in keyChunksMatrix {
        firstProcessedChunk[key.countryId] = value.map { $0.index }.min()
        lastProcessedChunk[key.countryId] = value.map { $0.index }.max()
      }

      // Retrieve the summary
      let summary: ExposureDetectionSummary
      do {
        summary = try Hydra.await(enManager.getDetectionSummary(
          configuration: exposureDetectionConfiguration.toNative(),
          diagnosisKeyURLs: keyChunks.flatMap { $0.localUrls }
        ))
      } catch {
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
        // Stop at the summary
        resolve(.partialDetection(now(), summary, firstProcessedChunk, lastProcessedChunk))
        return
      }

      // Retrieve exposure info
      let exposureInfo: [ExposureInfo]
      do {
        exposureInfo = try Hydra.await(enManager.getExposureInfo(
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
    riskScoreThreshold: Int,
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
