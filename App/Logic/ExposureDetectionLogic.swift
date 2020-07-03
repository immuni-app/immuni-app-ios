// ExposureDetectionLogic.swift
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
import Foundation
import Hydra
import ImmuniExposureNotification
import Katana
import Models

extension Logic {
  enum ExposureDetection {}
}

extension Logic.ExposureDetection {
  /// Performs a cycle of exposure detection if enough time has passed since the previous one.
  /// This core of this logic is in `PerformExposureDetectionIfNecessary.performExposureDetection`, which returns an `Outcome`.
  /// The rest of the body of this `SideEffect` is about handling this outcome.
  struct PerformExposureDetectionIfNecessary: AppSideEffect {
    /// The type of detection to perform
    var type: DetectionType

    /// Whether to forcefully run a cycle of exposure detection, regardless of preconditions
    var forceRun: Bool = false

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      // Set the task expiration handler
      self.type.backgroundTask?.expirationHandler = {
        let timeout: ExposureDetectionOutcome = .error(.timeout)
        try? context.awaitDispatch(TrackExposureDetectionPerformed(outcome: timeout, type: self.type))
        try? context.awaitDispatch(SignalBackgroundTask(outcome: timeout, type: self.type))
        self.type.backgroundTask?.setTaskCompleted(success: false)
      }

      let state = context.getState()

      /// Perform a cycle of exposure detection and retrieve its outcome
      let outcome = try await(context.dependencies.exposureDetectionExecutor.execute(
        exposureDetectionPeriod: self.type.detectionPeriod(using: state.configuration),
        lastExposureDetectionDate: state.exposureDetection.lastDetectionDate,
        latestProcessedKeyChunkIndex: state.exposureDetection.latestProcessedKeyChunkIndex,
        exposureDetectionConfiguration: state.configuration.exposureConfiguration,
        exposureInfoRiskScoreThreshold: state.configuration.exposureInfoMinimumRiskScore,
        userExplanationMessage: L10n.Notifications.AppleExposureNotification.message,
        enManager: context.dependencies.exposureNotificationManager,
        tekProvider: context.dependencies.temporaryExposureKeyProvider,
        now: context.dependencies.now,
        isUserCovidPositive: state.user.covidStatus.isCovidPositive,
        forceRun: self.forceRun
      ))

      if let error = outcome.error {
        // Custom handling of specific errors
        self.handleError(error, context: context)
      }

      if let (_, latestProcessedChunk) = outcome.processedChunkBoundaries {
        // Update the latest processed chunk in the state
        try context.awaitDispatch(UpdateLatestProcessedKeyChunkIndex(index: latestProcessedChunk))
      }

      try context.awaitDispatch(TrackExposureDetectionPerformed(outcome: outcome, type: self.type))
      try? context.awaitDispatch(Logic.Analytics.SendOperationalInfoIfNeeded(outcome: outcome))
      try context.awaitDispatch(UpdateUserStatusIfNecessary(outcome: outcome))
      try? context.awaitDispatch(SignalBackgroundTask(outcome: outcome, type: self.type))

      // Mark the background task as completed, if any.
      self.type.backgroundTask?.setTaskCompleted(success: outcome.isSuccessful)
    }

    /// Custom handling of specific errors
    private func handleError(_ error: ExposureDetectionError, context: SideEffectContext<AppState, AppDependencies>) {
      switch error {
      case .notAuthorized:
        try? context.awaitDispatch(ScheduleLocalNotificationIfPossible())
      case .unableToRetrieveKeys, .unableToRetrieveStatus, .unableToRetrieveSummary, .unableToRetrieveExposureInfo, .timeout:
        // No custom handling necessary
        break
      }
    }
  }

  /// Update the COVID status of the user if the outcome requires it.
  struct UpdateUserStatusIfNecessary: AppSideEffect {
    let outcome: ExposureDetectionOutcome

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let mostRecentContactDay: CalendarDay

      switch self.outcome {
      case .error, .noDetectionNecessary:
        // Nothing to update
        return

      case .partialDetection(_, let summary, _, _):
        guard
          let mostRecentSummaryContactDay = summary.mostRecentContactDay
          else {
            // No matches, nothing to update
            return
        }

        mostRecentContactDay = mostRecentSummaryContactDay

      case .fullDetection(_, _, let exposureInfo, _, _):
        guard
          let mostRecentExposureInfoContactDay = exposureInfo.mostRecentContactDay
          else {
            // No matches, nothing to update
            return
        }

        mostRecentContactDay = mostRecentExposureInfoContactDay
      }

      let event: CovidEvent = .contactDetected(date: mostRecentContactDay)

      // Update the local COVID status of the user
      try context.awaitDispatch(Logic.CovidStatus.UpdateStatusWithEvent(event: event))
    }
  }
}

// MARK: - Notification

extension Logic.ExposureDetection {
  private enum NotificationID: String {
    case notAuthorized = "exposure_detection_not_authorized_notification_id"
  }

  /// Schedules a local notification to inform the user that the app doesn't have the required permissions to perform
  /// exposure detection
  struct ScheduleLocalNotificationIfPossible: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let manager = context.dependencies.pushNotification
      let state = context.getState()

      let now = context.dependencies.now()
      let timeSinceLastNotification = now.timeIntervalSince(state.user.lastServiceNotActiveDate)

