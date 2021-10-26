// ForceUpdateLogic.swift
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

import Extensions
import Hydra
import Katana
import PushNotification
import Tempura

extension Logic {
  enum ForceUpdate {}
}

extension Logic.ForceUpdate {}

// MARK: App Force Update

extension Logic.ForceUpdate {
  /// The ids of the force update notifications
  static let forceUpdateNotificationIDs = [
    Logic.ForceUpdate.requiredUpdateAppNotificationID,
    Logic.ForceUpdate.requiredUpdateRecurringAppNotificationID
  ]

  /// The id for the required update local notification
  static let requiredUpdateAppNotificationID = "required_update_app_local_notification_id"
  /// The id for the recurring app update local notification
  static let requiredUpdateRecurringAppNotificationID = "required_update_app_recurring_local_notification_id"

  /// State observer that notifies when the force update version change
  static var minimumAppVersionDidChange: ObserverInterceptor.ObserverType.StateChangeObserver {
    return ObserverInterceptor.ObserverType.typedStateChange { (prevState: AppState, currState: AppState) -> Bool in
      prevState.configuration.minimumBuildVersion != currState.configuration.minimumBuildVersion
    }
  }

  /// Shows the force update for the app
  struct ShowAppForceUpdate: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      context.dispatch(Show(Screen.forceUpdate, animated: true, context: ForceUpdateLS(type: .app)))
    }
  }

  /// Check current App version and show ForceUpdate view if the current app version is deprecated.
  /// If the check is performed while the app is in background, a notification reminder is scheduled instead.
  struct CheckAppVersion: AppSideEffect, StateObserverDispatchable {
    init?(prevState: State, currentState: State) {}
    init() {}

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let shouldBlockApplication = context.getState().shouldBlockApplication(bundle: context.dependencies.bundle)
      guard shouldBlockApplication else {
        context.dispatch(RemoveScheduledAppReminder())
        return
      }

      let isApplicationActive = mainThread { context.dependencies.application.applicationState == .active }
      if isApplicationActive {
        try context.awaitDispatch(ShowAppForceUpdate())
      } else {
        try context.awaitDispatch(SendAndScheduleAppUpdateReminder())
      }
    }
  }

  /// Removes the scheduled local notification for app update, if any
  private struct RemoveScheduledAppReminder: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      context.dependencies.pushNotification
        .deleteScheduledLocalNotifications(with: [Logic.ForceUpdate.requiredUpdateRecurringAppNotificationID])
    }
  }

  /// Send a reminder notification for users in case they should update the app.
  /// Also, it schedules a periodic reminder to update the app.
  private struct SendAndScheduleAppUpdateReminder: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()
      let period = state.configuration.requiredUpdateNotificationPeriod
      let debugNotifications = state.toggles.isPushNotificationDebugMode

      // send immediately a notification
      context.dependencies.pushNotification.scheduleLocalNotification(
        LocalNotificationContent(
          title: L10n.Notifications.UpdateApp.title,
          body: L10n.Notifications.UpdateApp.description,
          userInfo: [:],
          identifier: Logic.ForceUpdate.requiredUpdateAppNotificationID
        ),
        with: LocalNotificationTrigger.timeInterval(1)
      )

      // schedule a recurring notification
      context.dependencies.pushNotification.scheduleLocalNotification(
        LocalNotificationContent(
          title: L10n.Notifications.UpdateApp.title,
          body: L10n.Notifications.UpdateApp.description,
          userInfo: [:],
          identifier: Logic.ForceUpdate.requiredUpdateRecurringAppNotificationID
        ),
        with: LocalNotificationTrigger.repeatingTimeInterval(period).usingDebugVersion(isDebug: debugNotifications)
      )
    }
  }
}

// MARK: OS Force Update

extension Logic.ForceUpdate {
  /// The id for the OS force update local notification ID
  private static let updateOSNotificationID = "update_os_local_notification_id"

  /// Shows the force update for the OS
  struct ShowOSForceUpdate: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      context.dispatch(Show(Screen.forceUpdate, animated: true, context: ForceUpdateLS(type: .operatingSystem)))
      context.dispatch(ScheduleOSUpdateReminder())
    }
  }

  /// Schedules a reminder notification for users in case they should update the OS
  private struct ScheduleOSUpdateReminder: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()
      let period = state.configuration.osForceUpdateNotificationPeriod
      let isDebugNotification = state.toggles.isPushNotificationDebugMode

      // ask for provisional permissions to the user
      try Hydra.await(context.dependencies.pushNotification.askForPermission([.provisional, .alert]))

      // schedule the notification
      context.dependencies.pushNotification.scheduleLocalNotification(
        LocalNotificationContent(
          title: L10n.Notifications.UpdateOs.title,
          body: L10n.Notifications.UpdateOs.description,
          userInfo: [:],
          identifier: Logic.ForceUpdate.updateOSNotificationID
        ),
        with: LocalNotificationTrigger.repeatingTimeInterval(period).usingDebugVersion(isDebug: isDebugNotification)
      )
    }
  }

  /// Removes the scheduled local notification for OS update, if any
  struct RemoveScheduledOSReminderIfNeeded: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      context.dependencies.pushNotification
        .deleteScheduledLocalNotifications(with: [Logic.ForceUpdate.updateOSNotificationID])
    }
  }
}
