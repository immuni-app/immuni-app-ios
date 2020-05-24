// ExposureDetectionState+Debugging.swift
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

#if canImport(DebugMenu)
  extension ExposureDetectionState {
    /// A struct to keep track of a single run of Exposure Detection. It is only used in the debug environment
    struct DebugRecord: Codable {
      /// The kind of exposure detection run (foreground or background)
      let kind: Kind

      /// The result of the Exposure Detection run
      let result: Result

      /// The time at which the record was created
      let timestamp: Date

      init(kind: Kind, result: Result, timestamp: Date = Date()) {
        self.kind = kind
        self.result = result
        self.timestamp = timestamp
      }
    }
  }

  extension ExposureDetectionState.DebugRecord {
    /// The kind of Exposure Detection run.
    enum Kind: String, Codable {
      case background
      case foreground
    }

    /// The result of an exposure detection run. It's basically a slimmed-down, codable version of `ExposureDetectionOutcome`
    enum Result: Codable {
      /// Detection was skipped
      case skipped
      /// Detection failed. `errorType` contains the case of `ExposureDetectionError` that was triggereds
      case failed(_ errorType: String)
      /// Detection succeeded
      case succeeded(exposuresCount: Int, fullDetection: Bool)
    }
  }

  // MARK: - Initializers

  extension ExposureDetectionState.DebugRecord.Result {
    init(from outcome: ExposureDetectionOutcome) {
      switch outcome {
      case .noDetectionNecessary:
        self = .skipped
      case .partialDetection(_, let summary, _, _):
        self = .succeeded(exposuresCount: summary.matchedKeyCount, fullDetection: false)
      case .fullDetection(_, _, let exposureInfo, _, _):
        self = .succeeded(exposuresCount: exposureInfo.count, fullDetection: true)
      case .error(let error):
        self = .failed(error.label)
      }
    }
  }

  extension ExposureDetectionState.DebugRecord.Kind {
    init(from type: Logic.ExposureDetection.DetectionType) {
      switch type {
      case .foreground:
        self = .foreground
      case .background:
        self = .background
      }
    }
  }

  // MARK: - CustomStringConvertible conformances

  extension ExposureDetectionState.DebugRecord: CustomStringConvertible {
    static let formatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd@HH:mm"
      return formatter
    }()

    var description: String {
      "<\(Self.formatter.string(from: self.timestamp)) (\(self.kind)) – \(self.result)>"
    }
  }

  extension ExposureDetectionState.DebugRecord.Kind: CustomStringConvertible {
    var description: String {
      switch self {
      case .foreground:
        return "foreground"
      case .background:
        return "background"
      }
    }
  }

  extension ExposureDetectionState.DebugRecord.Result: CustomStringConvertible {
    var description: String {
      switch self {
      case .skipped:
        return "skipped"
      case .failed(let reason):
        return "failed(\(reason))"
      case .succeeded(let exposuresCount, let fullDetection):
        return "success(\(fullDetection ? "full" : "partial"), \(exposuresCount) matches)"
      }
    }
  }

  // MARK: - Codable conformances

  extension ExposureDetectionState.DebugRecord.Result {
    private enum CodingKeys: String, CodingKey {
      case type
      case error
      case exposuresCount
      case fullDetection
    }

    private enum Case: String, Codable {
      case failed
      case succeeded
      case skipped
    }

    private var rawCase: Case {
      switch self {
      case .failed:
        return .failed
      case .succeeded:
        return .succeeded
      case .skipped:
        return .skipped
      }
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let status = try container.decode(Case.self, forKey: CodingKeys.type)
      switch status {
      case .skipped:
        self = .skipped
      case .failed:
        let errorType = try container.decode(String.self, forKey: CodingKeys.error)
        self = .failed(errorType)
      case .succeeded:
        let exposuresCount = try container.decode(Int.self, forKey: CodingKeys.exposuresCount)
        let fullDetection = try container.decode(Bool.self, forKey: CodingKeys.fullDetection)
        self = .succeeded(exposuresCount: exposuresCount, fullDetection: fullDetection)
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(self.rawCase, forKey: CodingKeys.type)
      switch self {
      case .skipped:
        break
      case .failed(let error):
        try container.encode(error, forKey: CodingKeys.error)
      case .succeeded(let exposuresCount, let fullDetection):
        try container.encode(exposuresCount, forKey: CodingKeys.exposuresCount)
        try container.encode(fullDetection, forKey: CodingKeys.fullDetection)
      }
    }
  }

  // MARK: - Helpers

  private extension ExposureDetectionError {
    var label: String {
      switch self {
      case .timeout:
        return "timeout"
      case .notAuthorized:
        return "notAuthorized"
      case .unableToRetrieveKeys:
        return "unableToRetrieveKeys"
      case .unableToRetrieveStatus:
        return "unableToRetrieveStatus"
      case .unableToRetrieveSummary:
        return "unableToRetrieveSummary"
      case .unableToRetrieveExposureInfo:
        return "unableToRetrieveExposureInfo"
      }
    }
  }
#endif
