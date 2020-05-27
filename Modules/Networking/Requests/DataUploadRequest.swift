// DataUploadRequest.swift
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

import Alamofire
import Extensions
import Foundation
import Models

public struct DataUploadRequest: FixedSizeJSONRequest {
  // swiftlint:disable:next force_unwrapping
  public var baseURL = URL(string: "https://upload.immuni.gov.it")!
  public var path = "/v1/ingestion/upload"
  public var method: HTTPMethod = .post
  public var cachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData

  public var headers: [HTTPHeader] {
    return HTTPHeader.defaultImmuniHeaders + [
      .authorization(bearerToken: self.otp.rawValue.sha256),
      .contentType("application/json; charset=UTF-8"),
      .dummyData(false),
      .clientClock(self.now())
    ]
  }

  public let jsonParameter: Body
  public let otp: OTP
  public let now: () -> Date
  public let targetSize: Int

  public init(body: Body, otp: OTP, now: @escaping () -> Date, targetSize: Int) {
    self.jsonParameter = body
    self.otp = otp
    self.now = now
    self.targetSize = targetSize
  }
}

public extension DataUploadRequest {
  struct Body: Encodable {
    public let teks: [CodableTemporaryExposureKey]
    public let province: String
    public let exposureDetectionSummaries: [CodableExposureDetectionSummary]

    /// Create a data upload request body with given teks, province and exposureDetectionSummaries.
    /// A padding is added automatically so that both valid both dummy requests will have the same size.
    public init(
      teks: [CodableTemporaryExposureKey],
      province: String,
      exposureDetectionSummaries: [CodableExposureDetectionSummary],
      maximumExposureInfoCount: Int,
      maximumExposureDetectionSummaryCount: Int
    ) {
      self.teks = Self.cap(teks)
      self.province = province
      self.exposureDetectionSummaries = Self.cap(
        exposureDetectionSummaries,
        maxSummaries: maximumExposureDetectionSummaryCount,
        maxExposureInfo: maximumExposureInfoCount
      )
    }
  }
}

public extension DataUploadRequest.Body {
  enum CodingKeys: String, CodingKey {
    case teks
    case province
    case exposureDetectionSummaries = "exposure_detection_summaries"
  }
}

// MARK: - Sorting

extension DataUploadRequest.Body {
  // In development, the key of the current day is also returned, resulting in a request with 15 TEKs. Given that the backend
  // expects 14, the oldest one is discarded.
  static func cap(_ teks: [CodableTemporaryExposureKey]) -> [CodableTemporaryExposureKey] {
    let cappedTeks = teks
      .sorted(by: CodableTemporaryExposureKey.byRollingStartNumberDesc)
      .prefix(14)

    return Array(cappedTeks)
  }

  static func cap(
    _ summaries: [CodableExposureDetectionSummary],
    maxSummaries: Int,
    maxExposureInfo: Int
  ) -> [CodableExposureDetectionSummary] {
    let cappedSummaries = Array(
      summaries
        .sorted(by: CodableExposureDetectionSummary.byDateDescending)
        .prefix(maxSummaries)
    )

    let exposureInfoWithSummary = Array(
      cappedSummaries
        .flatMap { summary in summary.exposureInfo.map { info in (info: info, summary: summary) } }
        .sorted(by: CodableExposureInfo.byRiskDescendingDateAscending)
        .prefix(maxExposureInfo)
    )

    let exposureInfosBySummary = Dictionary(grouping: exposureInfoWithSummary, by: { $0.summary })
      .mapValues { $0.map { $0.info } }

    var resultingSummaries: [CodableExposureDetectionSummary] = []
    for (var summary, exposureInfos) in exposureInfosBySummary {
      summary.exposureInfo = exposureInfos
      resultingSummaries.append(summary)
    }

    return resultingSummaries
  }
}

extension CodableTemporaryExposureKey {
  /// Sorting closure that sorts two keys by rollingStartNumber in descending order.
  static let byRollingStartNumberDesc: (Self, Self) -> Bool = { lhs, rhs in
    lhs.rollingStartNumber > rhs.rollingStartNumber
  }
}

extension CodableExposureDetectionSummary {
  /// Sorting closure that sorts two summaries by date in descending order.
  /// Note: `date` is a String, but it's in the `yyyy-MM-dd` format so lexicographic sorting is correct.
  static let byDateDescending: (Self, Self) -> Bool = { lhs, rhs in
    lhs.date > rhs.date
  }
}

extension CodableExposureInfo {
  typealias ExposureInfoWithSummary = (info: CodableExposureInfo, summary: CodableExposureDetectionSummary)

  static let byRiskDescendingDateAscending: (ExposureInfoWithSummary, ExposureInfoWithSummary) -> Bool = { lhs, rhs in
    let lhs = lhs.info
    let rhs = rhs.info

    guard lhs.totalRiskScore != rhs.totalRiskScore else {
      // Same risk. Sort by date ascending
      return lhs.date < rhs.date
    }

    // Sort by risk descending
    return lhs.totalRiskScore > rhs.totalRiskScore
  }
}
