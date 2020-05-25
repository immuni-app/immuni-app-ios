// PushNotificationStatus.swift
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
import UserNotifications

/// The current permission status of Push Notifications
public enum PushNotificationStatus: CaseIterable {
  /// The user has not yet made a choice regarding whether the application may post user notifications.
  case notDetermined

  /// The application is not authorized to post user notifications.
  case denied

  /// The application is authorized to post user notifications.
  case authorized

  /// The application is authorized to post non-interruptive user notifications.
  case provisional

  /// Initialization from Apple's type
  public init(from native: UNAuthorizationStatus) {
    switch native {
    case .notDetermined:
      self = .notDetermined
    case .denied:
      self = .denied
    case .authorized:
      self = .authorized
    case .provisional:
      self = .provisional
    @unknown default:
      self = .notDetermined
    }
  }
}

public extension PushNotificationStatus {
  /// Whether the authorization status allows the app to send notification to the user
  var allowsSendingNotifications: Bool {
    switch self {
    case .authorized, .provisional:
      return true
    case .denied, .notDetermined:
      return false
    }
  }
}
