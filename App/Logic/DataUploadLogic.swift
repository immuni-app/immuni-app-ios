// DataUploadLogic.swift
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
import ImmuniExposureNotification
import Katana
import Models
import Networking
import Tempura

extension Logic {
  enum DataUpload {}
}

extension Logic.DataUpload {
  /// Shows the Upload Data screen
  struct ShowUploadData: AppSideEffect {
    /// A threshold to make past failed attempts expire, so that in case of another failed attempt after a long time the
    /// exponential backoff starts from the beginning
    static let recentFailedAttemptsThreshold: TimeInterval = 24 * 60 * 60

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()
      try context.awaitDispatch(RefreshOTP())

      let now = context.dependencies.now()
      let failedAttempts = state.ingestion.otpValidationFailedAttempts

      let errorSecondsLeft: Int
      let recentFailedAttempts: Int

      if
        let lastOtpFailedAttempt = state.ingestion.lastOtpValidationFailedAttempt,
        now.timeIntervalSince(lastOtpFailedAttempt) <= Self.recentFailedAttemptsThreshold {
        let backOffDuration = UploadDataLS.backOffDuration(failedAttempts: failedAttempts)
        let backOffEnd = lastOtpFailedAttempt.addingTimeInterval(TimeInterval(backOffDuration))
        errorSecondsLeft = backOffEnd.timeIntervalSince(now).roundedInt().bounded(min: 0)
        recentFailedAttempts = failedAttempts
      } else {
        errorSecondsLeft = 0
        recentFailedAttempts = 0
      }

