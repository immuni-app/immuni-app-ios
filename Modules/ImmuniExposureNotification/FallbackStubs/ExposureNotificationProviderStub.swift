// ExposureNotificationProviderStub.swift
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

/// Empty implementation of an `ExposureNotificationProvider`, meant to be used on those version where Apple's framework is not
/// available.
public class ExposureNotificationProviderStub: ExposureNotificationProvider {
  public let status: ExposureNotificationStatus

  public init(status: ExposureNotificationStatus) {
    self.status = status
  }

  public func activate() -> Promise<Void> {
    return .init(resolved: ())
  }

  public func setExposureNotificationEnabled(_ enabled: Bool) -> Promise<Void> {
    return .init(resolved: ())
  }

  public func detectExposures(
    configuration: ExposureDetectionConfiguration,
    diagnosisKeyURLs: [URL]
  ) -> Promise<ExposureDetectionSummary> {
    return .init(resolved: .noMatch)
  }

  public func getExposureInfo(from summary: ExposureDetectionSummaryData, userExplanation: String) -> Promise<[ExposureInfo]> {
    return .init(resolved: [])
  }

  public func getDiagnosisKeys() -> Promise<[TemporaryExposureKey]> {
    return .init(resolved: [])
  }

  public func deactivate() -> Promise<Void> {
    return .init(resolved: ())
  }
}

/// Stub implementation of an `ExposureDetectionConfiguration`
public struct ExposureDetectionConfigurationStub: ExposureDetectionConfiguration {
  public var attenuationBucketScores: [RiskScore]
  public var attenuationWeight: Double
  public var daysSinceLastExposureBucketScores: [RiskScore]
  public var daysSinceLastExposureWeight: Double
  public var durationBucketScores: [RiskScore]
  public var durationWeight: Double
  public var transmissionRiskBucketScores: [RiskScore]
  public var transmissionRiskWeight: Double
  public var minimumRiskScore: RiskScore
  public var attenuationThresholds: [Int]

  public init(
    attenuationBucketScores: [RiskScore] = [1, 2, 3, 4, 5, 6, 7, 8],
    attenuationWeight: Double = 1,
    daysSinceLastExposureBucketScores: [RiskScore] = [1, 2, 3, 4, 5, 6, 7, 8],
    daysSinceLastExposureWeight: Double = 1,
    durationBucketScores: [RiskScore] = [1, 2, 3, 4, 5, 6, 7, 8],
    durationWeight: Double = 1,
    transmissionRiskBucketScores: [RiskScore] = [1, 2, 3, 4, 5, 6, 7, 8],
    transmissionRiskWeight: Double = 1,
    minimumRiskScore: RiskScore = 1,
    attenuationThresholds: [Int] = [50, 70]
  ) {
    self.attenuationBucketScores = attenuationBucketScores
    self.attenuationWeight = attenuationWeight
    self.daysSinceLastExposureBucketScores = daysSinceLastExposureBucketScores
    self.daysSinceLastExposureWeight = daysSinceLastExposureWeight
    self.durationBucketScores = durationBucketScores
    self.durationWeight = durationWeight
    self.transmissionRiskBucketScores = transmissionRiskBucketScores
    self.transmissionRiskWeight = transmissionRiskWeight
    self.minimumRiskScore = minimumRiskScore
    self.attenuationThresholds = attenuationThresholds
  }
}
