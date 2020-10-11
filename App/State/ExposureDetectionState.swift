// ExposureDetectionState.swift
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
import ImmuniExposureNotification
import Models

/// The slice of state related to exposure detection events
struct ExposureDetectionState: Codable {
  /// The index of latest processed chunk of `TemporaryExposureKeys`
  var latestProcessedKeyChunkIndex: Int? = nil

  /// The date of the most recent exposure detection, if any.
  var lastDetectionDate: Date? = nil

  /// The recent (last 14 days) outcomes of Exposure detection cycles that resulted in positive matches.
  /// They are stored so that they can be sent in case of a Data Upload (see `Logic.DataUpload`)
  var recentPositiveExposureResults: [PositiveExposureResult] = []

  /// The list contains the selected country, the selection date and the latestProcessedKeyChunkIndex of the country
  var countriesOfInterest: [CountryOfInterest] = []

  #if canImport(DebugMenu)
    /// The series of results of previous exposure detections.
    /// It is used only in the debug environment to collect information about every Exposure Detection run.
    var previousDetectionResults: [DebugRecord] = []
  #endif
}

// MARK: Models

extension ExposureDetectionState {
  /// The outcome of an exposure detection that resulted in one or more matches
  struct PositiveExposureResult: Codable {
    /// The date this result refers to
    let date: Date

    /// The content of this result
    let data: CodableExposureDetectionSummary

    /// Default init
    init(date: Date, data: CodableExposureDetectionSummary) {
      self.date = date
      self.data = data
    }

    /// Convenience initializer from an outcome
    init?(from outcome: ExposureDetectionOutcome) {
      switch outcome {
      case .noDetectionNecessary, .error, .partialDetection(_, .noMatch, _, _), .fullDetection(_, .noMatch, _, _, _):
        return nil
      case .partialDetection(let date, .matches(let summary), _, _):
        self.date = date
        self.data = .init(from: summary, with: [], generatedAt: date)
      case .fullDetection(let date, .matches(let summary), let exposureInfo, _, _):
        self.date = date
        self.data = .init(from: summary, with: exposureInfo, generatedAt: date)
      }
    }
  }
}

// MARK: - Helpers

private extension CodableExposureDetectionSummary {
  init(from nativeSummary: ExposureDetectionSummaryData, with nativeExposureInfo: [ExposureInfo], generatedAt date: Date) {
    self.init(
      date: date,
      matchedKeyCount: Int(nativeSummary.matchedKeyCount),
      daysSinceLastExposure: nativeSummary.daysSinceLastExposure,
      attenuationDurations: nativeSummary.durationByAttenuationBucket,
      maximumRiskScore: Int(nativeSummary.maximumRiskScore),
      exposureInfo: nativeExposureInfo.map { .init(from: $0) }
    )
  }
}

private extension CodableExposureInfo {
  init(from native: ExposureInfo) {
    self.init(
      date: native.date,
      duration: native.duration,
      attenuationValue: Int(native.attenuationValue),
      attenuationDurations: native.durationByAttenuationBucket,
      transmissionRiskLevel: native.transmissionRisk.toInt(),
      totalRiskScore: Int(native.totalRiskScore)
    )
  }
}

private extension RiskLevel {
  func toInt() -> Int {
    switch self {
    case .invalid:
      return 0
    case .lowest:
      return 1
    case .low:
      return 2
    case .lowMedium:
      return 3
    case .medium:
      return 4
    case .mediumHigh:
      return 5
    case .high:
      return 6
    case .veryHigh:
      return 7
    case .highest:
      return 8
    }
  }
}