      try context.awaitDispatch(Logic.DataUpload.SetDummyTrafficSequenceCancelled(value: true))
      let ls = UploadDataLS(recentFailedAttempts: recentFailedAttempts, errorSecondsLeft: errorSecondsLeft)
      try context.awaitDispatch(Show(Screen.uploadData, animated: true, context: ls))
    }
  }

  /// Performs the validation of the provided OTP
  struct VerifyCode: AppSideEffect {
    let code: OTP

    enum Error: Swift.Error {
      case verificationFailed
    }

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Logic.Loading.Show(message: L10n.UploadData.Verify.loading))

      do {
        try context.awaitDispatch(AssertExposureNotificationPermissionGranted())
      } catch {
        try context.awaitDispatch(Logic.Loading.Hide())
        try context.awaitDispatch(ShowMissingAuthorizationAlert())
        return
      }

      do {
        // Send the request
        try await(context.dependencies.networkManager.validateOTP(self.code))
        try context.awaitDispatch(MarkOTPValidationSuccessfulAttempt())
      } catch NetworkManager.Error.unauthorizedOTP {
        // User is not authorized. Bubble up the error to the calling ViewController
        try await(context.dispatch(Logic.Loading.Hide()))
        try context.awaitDispatch(MarkOTPValidationFailedAttempt(date: context.dependencies.now()))
        throw Error.verificationFailed
      } catch {
        try await(context.dispatch(Logic.Loading.Hide()))
        try context.awaitDispatch(ShowErrorAlert(error: error, retryDispatchable: self))
        return
      }

      try await(context.dispatch(Logic.Loading.Hide()))
      try context.awaitDispatch(ShowConfirmData(code: self.code))
    }
  }

  /// Shows the screen in which data that are uploaded are listed
  struct ShowConfirmData: AppSideEffect {
    let code: OTP

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      let shouldShowExpositionData = !state.exposureDetection.recentPositiveExposureResults.isEmpty

      let ls = ConfirmUploadLS(
        validatedCode: self.code,
        dataKindsInfo: shouldShowExpositionData
          ? [.result, .proximityData, .expositionData, .province]
          : [.result, .proximityData, .province]
      )
      try context.awaitDispatch(Show(Screen.confirmUpload, animated: true, context: ls))
    }
  }

  /// Handles the data confirmation flow
  struct ConfirmData: AppSideEffect {
    let code: OTP

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      do {
        try context.awaitDispatch(AssertExposureNotificationPermissionGranted())
      } catch {
        try context.awaitDispatch(Logic.Loading.Hide())
        try context.awaitDispatch(ShowMissingAuthorizationAlert())
        return
      }

      // Retrieve keys
      try context
        .awaitDispatch(Show(
          Screen.permissionOverlay,
          animated: true,
          context: OnboardingPermissionOverlayLS(type: .diagnosisKeys)
        ))

      let keys: [TemporaryExposureKey]
      do {
        keys = try await(context.dependencies.exposureNotificationManager.getDiagnosisKeys())
        try context.awaitDispatch(Hide(Screen.permissionOverlay, animated: false))
      } catch {
        // The user declined sharing the keys.
        try context.awaitDispatch(Hide(Screen.permissionOverlay, animated: false))
        return
      }

      // Start loading
      try context.awaitDispatch(Logic.Loading.Show(message: L10n.UploadData.SendData.loading))

      // Build the request payload
      let userProvince = state.user.province
        ?? AppLogger.fatalError("Province must be set at this point")

      let requestBody = DataUploadRequest.Body(
        teks: keys.map { .init(from: $0) },
        province: userProvince.rawValue,
        exposureDetectionSummaries: state.exposureDetection.recentPositiveExposureResults.map { $0.data }
      )

      // Send the data to the backend
      do {
        try await(context.dependencies.networkManager.uploadData(body: requestBody, otp: self.code))
        try await(context.dispatch(Logic.Loading.Hide()))
      } catch {
        try await(context.dispatch(Logic.Loading.Hide()))
        try context.awaitDispatch(ShowErrorAlert(error: error, retryDispatchable: self))
        return
      }

      let now = context.dependencies.now()
      context.dispatch(Logic.CovidStatus.UpdateStatusWithEvent(event: .dataUpload(currentDate: now.calendarDay)))

      try context.awaitDispatch(Show(Screen.confirmation, animated: true, context: ConfirmationLS.uploadDataCompleted))
      try await(Promise<Void>(resolved: ()).defer(3))

      try context.awaitDispatch(Hide(Screen.confirmation, animated: true))
      try context.awaitDispatch(Hide(Screen.confirmUpload, animated: true))
      try context.awaitDispatch(Hide(Screen.uploadData, animated: true))
    }
  }

  /// Checks that the exposure notifications permissions is authorized
  struct AssertExposureNotificationPermissionGranted: SideEffect {
    enum Error: Swift.Error {
      case noPermissionGiven
    }

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()
      guard state.environment.exposureNotificationAuthorizationStatus.isAuthorized else {
        // The user did not give permissions to exposure notification.
        throw Error.noPermissionGiven
      }
    }
  }

  /// Shows the alert that the Exposure Notification is disabled
  struct ShowMissingAuthorizationAlert: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let model = Alert.Model(
        title: L10n.UploadData.MissingAuthorization.title,
        message: L10n.UploadData.MissingAuthorization.message,
        preferredStyle: .alert,
        actions: [
          .init(title: L10n.UploadData.MissingAuthorization.close, style: .cancel),

          .init(title: L10n.UploadData.MissingAuthorization.enable, style: .default, onTap: {
            context.dispatch(Logic.PermissionTutorial.ShowActivateExposureNotificationTutorial())
          })
        ]
      )

      try context.awaitDispatch(Logic.Alert.Show(alertModel: model))
    }
  }

  /// Reusable side effect that shows a readable error when something wrong occuring
  /// while contacting the remote backend
  struct ShowErrorAlert: AppSideEffect {
    let error: Error
    let retryDispatchable: Dispatchable?

    init(error: Error, retryDispatchable: Dispatchable? = nil) {
      self.error = error
      self.retryDispatchable = retryDispatchable
    }

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let title: String
      let message: String
      let cancelAction: String

      let typedError = self.error as? NetworkManager.Error

      switch typedError {
      case .none, .connectionError:
        // Treat none as a generic connection error
        title = L10n.UploadData.ConnectionError.title
        message = L10n.UploadData.ConnectionError.message
        cancelAction = L10n.UploadData.ConnectionError.action

      case .unknownError, .badRequest, .bodyNotCompliant, .tooManyKeysUploaded, .unauthorizedOTP, .batchNotFound, .noBatchesFound,
           .otpAlreadyAuthorized:
        title = L10n.UploadData.ApiError.title
        message = L10n.UploadData.ApiError.message
        cancelAction = L10n.UploadData.ApiError.action
      }

      let model = Alert.Model(
        title: title,
        message: message,
        preferredStyle: .alert,
        actions: [
          .init(title: cancelAction, style: .cancel)
        ]
      )

      try context.awaitDispatch(Logic.Alert.Show(alertModel: model))
    }
  }
}

