// CovidEvent.swift
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

/// A `Covid` event represents an event that can occur in the application and
/// that may lead to a change in the user's covid status. High-level there are 3 kind of events:
/// - user generated (e.g., user tap on a button)
/// - SDK generated (e.g., new contact detected)
/// - time-based (e.g., new day has passed)
public enum CovidEvent {
  /// The exposure notification system has detected a contact in a given date, with the give type
  case contactDetected(date: CalendarDay)

  /// The keys of the users have been uploaded to the relative service.
  /// This means that the user is positive to COVID-19
  case dataUpload(currentDate: CalendarDay)

  /// The user has performed an explicit event using the Immuni's UI
  case userEvent(UserEventType)
}

// MARK: Models

public extension CovidEvent {
  /// The type of user-generated events
  enum UserEventType {
    /// The user has explicitly dismissed the current status' alert
    case alertDismissal

    /// This should be used when the NHS confirms they are no longer positive and can go
    /// back to the neutral state
    case recoverConfirmed
  }
}
