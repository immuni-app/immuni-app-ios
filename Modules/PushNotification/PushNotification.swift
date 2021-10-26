// PushNotification.swift
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
import UserNotifications

/// Manager used to handle local notifications
public final class PushNotificationManager {
  private var wrappeedDependencies: Dependencies?

  var localNotificationScheduler: LocalNotificationScheduler = ConcreteLocalNotificationScheduler()

  lazy var notificationPermissionsProvider: NotificationPermissionsProvider = {
    ConcreteNotificationPermissionsProvider(manager: self)
  }()

  /// Init the manager
  public init() {}

  /// Start the manager with the given dependencies
  /// - parameter dependencies: The dependencies
  public func start(with dependencies: Dependencies) {
    self.wrappeedDependencies = dependencies
  }

  /**
   Ask permission to display notifications to the user and request an APNS token.

   - parameter permissions: The permissions to ask

   - returns: A promise resolving to the authorization status once the user has made a decision

   - note: If permissions on the system alert have already been granted or denied, the result action
           will be dispatched immediately.
   */
  @discardableResult
  public func askForPermission(
    _ permissions: UNAuthorizationOptions = .all
  ) -> Promise<PushNotificationStatus> {
    return Promise(in: .userInitiated) { resolve, _, _ in
      let result = try Hydra.await(self.notificationPermissionsProvider.requestPermissions(permissions: permissions))
      resolve(PushNotificationStatus(from: result))
    }
  }

  /**
   Returns the current authorization state of the notification's permissions.
   */
  public func getCurrentAuthorizationStatus() -> Promise<PushNotificationStatus> {
    return Promise(in: .userInitiated) { resolve, _, _ in
      UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
        resolve(PushNotificationStatus(from: settings.authorizationStatus))
      })
    }
  }

  // MARK: Local notifications

  /**
   Schedule a local notification.

   - parameter notification: the content of the notification to schedule
   - parameter trigger: the trigger of the notification, specifying when to show it
   */
  public func scheduleLocalNotification(_ notification: LocalNotificationContent, with trigger: LocalNotificationTrigger) {
    self.localNotificationScheduler.schedule(notification: notification, with: trigger)
  }

  /**
   Deletes all the scheduled local notifications.
   */
  public func deleteAllLocalNotifications() {
    self.localNotificationScheduler.deleteAllScheduledNotifications()
  }

  /**
   Deletes the scheduled local notifications with the passed identifiers.

   - parameter identifiers: the identifiers of the notifications to be deleted
   */
  public func deleteScheduledLocalNotifications(with identifiers: [String]) {
    self.localNotificationScheduler.deleteScheduledNotifications(with: identifiers)
  }

  /**
   Retrieves the ids of the scheduled local notifications
   */
  public func scheduledLocalNotificationsIds() -> Promise<[String]> {
    return self.localNotificationScheduler.scheduledNotificationsIds()
  }

  /// Removes the delivered notifications with the given identifiers
  /// from the Notification Center
  public func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
    self.localNotificationScheduler.removeDeliveredNotifications(withIdentifiers: identifiers)
  }
}

private extension PushNotificationManager {
  var dependencies: Dependencies {
    guard let dependencies = self.wrappeedDependencies else {
      LibLogger.fatalError("You must call start before using the manager")
    }

    return dependencies
  }
}

public extension PushNotificationManager {
  /// Dependencies for the PushNotification Manager
  struct Dependencies {
    public init() {}
  }
}