// MARK: - Dummy traffic

extension Logic.DataUpload {
  /// Updates the dummy ingestion traffic opportunity window taking the parameters from the Configuration and the RNGs.
  struct UpdateDummyTrafficOpportunityWindowIfExpired: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      let now = context.dependencies.now()

      guard now > state.ingestion.dummyTrafficOpportunityWindow.windowEnd else {
        // Window not started or finished yet.
        return
      }

      try context.awaitDispatch(UpdateDummyTrafficOpportunityWindow())
    }
  }

  /// Updates the dummy ingestion traffic opportunity window taking the parameters from the Configuration and the RNGs.
  struct UpdateDummyTrafficOpportunityWindow: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      let dummyTrafficStochasticDelay = context.dependencies.exponentialDistributionGenerator
        .exponentialRandom(with: state.configuration.dummyIngestionMeanStochasticDelay)

      try context.awaitDispatch(
        SetDummyTrafficOpportunityWindow(
          dummyTrafficStochasticDelay: dummyTrafficStochasticDelay,
          dummyTrafficOpportunityWindowDuration: state.configuration.dummyIngestionWindowDuration,
          now: context.dependencies.now()
        )
      )
    }
  }

  /// Schedules a sequence of dummy ingestion requests for some random point in the future.
  /// -seeAlso: https://github.com/immuni-app/immuni-documentation/blob/master/Traffic%20Analysis%20Mitigation.md
  struct ScheduleDummyIngestionSequenceIfNecessary: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      guard !state.ingestion.dummyTrafficSequenceScheduledInSession else {
        // There is already another sequence schedule for this session.
        return
      }

      // Reset the flag in case this is a new session
      try context.awaitDispatch(SetDummyTrafficSequenceCancelled(value: false))

      guard state.ingestion.dummyTrafficOpportunityWindow.contains(context.dependencies.now()) else {
        // Not within the opportunity window. Nothing to do.
        return
      }

      // Prevent other ingestion sequences from being scheduled in this session
      try context.awaitDispatch(SetDummyIngestionSequenceScheduledForThisSession(value: true))

      let startDelay = context.dependencies.exponentialDistributionGenerator
        .exponentialRandom(with: state.configuration.dummyIngestionAverageStartUpDelay)

      // Dispatch a delayed action and return
      context.dispatch(StartIngestionSequenceIfNotCancelled().deferred(of: startDelay))
    }
  }

  /// Attempts a simulated sequence of ingestion requests, unless it was cancelled for outside in the meanwhile.
  /// -seeAlso: https://github.com/immuni-app/immuni-documentation/blob/master/Traffic%20Analysis%20Mitigation.md
  struct StartIngestionSequenceIfNotCancelled: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      var executions = 0
      while true {
        // Fetch the state at every run because it might have been updated in the meanwhile
        let state = context.getState()

        guard !state.ingestion.isDummyTrafficSequenceCancelled else {
          // The user signaled the intent of starting a genuine upload.
          break
        }

        #warning("Define proper dummy request")
        try? await(context.dependencies.networkManager.uploadData(body: .dummy(), otp: .init()))

        let diceRoll = context.dependencies.uniformDistributionGenerator.randomNumberBetweenZeroAndOne()
        let threshold = state.configuration.dummyIngestionRequestProbabilities[safe: executions]
          ?? state.configuration.dummyIngestionRequestProbabilities.last
          ?? AppLogger.fatalError("No probabilities defined")

        guard diceRoll < threshold else {
          // The generated probability was above the threshold.
          break
        }

        let interRequestDelay = context.dependencies.exponentialDistributionGenerator
          .exponentialRandom(with: state.configuration.dummyIngestionAverageRequestWaitingTime)

        // Await for a random time
        try await(Promise<Void>.deferring(of: interRequestDelay))
        executions += 1
      }

      // Allow the scheduling of another session.
      try context.awaitDispatch(SetDummyIngestionSequenceScheduledForThisSession(value: false))

      // Update the opportunity window
      try context.awaitDispatch(UpdateDummyTrafficOpportunityWindow())
    }
  }
}

