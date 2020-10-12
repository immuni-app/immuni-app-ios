// ExposureDetectionExecutor.swift
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
import Models

/// Protocol that is able to perform a cycle of exposure detection
public protocol ExposureDetectionExecutor {
  /// Executes a cycle of Exposure Detection, given a set of parameters
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
  ) -> Promise<ExposureDetectionOutcome>
}

/// Outcome of a cycle of exposure detection
public enum ExposureDetectionOutcome {
  /// No detection was necessary, for example because it was performed recently
  case noDetectionNecessary

  /// Only a partial detection has been performed, i.e. a detection that stopped at the `ExposureDetectionSummary`.`
  case partialDetection(
    _ date: Date,
    _ summary: ExposureDetectionSummary,
    _ earliestProcessedChunk: [String: Int],
    _ latestProcessedChunk: [String: Int]
  )

  /// A full detection has been performed, i.e. a detection that gathered `ExposureInfo`.`
  case fullDetection(
    _ date: Date,
    _ summary: ExposureDetectionSummary,
    _ exposureInfo: [ExposureInfo],
    _ earliestProcessedChunk: [String: Int],
    _ latestProcessedChunk: [String: Int]
  )

  /// A detection resulted in an error
  case error(ExposureDetectionError)

  /// The error associated to this outcome, if any.
  public var error: ExposureDetectionError? {
    switch self {
    case .error(let error):
      return error
    case .noDetectionNecessary, .partialDetection, .fullDetection:
      return nil
    }
  }

  /// The first and the last chunk indexes processed in this detection, if any.
  public var processedChunkBoundaries: ([String: Int], [String: Int])? {
    switch self {
    case .error, .noDetectionNecessary:
      return nil
    case .partialDetection(_, _, let earliestProcessedChunk, let latestProcessedChunk),
         .fullDetection(_, _, _, let earliestProcessedChunk, let latestProcessedChunk):
      return (earliestProcessedChunk, latestProcessedChunk)
    }
  }

  /// Whether this detection was successful
  public var isSuccessful: Bool {
    return self.error == nil
  }
}

/// Errors related to exposure detection
public enum ExposureDetectionError: Swift.Error {
  case timeout
  case notAuthorized
  case unableToRetrieveKeys(_ inner: Swift.Error)
  case unableToRetrieveStatus(_ inner: Swift.Error)
  case unableToRetrieveSummary(_ inner: Swift.Error)
  case unableToRetrieveExposureInfo(_ inner: Swift.Error)
}
