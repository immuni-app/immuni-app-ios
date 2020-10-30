// DataUploadRequest+Mocks.swift
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
import Models
import Networking

extension DataUploadRequest.Body {
  static func mock() -> Self {
    let teks = (0 ..< 14).map { _ in CodableTemporaryExposureKey.mock() }
    let summaries = (0 ..< 30).map { _ in CodableExposureDetectionSummary.mock() }

    return self.init(
      teks: teks,
      province: "AA",
      exposureDetectionSummaries: summaries,
      maximumExposureInfoCount: 600,
      maximumExposureDetectionSummaryCount: 100,
      countriesOfInterest: []
    )
  }
}

extension CodableTemporaryExposureKey {
  static func mock() -> Self {
    return .init(
      keyData: Data.randomData(with: 168),
      rollingStartNumber: Int(Date().timeIntervalSince1970 / 600),
      rollingPeriod: 144
    )
  }
}

extension CodableExposureInfo {
  static func mock(
    date: Date = Date(),
    duration: TimeInterval = .random(in: 0 ... 1800),
    attenuationValue: Int = .random(in: 10 ... 100),
    attenuationDurations: [TimeInterval] = [
      .random(in: 0 ... 1800),
      .random(in: 0 ... 1800),
      .random(in: 0 ... 1800)
    ],
    transmissionRiskLevel: Int = .random(in: 1 ... 8),
    totalRiskScore: Int = .random(in: 1 ... 8)
  ) -> Self {
    return .init(
      date: date,
      duration: duration,
      attenuationValue: attenuationValue,
      attenuationDurations: attenuationDurations,
      transmissionRiskLevel: transmissionRiskLevel,
      totalRiskScore: totalRiskScore
    )
  }
}

extension CodableExposureDetectionSummary {
  static func mock(
    date: Date = Date(),
    matchedKeyCount: Int = .random(in: 0 ... 15),
    daysSinceLastExposure: Int = .random(in: 0 ... 14),
    attenuationDurations: [TimeInterval] = [
      .random(in: 0 ... 1800),
      .random(in: 0 ... 1800),
      .random(in: 0 ... 1800)
    ],
    maximumRiskScore: Int = .random(in: 0 ... 255),
    exposureInfo: [CodableExposureInfo] = (0 ..< Int.random(in: 1 ... 10)).map { _ in .mock() }
  ) -> Self {
    return .init(
      date: date, matchedKeyCount: matchedKeyCount, daysSinceLastExposure: daysSinceLastExposure,
      attenuationDurations: attenuationDurations, maximumRiskScore: maximumRiskScore, exposureInfo: exposureInfo
    )
  }
}