// MARK: - StateUpdaters

extension Logic.DataUpload {
  /// Refreshes the OTP
  struct RefreshOTP: AppStateUpdater {
    func updateState(_ state: inout AppState) {
      state.ingestion.otp = OTP()
    }
  }

  /// Handles a failed OTP validation attempt
  struct MarkOTPValidationFailedAttempt: AppStateUpdater {
    let date: Date

    func updateState(_ state: inout AppState) {
      state.ingestion.lastOtpValidationFailedAttempt = self.date
      state.ingestion.otpValidationFailedAttempts += 1
    }
  }

  /// Handles a successful OTP validation attempt
  struct MarkOTPValidationSuccessfulAttempt: AppStateUpdater {
    func updateState(_ state: inout AppState) {
      state.ingestion.lastOtpValidationFailedAttempt = nil
      state.ingestion.otpValidationFailedAttempts = 0
    }
  }

  /// Sets the opportunity window for the dummy ingestion traffic
  struct SetDummyTrafficOpportunityWindow: AppStateUpdater {
    let dummyTrafficStochasticDelay: Double
    let dummyTrafficOpportunityWindowDuration: Double
    let now: Date

    func updateState(_ state: inout AppState) {
      let windowStart = self.now.addingTimeInterval(self.dummyTrafficStochasticDelay)
      let windowDuration = self.dummyTrafficOpportunityWindowDuration
      state.ingestion.dummyTrafficOpportunityWindow = .init(windowStart: windowStart, windowDuration: windowDuration)
    }
  }

  /// Marks a dummy traffic sequence as cancelled
  struct SetDummyTrafficSequenceCancelled: AppStateUpdater {
    let value: Bool

    func updateState(_ state: inout AppState) {
      state.ingestion.isDummyTrafficSequenceCancelled = self.value
    }
  }

  /// Signals that a dummy traffic sequence is already scheduled for this session
  struct SetDummyIngestionSequenceScheduledForThisSession: AppStateUpdater {
    let value: Bool

    func updateState(_ state: inout AppState) {
      state.ingestion.dummyTrafficSequenceScheduledInSession = self.value
    }
  }

  /// Handles the end of a foreground session
  struct MarkForegroundSessionFinished: AppStateUpdater {
    func updateState(_ state: inout AppState) {
      state.ingestion.dummyTrafficSequenceScheduledInSession = false
      state.ingestion.isDummyTrafficSequenceCancelled = true
    }
  }
}

// MARK: - Helpers

private extension CodableTemporaryExposureKey {
  init(from native: TemporaryExposureKey) {
    self.init(
      keyData: native.keyData,
      rollingStartNumber: Int(native.rollingStartNumber),
      rollingPeriod: Int(native.rollingPeriod)
    )
  }
}
