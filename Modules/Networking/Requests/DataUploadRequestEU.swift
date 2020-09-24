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

public struct DataUploadRequestEU: FixedSizeJSONRequest {
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

public extension DataUploadRequestEU {
    struct Body: Encodable {
        public let teks: [CodableTemporaryExposureKey]
        public let province: String
        public let exposureDetectionSummaries: [CodableExposureDetectionSummary]
        public var countriesOfInterest: [String]

        /// Create a data upload request body with given teks, province and exposureDetectionSummaries.
        /// A padding is added automatically so that both valid both dummy requests will have the same size.
        public init(
            teks: [CodableTemporaryExposureKey],
            province: String,
            exposureDetectionSummaries: [CodableExposureDetectionSummary],
            maximumExposureInfoCount: Int,
            maximumExposureDetectionSummaryCount: Int,
            countriesOfInterest: [String] = []
        ) {
            self.teks = Self.cap(teks)
            self.province = province
            self.exposureDetectionSummaries = Self.cap(
                exposureDetectionSummaries,
                maxSummaries: maximumExposureDetectionSummaryCount,
                maxExposureInfo: maximumExposureInfoCount
            )
            self.countriesOfInterest = countriesOfInterest
        }
    }
}

public extension DataUploadRequestEU.Body {
    enum CodingKeys: String, CodingKey {
        case teks
        case province
        case exposureDetectionSummaries = "exposure_detection_summaries"
    }
}

// MARK: - Sorting
extension DataUploadRequestEU.Body {
    /// In development, the key of the current day is also returned, resulting in a request with 15 TEKs. Given that the backend
    /// expects 14, the oldest one is discarded.
    static func cap(_ teks: [CodableTemporaryExposureKey]) -> [CodableTemporaryExposureKey] {
        let cappedTeks = teks
            .sorted(by: CodableTemporaryExposureKey.byRollingStartNumberDesc)
            .prefix(CodableTemporaryExposureKey.maximumKeysPerRequest)
        
        return Array(cappedTeks)
    }
    
    /// To ensure that the size of the request is within the targetSize, Summaries and ExposureInfo are capped to a given value.
    static func cap(
        _ summaries: [CodableExposureDetectionSummary],
        maxSummaries: Int,
        maxExposureInfo: Int
    ) -> [CodableExposureDetectionSummary] {
        // Cap the number of summaries, prioritizing the oldest ones.
        // Note: the cap is expected to be permissive enough so that this will reasonably never happen.
        let cappedSummaries = Array(
            summaries
                .sorted(by: CodableExposureDetectionSummary.byDateAscending)
                .prefix(maxSummaries)
        )
        
        // Cap the number of ExposureInfo, prioritizing the riskies (and the least recent in case of equality), across all summaries.
        // Note: the choice for the least recent is due to the fact that a user Uploading their TEKs (therefore being positive to
        // COVID-19) is more likely to have been infected 14 days ago rather than today).
        let exposureInfoToKeep = Set(
            cappedSummaries
                .flatMap { $0.exposureInfo }
                .sorted(by: CodableExposureInfo.byRiskDescendingDateAscending)
                .prefix(maxExposureInfo)
        )
        
        // Filter away all the exposures to discard from the capped sumamries
        var resultingSummaries: [CodableExposureDetectionSummary] = []
        for var summary in cappedSummaries {
            summary.exposureInfo = summary.exposureInfo
                .filter { exposureInfoToKeep.contains($0) }
            resultingSummaries.append(summary)
        }
        
        return resultingSummaries
    }
}
