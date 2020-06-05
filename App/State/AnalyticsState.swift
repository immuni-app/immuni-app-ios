// AnalyticsState.swift
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

/// Slice of state used to store pieces of information related to the analytics logic.
/// Note that this is NOT used to store analytics
struct AnalyticsState: Codable {
  /// The day in which the last analytic with exposure has been sent
  var eventWithExposureLastSent = Date.distantPast.calendarDay

  /// The day in which the last analytic without exposure has been sent
  var eventWithoutExposureLastSent = Date.distantPast.calendarDay

  /// The current opportunity window to send a new analytic without exposure
  var eventWithoutExposureWindow: OpportunityWindow = .distantPast

  /// The opportunity window for Analytics-related dummy traffic.
  var dummyTrafficOpportunityWindow: OpportunityWindow = .distantPast

  /// The rolling token to be used for analytics uploads
  var token: AnalyticsToken? = nil
}

extension AnalyticsState {
  /// A rolling token to be used for analytics upload, with the given expiration date
  enum AnalyticsToken: Codable {
    case generated(token: String, expiration: Date)
    case validated(token: String, expiration: Date)

    /// The actual token
    var token: String {
      switch self {
      case .generated(let token, _), .validated(let token, _):
        return token
      }
    }

    /// The expiration date for this token
    var expiration: Date {
      switch self {
      case .generated(_, let expiration), .validated(_, let expiration):
        return expiration
      }
    }

    /// Whether this token is expired
    func isExpired(now: Date) -> Bool {
      return self.expiration <= now
    }

    func isValid(now: Date) -> Bool {
      switch self {
      case .generated:
        return false
      case .validated:
        return !self.isExpired(now: now)
      }
    }
  }
}

// MARK: - Codable conformances

extension AnalyticsState.AnalyticsToken {
  private enum CodingKeys: String, CodingKey {
    case type
    case token
    case expiration
  }

  private enum Case: String, Codable {
    case generated
    case validated
  }

  private var rawCase: Case {
    switch self {
    case .generated:
      return .generated
    case .validated:
      return .validated
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let status = try container.decode(Case.self, forKey: CodingKeys.type)
    let token = try container.decode(String.self, forKey: CodingKeys.token)
    let expiration = try container.decode(Date.self, forKey: CodingKeys.expiration)
    switch status {
    case .generated:
      self = .generated(token: token, expiration: expiration)
    case .validated:
      self = .validated(token: token, expiration: expiration)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.rawCase, forKey: CodingKeys.type)
    switch self {
    case .generated(let token, let expiration), .validated(let token, let expiration):
      try container.encode(token, forKey: CodingKeys.token)
      try container.encode(expiration, forKey: CodingKeys.expiration)
    }
  }
}
