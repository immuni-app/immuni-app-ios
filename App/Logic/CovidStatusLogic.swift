// CovidStatusLogic.swift
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

import Hydra
import Katana
import Models
import PushNotification
import Tempura

extension Logic {
  enum CovidStatus {}
}

extension Logic.CovidStatus {
  /// Updates the user covid status based on the given event.
  /// Entering/Leaving side effects are dispatched according to the transition logic
  struct UpdateStatusWithEvent: AppSideEffect {
    let event: CovidEvent

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let previousStatus = context.getState().user.covidStatus
      let newStatus = previousStatus.transitioned(becauseOf: self.event)

      try context.awaitDispatch(Logic.CovidStatus.UpdateCovidStatus(newStatus: newStatus))

      guard previousStatus.rawCase != newStatus.rawCase else {
        return
      }

      let leavingDispatchable = previousStatus.leavingDispatchable
      let enteringDispatchable = newStatus.enteringDispatchables

      for item in leavingDispatchable {
        context.anyDispatch(item)
      }

      for item in enteringDispatchable {
        context.anyDispatch(item)
      }
    }
  }

  /// The ids of the covid status update notifications
  static let covidNotificationIDs = [
    Logic.CovidStatus.RiskNotificationID.contactReminder.rawValue,
    Logic.CovidStatus.PositiveNotificationID.updateStatus.rawValue
  ]
  /// Updates the user Green Certificate
  struct UpdateGreenCertificate: AppStateUpdater {
    let newGreenCertificate: GreenCertificate

    func updateState(_ state: inout AppState) {
        if let dgcs = state.user.greenCertificates {
            if dgcs.filter({ $0.id == newGreenCertificate.id }).count == 0 {
                state.user.greenCertificates?.append(newGreenCertificate)
            }
        }
        else{
            state.user.greenCertificates = [newGreenCertificate]
        }
    }
  }
  /// Delete the user Green Certificate
  struct DeleteGreenCertificate: AppStateUpdater {
    
    let id: String

    func updateState(_ state: inout AppState) {
      if let dgcs = state.user.greenCertificates {
        state.user.greenCertificates = dgcs.filter({ $0.id != id })
        }
      }
    }
  /// Update flag show modal Dgc
  struct UpdateFlagShowModalDgc: AppStateUpdater {
      
      func updateState(_ state: inout AppState) {
          state.user.showModalDgc = false
        }
      }
}

// MARK: Neutral Logic

extension Logic.CovidStatus {
  /// The user has just left the covid neutral state
  struct UserHasLeftNeutralState: EmptySideEffect {}

  /// The user has just entered the covid neutral state
  struct UserHasEnteredNeutralState: EmptySideEffect {}
}

// MARK: Risk Logic

extension Logic.CovidStatus {
  /// IDs to identify the notifications
  private enum RiskNotificationID: String {
    case contactReminder = "risk_reminder_notification_id"
  }

  /// The user has just left the covid risk state
  struct UserHasLeftRiskState: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      context.dispatch(RemoveRiskReminderNotification())
    }
  }

  /// The user has just entered the covid risk state
  struct UserHasEnteredRiskState: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let manager = context.dependencies.pushNotification
      let state = context.getState()

      let currentAuth = state.environment.pushNotificationAuthorizationStatus
      let notificationPeriod = state.configuration.riskReminderNotificationPeriod
      let notificationDebugMode = state.toggles.isPushNotificationDebugMode
      let isBackground = context.dependencies.application.isBackground

      guard
        currentAuth.allowsSendingNotifications,
        isBackground
      else {
        // if the user doesn't have permissions OR the app is not
        // in background (that is, the user has the app opened),
        // don't schedule any notification
        return
      }

      // If a contact with a positive user is detected, it must be the result of a full cycle of exposure detection (i.e.
      // detection with ExposureInfo), which already causes the operative system to immediately notify the user.
      // On top of this, a periodic reminder is added in case the user has not opened the app since having entered the Risk
      // state. This reminder is removed either on state change or when the app is opened.
      manager.scheduleLocalNotification(
        .init(
          title: L10n.Notifications.Risk.title,
          body: L10n.Notifications.Risk.description,
          userInfo: [:],
          identifier: RiskNotificationID.contactReminder.rawValue
        ),
        with: LocalNotificationTrigger.repeatingTimeInterval(notificationPeriod)
          .usingDebugVersion(isDebug: notificationDebugMode)
      )
    }
  }

  /// Removes the reminder that a contact happened. This should be done either when the user
  /// is not at risk anymore, or when the app is opened (whichever comes first)
  struct RemoveRiskReminderNotification: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      context.dependencies.pushNotification.deleteScheduledLocalNotifications(with: [
        RiskNotificationID.contactReminder.rawValue
      ])
    }
  }
}

// MARK: Positive Logic

extension Logic.CovidStatus {
  /// IDs for identify to notifications
  private enum PositiveNotificationID: String {
    case updateStatus = "positive_update_status_notification_id"
  }

  /// The user has just left the covid positive state
  struct UserHasLeftPositiveState: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      // The notification is descheduled if the app changes state.
      context.dependencies.pushNotification.deleteScheduledLocalNotifications(with: [
        PositiveNotificationID.updateStatus.rawValue
      ])
    }
  }

  /// The user has just entered the covid positive state
  struct UserHasEnteredPositiveState: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let manager = context.dependencies.pushNotification
      let state = context.getState()
      let currentAuth = state.environment.pushNotificationAuthorizationStatus
      let notificationDebugMode = state.toggles.isPushNotificationDebugMode

      guard currentAuth.allowsSendingNotifications else {
        return
      }

      // In order to avoid for the app to stay in this state indefinitely,
      // the user is notified every 14 days since they upload their data
      // to (eventually) update their status.
      manager.scheduleLocalNotification(
        .init(
          title: L10n.Notifications.UpdatePositiveState.title,
          body: L10n.Notifications.UpdatePositiveState.description,
          userInfo: [:],
          identifier: PositiveNotificationID.updateStatus.rawValue
        ),
        with: LocalNotificationTrigger.repeatingTimeInterval(CovidStatus.alertPeriod)
          .usingDebugVersion(isDebug: notificationDebugMode) // 14 days
      )
    }
  }
}

// MARK: Private

private extension Logic.CovidStatus {
  /// Updates the user covid status
  private struct UpdateCovidStatus: AppStateUpdater {
    let newStatus: CovidStatus

    func updateState(_ state: inout AppState) {
      state.user.covidStatus = self.newStatus
    }
  }
}
