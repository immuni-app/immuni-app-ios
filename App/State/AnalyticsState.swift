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
  struct AnalyticsToken: Codable {
    /// The default length of the token, in bytes
    static let tokenLength: Int = 128

    let token: String
    let expiration: Date
    let status: Status

    enum Status: String, Codable {
      /// The token has been generated but it hasn't been validated by the backend yet
      case generated

      /// The token has been validated by the backend
      case validated
    }

    /// Whether this token is expired
    func isExpired(now: Date) -> Bool {
      return self.expiration <= now
    }

    /// Whether the token has been validated and is not expired
    func isValid(now: Date) -> Bool {
      switch self.status {
      case .generated:
        return false
      case .validated:
        return !self.isExpired(now: now)
      }
    }
  }
}
