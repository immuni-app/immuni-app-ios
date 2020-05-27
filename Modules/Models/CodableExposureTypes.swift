// CodableExposureTypes.swift
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

/// A codable struct holding the same information as a `TemporaryExposureKey`
public struct CodableTemporaryExposureKey: Equatable, Codable {
  public let base64EncodedKeyData: String
  public let rollingStartNumber: Int
  public let rollingPeriod: Int

  public init(
    keyData: Data,
    rollingStartNumber: Int,
    rollingPeriod: Int
  ) {
    self.base64EncodedKeyData = keyData.base64EncodedString()
    self.rollingStartNumber = rollingStartNumber
    self.rollingPeriod = rollingPeriod
  }
}

/// A codable struct holding the same information as an `ExposureDetectionSummary`
public struct CodableExposureDetectionSummary: Equatable, Hashable, Codable {
  public let date: String // yyyy-MM-dd, the date in which this summary was generated
  public let matchedKeyCount: Int
  public let daysSinceLastExposure: Int
  public let attenuationDurations: [Int] // In seconds
  public let maximumRiskScore: Int
  public var exposureInfo: [CodableExposureInfo]

  public init(
    date: Date,
    matchedKeyCount: Int,
    daysSinceLastExposure: Int,
    attenuationDurations: [TimeInterval],
    maximumRiskScore: Int,
    exposureInfo: [CodableExposureInfo]
  ) {
    self.date = date.utcIsoString
    self.matchedKeyCount = matchedKeyCount
    self.daysSinceLastExposure = daysSinceLastExposure
    self.attenuationDurations = attenuationDurations.map { $0.roundedInt().bounded(min: 0, max: 1800) }
    self.maximumRiskScore = maximumRiskScore.bounded(min: 0, max: 4096)
    self.exposureInfo = exposureInfo
  }
}

/// A codable struct holding the same information as an `ExposureInfo`
public struct CodableExposureInfo: Equatable, Hashable, Codable {
  public let date: String // yyyy-MM-dd, the date of the exposure
  public let duration: Int // In seconds
  public let attenuationValue: Int
  public let attenuationDurations: [Int] // In seconds
  public let transmissionRiskLevel: Int
  public let totalRiskScore: Int

  public init(
    date: Date,
    duration: TimeInterval,
    attenuationValue: Int,
    attenuationDurations: [TimeInterval],
    transmissionRiskLevel: Int,
    totalRiskScore: Int
  ) {
    self.date = date.utcIsoString
    self.duration = duration.roundedInt().bounded(min: 0, max: 1800)
    self.attenuationValue = attenuationValue.bounded(min: 0, max: 255)
    self.attenuationDurations = attenuationDurations.map { $0.roundedInt().bounded(min: 0, max: 1800) }
    self.transmissionRiskLevel = transmissionRiskLevel.bounded(min: 0, max: 8)
    self.totalRiskScore = totalRiskScore.bounded(min: 0, max: 4096)
  }
}

// MARK: - Coding Keys

extension CodableTemporaryExposureKey {
  enum CodingKeys: String, CodingKey {
    case base64EncodedKeyData = "key_data"
    case rollingStartNumber = "rolling_start_number"
    case rollingPeriod = "rolling_period"
  }
}

extension CodableExposureDetectionSummary {
  enum CodingKeys: String, CodingKey {
    case date
    case matchedKeyCount = "matched_key_count"
    case daysSinceLastExposure = "days_since_last_exposure"
    case attenuationDurations = "attenuation_durations"
    case maximumRiskScore = "maximum_risk_score"
    case exposureInfo = "exposure_info"
  }
}

extension CodableExposureInfo {
  enum CodingKeys: String, CodingKey {
    case date
    case duration
    case attenuationValue = "attenuation_value"
    case attenuationDurations = "attenuation_durations"
    case transmissionRiskLevel = "transmission_risk_level"
    case totalRiskScore = "total_risk_score"
  }
}
