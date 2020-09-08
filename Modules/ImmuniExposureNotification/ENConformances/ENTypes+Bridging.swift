// ENTypes+Bridging.swift
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
import Foundation

// MARK: - Type bridging

@available(iOS 13.5, *)
extension ENTemporaryExposureKey: TemporaryExposureKey {
  public var transmissionRisk: RiskLevel {
    return self.transmissionRiskLevel.toNative()
  }
}

@available(iOS 13.5, *)
extension ENRiskLevel {
  init(from native: RiskLevel) {
    switch native {
    case .lowest:
      self = 0
    case .low:
      self = 1
    case .lowMedium:
      self = 2
    case .medium:
      self = 3
    case .mediumHigh:
      self = 4
    case .high:
      self = 5
    case .veryHigh:
      self = 6
    case .highest:
      self = 7
    case .invalid:
      self = 8
    }
  }

  func toNative() -> RiskLevel {
    switch self {
    case 0:
      return .lowest
    case 1:
      return .low
    case 2:
      return .lowMedium
    case 3:
      return .medium
    case 4:
      return .mediumHigh
    case 5:
      return .high
    case 6:
      return .veryHigh
    case 7:
      return .highest
    default:
      return .invalid
    }
  }
}

@available(iOS 13.5, *)
extension ENExposureDetectionSummary: ExposureDetectionSummaryData {
  public var durationByAttenuationBucket: [TimeInterval] {
    return self.attenuationDurations
      .map { $0.doubleValue }
  }

  func toExposureDetectionSummary() -> ExposureDetectionSummary {
    guard self.matchedKeyCount > 0 else {
      return .noMatch
    }

    return .matches(data: self)
  }
}

@available(iOS 13.5, *)
extension ENExposureInfo: ExposureInfo {
  public var durationByAttenuationBucket: [TimeInterval] {
    return self.attenuationDurations
      .map { $0.doubleValue }
  }

  public var transmissionRisk: RiskLevel {
    return self.transmissionRiskLevel.toNative()
  }
}

@available(iOS 13.5, *)
extension ExposureNotificationStatus {
  init(authorizationStatus: ENAuthorizationStatus, frameworkStatus: ENStatus) {
    switch authorizationStatus {
    case .unknown:
      self = .unknown
    case .restricted:
      self = .restricted
    case .notAuthorized:
      self = .notAuthorized
    case .authorized:
      switch frameworkStatus {
      case .unknown:
        self = .authorized
      case .active:
        self = .authorizedAndActive
      case .disabled:
        self = .authorizedAndInactive
      case .bluetoothOff:
        self = .authorizedAndBluetoothOff
      case .restricted:
        self = .restricted
      @unknown default:
        self = .authorized
      }
    @unknown default:
      self = .unknown
    }
  }
}

@available(iOS 13.5, *)
extension ENExposureConfiguration: ExposureDetectionConfiguration {
  /// The key inside the metadata for the threshold for attenuation buckets
  static var metadataAttenuationDurationThresholdsKey: String { "attenuationDurationThresholds" }

  public var attenuationThresholds: [Int] {
    get {
      let value = self.metadata?[Self.metadataAttenuationDurationThresholdsKey] as? [NSNumber] ?? []
      return value.map { $0.intValue }
    }
    set {
      var metadata = self.metadata ?? [:]
      metadata[Self.metadataAttenuationDurationThresholdsKey] = newValue.map { NSNumber(value: $0) }
      self.metadata = metadata
    }
  }

  public var attenuationBucketScores: [RiskScore] {
    get {
      return self.attenuationLevelValues.map { $0.uint8Value }
    }
    set {
      self.attenuationLevelValues = newValue.map { NSNumber(value: $0) }
    }
  }

  public var daysSinceLastExposureBucketScores: [RiskScore] {
    get {
      return self.daysSinceLastExposureLevelValues.map { $0.uint8Value }
    }
    set {
      self.daysSinceLastExposureLevelValues = newValue.map { NSNumber(value: $0) }
    }
  }

  public var durationBucketScores: [RiskScore] {
    get {
      return self.durationLevelValues.map { $0.uint8Value }
    }
    set {
      self.durationLevelValues = newValue.map { NSNumber(value: $0) }
    }
  }

  public var transmissionRiskBucketScores: [RiskScore] {
    get {
      return self.transmissionRiskLevelValues.map { $0.uint8Value }
    }
    set {
      self.transmissionRiskLevelValues = newValue.map { NSNumber(value: $0) }
    }
  }
}
