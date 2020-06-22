// LocalNotificationScheduler.swift
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
import Hydra
import UIKit
import UserNotifications

/// Describes the content of a local notification
public struct LocalNotificationContent {
  /// Array of attachments.
  public var attachments: [UNNotificationAttachment]

  /// The title of the notification
  public var title: String

  /// The subtitle of the notification.
  public var subtitle: String?

  /// The body text of the notification
  public var body: String

  /// Custom data we can add to a notification
  public var userInfo: [AnyHashable: Any]

  /// The application badge number.
  public var badge: NSNumber?

  /// The identifier for a registered UNNotificationCategory that will be used to
  /// determine the appropriate actions to display for the notification.
  public var categoryIdentifier: String?

  /// The launch image that will be used when the app is opened from the notification.
  public var launchImageName: String?

  // The sound that will be played for the notification.
  public var sound: UNNotificationSound?

  /// The unique identifier for the thread or conversation related to this notification request.
  /// It will be used to visually group notifications together.
  public var threadIdentifier: String?

  /// The argument to be inserted in the summary for this notification.
  public var summaryArgument: String?

  /// A number that indicates how many items in the summary are represented in the summary.
  /// For example if a podcast app sends one notification for 3 new episodes in a show,
  /// the argument should be the name of the show and the count should be 3.
  /// Default is 1 and cannot be 0.
  public var summaryArgumentCount: Int?

  /// An identifier for the content of the notification used by the system to
  /// customize the scene to be activated when tapping on a notification.
  public var targetContentIdentifier: String?

  /**
   Identifier of the notification. Unique among all notificaitons scheduled notifications.
   - note: This is needed by the system to uniquely identify a notification
   */
  public var identifier: String

  /// Create a new LocalNotificationContent
  public init(title: String, body: String, userInfo: [AnyHashable: Any] = [:], identifier: String = UUID().uuidString) {
    self.title = title
    self.body = body
    self.userInfo = userInfo
    self.identifier = identifier
    self.attachments = []
  }
}

/// Describes when the notification is sent
public enum LocalNotificationTrigger {
  /// Send the notification after the specified number of seconds
  case timeInterval(TimeInterval)

  /// Send the notification after the specified number of seconds. Notification is also repeated after that amount of time
  case repeatingTimeInterval(TimeInterval)

  /// Send the nofication on the given date
  case date(Date)

  /// Send the notification in all days conforming to the given DateComponents starting from now.
  /// For ex. passing `DateComponents(weekday: 1, hour: 19, minute: 0)` triggers the same notification every first day of the week
  /// (Sunday in the Gregorian calendar) at 19:00
  case repeatingDateComponents(DateComponents)
}

/// Capable of scheduling local notifications
public protocol LocalNotificationScheduler {
  /// Schedule a local notification with the specified content to be sent when the conditions
  /// in the specified trigger are met
  func schedule(notification: LocalNotificationContent, with trigger: LocalNotificationTrigger)

  /// Delete all the scheduled local notifications
  func deleteAllScheduledNotifications()

  /// Delete the scheduled local notifications with the passed identifiers
  func deleteScheduledNotifications(with identifiers: [String])

  /// Returns all the currently scheduled notification ids
  func scheduledNotificationsIds() -> Promise<[String]>

  /// Removes delivered notifications with the given ids
  func removeDeliveredNotifications(withIdentifiers identifiers: [String])
}

class ConcreteLocalNotificationScheduler: LocalNotificationScheduler {
  func schedule(notification: LocalNotificationContent, with trigger: LocalNotificationTrigger) {
    let center = UNUserNotificationCenter.current()

    let request = UNNotificationRequest(
      identifier: notification.identifier,
      content: notification.toUNNotificationContent(),
      trigger: trigger.toUNNotificationTrigger()
    )

    center.add(request, withCompletionHandler: nil)
  }

  func deleteAllScheduledNotifications() {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
    center.removeAllDeliveredNotifications()
  }

  func deleteScheduledNotifications(with identifiers: [String]) {
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: identifiers)
    center.removeDeliveredNotifications(withIdentifiers: identifiers)
  }

  func scheduledNotificationsIds() -> Promise<[String]> {
    return Promise<[String]> { resolve, _, _ in
      let center = UNUserNotificationCenter.current()
      center.getPendingNotificationRequests { requests in
        let ids = requests.map { $0.identifier }
        resolve(ids)
      }
    }
  }

  func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
    let center = UNUserNotificationCenter.current()
    center.removeDeliveredNotifications(withIdentifiers: identifiers)
  }
}

private extension LocalNotificationContent {
  func toUNNotificationContent() -> UNNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = self.title
    content.body = self.body
    content.sound = self.sound ?? .default
    content.userInfo = self.userInfo
    content.badge = self.badge
    content.attachments = self.attachments

    if let subtitle = self.subtitle {
      content.subtitle = subtitle
    }

    if let categoryIdentifier = self.categoryIdentifier {
      content.categoryIdentifier = categoryIdentifier
    }

    if let launchImageName = self.launchImageName {
      content.launchImageName = launchImageName
    }

    if let threadIdentifier = self.threadIdentifier {
      content.threadIdentifier = threadIdentifier
    }

    if let summaryArgument = self.summaryArgument {
      content.summaryArgument = summaryArgument
    }

    if let summaryArgumentCount = self.summaryArgumentCount {
      content.summaryArgumentCount = summaryArgumentCount
    }

    if let targetContentIdentifier = self.targetContentIdentifier {
      content.targetContentIdentifier = targetContentIdentifier
    }

    return content
  }
}

private extension LocalNotificationTrigger {
  func toUNNotificationTrigger() -> UNNotificationTrigger {
    switch self {
    case .timeInterval(let timeInterval):
      return UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

    case .repeatingTimeInterval(let timeInterval):
      return UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)

    case .date(let date):
      let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
      let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
      return trigger

    case .repeatingDateComponents(let dateComponents):
      let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
      return trigger
    }
  }
}
