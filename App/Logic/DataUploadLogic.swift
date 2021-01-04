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
      try context.awaitDispatch(RefreshOTP())

      let state = context.getState()
      let now = context.dependencies.now()
      let failedAttempts = state.ingestion.otpValidationFailedAttempts

      let errorSecondsLeft: Int
      let recentFailedAttempts: Int

      if
        let lastOtpFailedAttempt = state.ingestion.lastOtpValidationFailedAttempt,
        now.timeIntervalSince(lastOtpFailedAttempt) <= Self.recentFailedAttemptsThreshold
      {
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
  /// Shows the  UploadDataAutonomousVC screen
  struct ShowUploadDataAutonomous: AppSideEffect {
    /// A threshold to make past failed attempts expire, so that in case of another failed attempt after a long time the
    /// exponential backoff starts from the beginning
    static let recentFailedAttemptsThreshold: TimeInterval = 24 * 60 * 60
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        try context.awaitDispatch(RefreshOTP())

        let state = context.getState()
        let now = context.dependencies.now()
        let failedAttempts = state.ingestion.otpValidationFailedAttempts

        let errorSecondsLeft: Int
        let recentFailedAttempts: Int

        if
          let lastOtpFailedAttempt = state.ingestion.lastOtpValidationFailedAttempt,
          now.timeIntervalSince(lastOtpFailedAttempt) <= Self.recentFailedAttemptsThreshold
        {
          let backOffDuration = UploadDataLS.backOffDuration(failedAttempts: failedAttempts)
          let backOffEnd = lastOtpFailedAttempt.addingTimeInterval(TimeInterval(backOffDuration))
          errorSecondsLeft = backOffEnd.timeIntervalSince(now).roundedInt().bounded(min: 0)
          recentFailedAttempts = failedAttempts
        } else {
          errorSecondsLeft = 0
          recentFailedAttempts = 0
        }

        try context.awaitDispatch(Logic.DataUpload.SetDummyTrafficSequenceCancelled(value: true))
        let ls = UploadDataAutonomousLS(recentFailedAttempts: recentFailedAttempts, errorSecondsLeft: errorSecondsLeft)
        try context.awaitDispatch(Show(Screen.uploadDataAutonomous, animated: true, context: ls))
          }
        }
    /// Shows the  Choose Data Upload Mode screen
  struct ShowChooseDataUploadMode: AppSideEffect {
        
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {

        try context.awaitDispatch(Show(Screen.chooseDataUploadMode, animated: true, context: ChooseDataUploadModeLS()))
         }
       }
    
    /// Shows the alert that there is an error in loading data
  struct ShowAutonomousUploadErrorAlert: AppSideEffect {
    let message: String
    
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
    
    let model = Alert.Model(
        title: L10n.Settings.Setting.LoadDataAutonomous.FormError.title,
        message: message,
        preferredStyle: .alert,
        actions: [
            .init(title: L10n.UploadData.ApiError.action, style: .cancel)
        ]
    )

    try context.awaitDispatch(Logic.Alert.Show(alertModel: model))
    }
}
    
  /// Performs the validation of the provided OTP
  struct VerifyCode: AppSideEffect {
    let code: OTP

    enum Error: Swift.Error {
      case verificationFailed
    }

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()
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
        let requestSize = state.configuration.ingestionRequestTargetSize
        try await(context.dependencies.networkManager.validateOTP(self.code, requestSize: requestSize))
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
        try context.awaitDispatch(ShowMissingAuthorizationAlert())
        return
      }

      // Retrieve keys
      if #available(iOS 13.7, *) {
        // The new UX in iOS 13.7 is a full screen controller from Apple.
        // It doesn't make sense to show a custom-made overlay here, so we just don't trigger it.
        // Note: since `Hide` is idempotent, there is no need to handle it.
      } else {
        try context
          .awaitDispatch(Show(
            Screen.permissionOverlay,
            animated: true,
            context: OnboardingPermissionOverlayLS(type: .diagnosisKeys)
          ))
      }

      let keys: [TemporaryExposureKey]
      do {
        keys = try await(context.dependencies.exposureNotificationManager.getDiagnosisKeys())
        try context.awaitDispatch(Hide(Screen.permissionOverlay, animated: false))
      } catch {
        // The user declined sharing the keys.
        try context.awaitDispatch(Hide(Screen.permissionOverlay, animated: false))
        return
      }

      // Wait for the key window to be restored
      if #available(iOS 13.7, *) {
        try await(context.dependencies.application.waitForWindowRestored())
      }

      // Start loading
      try context.awaitDispatch(Logic.Loading.Show(message: L10n.UploadData.SendData.loading))

      // Build the request payload
      let userProvince = state.user.province
        ?? AppLogger.fatalError("Province must be set at this point")

      let requestBody = DataUploadRequest.Body(
        teks: keys.map { .init(from: $0) },
        province: userProvince.rawValue,
        exposureDetectionSummaries: state.exposureDetection.recentPositiveExposureResults.map { $0.data },
        maximumExposureInfoCount: state.configuration.dataUploadMaxExposureInfoCount,
        maximumExposureDetectionSummaryCount: state.configuration.dataUploadMaxSummaryCount,
        countriesOfInterest: state.exposureDetection.countriesOfInterest.map { $0.country }
      )

      // Send the data to the backend
      do {
        let requestSize = state.configuration.ingestionRequestTargetSize
        try await(context.dependencies.networkManager.uploadData(body: requestBody, otp: self.code, requestSize: requestSize))
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
      try context.awaitDispatch(Hide(Screen.uploadDataAutonomous, animated: true))
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

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let title: String
      let message: String
      let cancelAction: String

      let typedError = self.error as? NetworkManager.Error

      switch typedError {
      case .none:
        // Treat none as a generic connection error
        title = L10n.UploadData.ConnectionError.title
        message = L10n.UploadData.ConnectionError.message
        cancelAction = L10n.UploadData.ConnectionError.action

      case .connectionError:
        title = L10n.UploadData.VpnError.title
        message = L10n.UploadData.VpnError.message
        cancelAction = L10n.UploadData.VpnError.action

      case .unknownError, .badRequest, .unauthorizedOTP, .batchNotFound, .noBatchesFound, .otpAlreadyAuthorized:
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

private extension UIApplication {
  // The new UX in iOS 13.7 switches the whole UIWindow instead of just presenting an alert. This has the effect of
  // breaking Tempura's internal navigation logic until the key window is restored.
  // As a workaround, the app now waits for the key window to go back to its original instance
  func waitForWindowRestored() -> Promise<Void> {
    if NSClassFromString("XCTest") != nil {
      // testing, just mock the execution
      return Promise(resolved: ())
    }

    return Promise<Void>(in: .main) { resolve, _, _ in
      self.pollWindowRestored(onRestored: resolve)
    }
  }

  func pollWindowRestored(onRestored: @escaping Promise<Void>.Resolved) {
    let appDelegate = self.delegate as? AppDelegate
    let isWindowRestored = mainThread { self.sceneAwareKeyWindow == appDelegate?.window }

    guard !isWindowRestored else {
      onRestored(())
      return
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.pollWindowRestored(onRestored: onRestored)
    }
  }

  var sceneAwareKeyWindow: UIWindow? {
    return self.windows.first(where: \.isKeyWindow)
  }
}
