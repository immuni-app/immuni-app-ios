//
//  PushNotificationsStatus.swift
//  Immuni
//
//  Created by LorDisturbia on 25/05/2020.
//

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
