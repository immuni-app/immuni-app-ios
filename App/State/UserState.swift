// UserState.swift
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

/// Slice of state related to the user
struct UserState: Codable {
  enum CodingKeys: String, CodingKey {
    case province
    case lastServiceNotActiveDate
    case covidStatus
    case otpUploadFailedAttempts
    case lastOtpUploadFailedAttempt
  }

  // MARK: - Persisted slices

  /// The user's province
  var province: Province?

  /// The date of the last service not active local notification
  var lastServiceNotActiveDate = Date.distantPast

  /// The current user's covid status
  var covidStatus: CovidStatus = .neutral

  /// The number of consequent failed requests of OTP validation
  var otpUploadFailedAttempts: Int = 0

  /// The time of last failed OTP validation
  var lastOtpUploadFailedAttempt: Date? = nil

  // MARK: - Not persisted slices

  /// The user's OTP. Must change at every request
  var otp = OTP()
}
