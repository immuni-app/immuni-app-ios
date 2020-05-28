// ExposureNotification+Models.swift
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

/// The current status of the ExposureNotification manager
public enum ExposureNotificationStatus: CaseIterable {
  /// Authorized
  case authorized

  /// Authorized and active
  case authorizedAndActive

  /// Authorized and inactive
  case authorizedAndInactive

  /// Authorized, but the bluetooth is turned off
  case authorizedAndBluetoothOff

  /// Unknown
  case unknown

  /// Restricted, e.g. through Parental Control
  case restricted

  /// Explicitly unauthorized
  case notAuthorized

  /// Returns `true` if the manager is in a state in which it can perform exposure detection, `false` otherwise
  public var canPerformDetection: Bool {
    switch self {
    case .authorized, .authorizedAndActive, .authorizedAndInactive:
      return true
    case .notAuthorized, .restricted, .unknown, .authorizedAndBluetoothOff:
      return false
    }
  }

  /// Returns `true` if the manager is authorized, `false` otherwise
  public var isAuthorized: Bool {
    switch self {
    case .authorized, .authorizedAndActive, .authorizedAndBluetoothOff, .authorizedAndInactive:
      return true

    case .notAuthorized, .restricted, .unknown:
      return false
    }
  }
}

/// A struct holding information about a single temporary key, from which a user derived its Rolling Proximity Identifiers.
public protocol TemporaryExposureKey {
  /// Key material used to generate Rolling Proximity Identifiers.
  var keyData: Data { get }

  /// Duration this key is valid. It's the number of 10-minute windows between key rolling.
  var rollingPeriod: UInt32 { get }

  /// Interval number when the key's EKRollingPeriod started.
  var rollingStartNumber: UInt32 { get }

  /// Risk of transmission associated with the person this key came from.
  var transmissionRisk: RiskLevel { get }
}

/// An arbitrary risk level associated to each key.
public enum RiskLevel {
  case invalid
  case lowest
  case low
  case lowMedium
  case medium
  case mediumHigh
  case high
  case veryHigh
  case highest
}

/// An aggregated view of the contacts of the user with a certain set of keys.
public enum ExposureDetectionSummary {
  /// No matches found
  case noMatch

  /// Some matches were found
  case matches(data: ExposureDetectionSummaryData)

  /// The number of matching keys in this summary
  public var matchedKeyCount: Int {
    switch self {
    case .noMatch:
      return 0
    case .matches(let data):
      return Int(data.matchedKeyCount)
    }
  }
}

/// Protocol that holds summary information about the exposures of the user
public protocol ExposureDetectionSummaryData {
  /// An array of durations at certain radio signal attenuations.
  var durationByAttenuationBucket: [TimeInterval] { get }

  /// Number of days since the most recent exposure.
  var daysSinceLastExposure: Int { get }

  /// The number of keys that matched for an exposure detection.
  var matchedKeyCount: UInt64 { get }

  /// The highest risk score of all exposure incidents.
  var maximumRiskScore: RiskScore { get }

  /// The metadata associated with the summary.
  // swiftlint:disable:next discouraged_optional_collection
  var metadata: [AnyHashable: Any]? { get }
}

/// A value between 1 and 8 representing a single score in a set of detection parameters
public typealias RiskScore = UInt8

/// The configuration parameters (weights and thresholds) to be used for a `ExposureDetectionSession`.
public protocol ExposureDetectionConfiguration {
  /// Scores that indicate Bluetooth signal strength.
  var attenuationBucketScores: [RiskScore] { get set }

  /// The weight applied to a Bluetooth signal strength score.
  var attenuationWeight: Double { get set }

  /// Scores that indicate the days since the user’s last exposure.
  var daysSinceLastExposureBucketScores: [RiskScore] { get set }

  /// The weight assigned to a score applied to the days since the user’s exposure.
  var daysSinceLastExposureWeight: Double { get set }

  /// Scores that indicate the duration of a user’s exposure.
  var durationBucketScores: [RiskScore] { get set }

  /// The weight assigned to a score applied to the duration of the user’s exposure.
  var durationWeight: Double { get set }

  /// Scores for the user’s estimated risk of transmission.
  var transmissionRiskBucketScores: [RiskScore] { get set }

  /// The weight assigned to a score applied to the user’s risk of transmission.
  var transmissionRiskWeight: Double { get set }

  /// The user’s minimum risk score.
  var minimumRiskScore: RiskScore { get set }

  /// The thresholds of dBm that dictates how attenuations are divided into buckets in `ExposureInfo.attenuationDurations`
  var attenuationThresholds: [Int] { get set }
}

/// The metadata associated to a single Exposure event.
public protocol ExposureInfo {
  /// The recorded attenuation of the peer device at the time the exposure occurred.
  var attenuationValue: UInt8 { get }

  /// An array of durations at certain radio signal attenuations.
  var durationByAttenuationBucket: [TimeInterval] { get }

  /// An approximate date of when the exposure occurred.
  var date: Date { get }

  /// An approximate duration of the exposure
  var duration: TimeInterval { get }

  /// The risk level associated to this exposure.
  var transmissionRisk: RiskLevel { get }

  /// The calculated risk score of the exposure.
  /// It is a function of the attenuation, the duration and the risk level.
  var totalRiskScore: RiskScore { get }

  /// The metadata associated with the exposure information.
  // swiftlint:disable:next discouraged_optional_collection
  var metadata: [AnyHashable: Any]? { get }
}