      guard
        state.environment.pushNotificationAuthorizationStatus.allowsSendingNotifications,
        timeSinceLastNotification >= state.configuration.serviceNotActiveNotificationPeriod
        else {
          // either no permissions or too soon
          return
      }

      manager.scheduleLocalNotification(
        .init(
          title: L10n.Notifications.NotActiveService.title,
          body: L10n.Notifications.NotActiveService.description,
          identifier: NotificationID.notAuthorized.rawValue
        ),

        with: .date(now.addingTimeInterval(10))
      )

      try context.awaitDispatch(UpdateActiveNotificationTimestamp(date: now))
    }
  }

  /// Removes the delivered local notification about missing permissions
  /// If it is not longer needed
  struct RemoveLocalNotificationIfNotNeeded: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      guard state.environment.exposureNotificationAuthorizationStatus.isAuthorized else {
        // still not authorized
        return
      }

      context.dependencies.pushNotification.removeDeliveredNotifications(withIdentifiers: [
        NotificationID.notAuthorized.rawValue
      ])
    }
  }

  /// Updates the date of when the last not active service notification has been sent
  private struct UpdateActiveNotificationTimestamp: AppStateUpdater {
    let date: Date

    func updateState(_ state: inout AppState) {
      state.user.lastServiceNotActiveDate = self.date
    }
  }
}

// MARK: - Maintenance

extension Logic.ExposureDetection {
  struct ClearOutdatedResults: AppStateUpdater {
    let now: Date

    func updateState(_ state: inout AppState) {
      state.exposureDetection.recentPositiveExposureResults
        .removeAll(where: { self.now.timeIntervalSince($0.date) > CovidStatus.alertPeriod })
    }
  }
}

// MARK: - State updaters

extension Logic.ExposureDetection {
  /// Register the result of an exposure detection in the state.
  struct TrackExposureDetectionPerformed: AppStateUpdater {
    let outcome: ExposureDetectionOutcome
    let type: DetectionType

    func updateState(_ state: inout AppState) {
      #if canImport(DebugMenu)
        let record = ExposureDetectionState.DebugRecord(kind: .init(from: self.type), result: .init(from: self.outcome))
        state.exposureDetection.previousDetectionResults.append(record)
      #endif

      if let positiveExposureResult = ExposureDetectionState.PositiveExposureResult(from: self.outcome) {
        state.exposureDetection.recentPositiveExposureResults.append(positiveExposureResult)
      }

      // If successful, update the date of the last detection to the state
      switch self.outcome {
      case .noDetectionNecessary, .error:
        break
      case .partialDetection, .fullDetection:
        state.exposureDetection.lastDetectionDate = Date()
      }
    }
  }

  /// Updates the latest processed key chunk in the `ExposureDetectionState`
  struct UpdateLatestProcessedKeyChunkIndex: AppStateUpdater {
    let index: Int

    func updateState(_ state: inout AppState) {
      state.exposureDetection.latestProcessedKeyChunkIndex = self.index
    }
  }
}

// MARK: - Models

extension Logic.ExposureDetection {
  /// Type of Exposure Detection environment
  enum DetectionType {
    /// The detection is running in foreground
    case foreground
    /// The detection is running in background, with an associated `BackgroundTask`
    case background(BackgroundTask)

    /// The background taks associated with the detection, if any
    var backgroundTask: BackgroundTask? {
      switch self {
      case .foreground:
        return nil

      case .background(let task):
        return task
      }
    }

    /// The period for the detection
    func detectionPeriod(using configuration: Configuration) -> TimeInterval {
      switch self {
      case .foreground:
        return configuration.maximumExposureDetectionWaitingTime

      case .background:
        return configuration.exposureDetectionPeriod
      }
    }
  }
}

// MARK: - Helpers

private extension Array where Element == ExposureInfo {
  /// Most recent contact day of an array of `ExposureInfo`
  var mostRecentContactDay: CalendarDay? {
    let mostRecentDate = self
      .map { $0.date }
      .max()

    return mostRecentDate?.calendarDay
  }
}

private extension ExposureDetectionSummary {
  /// Most recent contact day of an `ExposureDetectionSummary`
  var mostRecentContactDay: CalendarDay? {
    switch self {
    case .noMatch:
      return nil
    case .matches(let data):
      return Date().calendarDay.byAdding(days: -data.daysSinceLastExposure)
    }
  }
}

// MARK: - Debugging

extension Logic.ExposureDetection {
  /// Signals that a background task has triggered a significant event.
  /// It meant to be used only for debugging, and in fact it does not do anything in production.
  struct SignalBackgroundTask: AppSideEffect {
    let outcome: ExposureDetectionOutcome
    let type: DetectionType

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      guard state.toggles.isBackgroundTaskDebugMode else {
        // Nothing to do
        return
      }

      guard case .background = self.type else {
        // Only trigger notifications for background tasks
        return
      }

      let title: String
      let message: String
      switch self.outcome {
      case .noDetectionNecessary:
        title = "Skipped"
        message = "Background task was skipped"
      case .fullDetection, .partialDetection:
        title = "Success"
        message = "Background task was performed successfully"
      case .error(.timeout):
        title = "Timeout"
        message = "Background task timed out"
      case .error(let error):
        title = "Error"
        message = "Background task resulted in error: \(error)"
      }

      context.dependencies.pushNotification.scheduleLocalNotification(
        .init(title: title, body: message),
        with: .timeInterval(5)
      )
    }
  }
}
