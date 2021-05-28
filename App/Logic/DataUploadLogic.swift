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
    let callCenterMode: Bool

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
        let ls = UploadDataLS(recentFailedAttempts: recentFailedAttempts, errorSecondsLeft: errorSecondsLeft, callCenterMode: self.callCenterMode)
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

        try context.awaitDispatch(Logic.DataUpload.SetDummyTrafficSequenceCancelled(value: true))
        
        try context.awaitDispatch(Show(Screen.uploadDataAutonomous, animated: true, context: UploadDataAutonomousLS()))
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
    /// Retrive digital green certificate
    struct RetriveDigitalGreenCertificate: AppSideEffect {
      let code: String
      let lastHisNumber: String
      let healthCardDate: String
      let codeType: CodeType

      enum Error: Swift.Error {
        case verificationFailed
      }

      func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        var state = context.getState()
        try context.awaitDispatch(Logic.Loading.Show(message: L10n.HomeView.RetriveGreenCertificate.loading))

        do {
            var codeWithPrefix: String
            switch codeType {
              case .nucg:
                codeWithPrefix = CodeType.prefixNucg + code
              case .cun:
                codeWithPrefix = code
              case .nrfe:
                codeWithPrefix = code
              case .otp:
                codeWithPrefix = code
            }

            let data = try await(context.dependencies.networkManager.retriveDigitalGreenCertificate(tokenType: codeType.rawValue.lowercased(), lastHisNumber: lastHisNumber, healthCardDate: healthCardDate, code: codeWithPrefix))
            
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any]
          let dgc = "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"
          try context.awaitDispatch(Logic.CovidStatus.UpdateGreenCertificate(newGreenCertificate: dgc))

          } catch {
            try await(context.dispatch(Logic.Loading.Hide()))
            try context.awaitDispatch(ShowErrorAlert(error: error, retryDispatchable: self))
            return
          }
        try await(context.dispatch(Logic.Loading.Hide()))

        try context.awaitDispatch(Show(Screen.confirmation, animated: true, context: ConfirmationLS.retriveGreenCertificateCompleted))
        try await(Promise<Void>(resolved: ()).defer(2))

        try context.awaitDispatch(Hide(Screen.confirmation, animated: true))
        try context.awaitDispatch(Hide(Screen.retriveGreenCertificate, animated: true))
        }
      }
   
  /// Performs the validation of the provided OTP
  struct VerifyCun: AppSideEffect {
    let code: OTP
    let lastHisNumber: String
    let symptomsStartedOn: String

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
        try await(context.dependencies.networkManager.validateCUN(self.code, lastHisNumber: self.lastHisNumber, symptomsStartedOn: self.symptomsStartedOn, requestSize: requestSize))
        } catch NetworkManager.Error.unauthorizedOTP {
          // User is not authorized. Bubble up the error to the calling ViewController
          try await(context.dispatch(Logic.Loading.Hide()))
            try context.awaitDispatch(ShowCunErrorAlert(title: L10n.UploadData.VpnError.title, message: L10n.UploadData.ErrorCun.message))
          throw Error.verificationFailed
        } catch NetworkManager.Error.otpAlreadyAuthorized {
            // cun Already Authorized. Bubble up the error to the calling ViewController
            try await(context.dispatch(Logic.Loading.Hide()))
            try context.awaitDispatch(ShowCunErrorAlert(title: L10n.UploadData.UnauthorizedCun.title, message: L10n.UploadData.UnauthorizedCun.message))
              
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
    
  /// Shows the alert that error Cun
  struct ShowCunErrorAlert: AppSideEffect {
    let title: String
    let message: String
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let model = Alert.Model(
        title: title,
        message: message,
        preferredStyle: .alert,
        actions: [
          .init(title: L10n.UploadData.ApiError.action, style: .cancel),
          ]
        )
      try context.awaitDispatch(Logic.Alert.Show(alertModel: model))
      }
    }

  /// Shows the alert that Asymptomatic warning
  struct ShowAsymptomaticAlert: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
    let model = Alert.Model(
        title: L10n.Settings.Setting.LoadDataAutonomous.Asymptomatic.Alert.title,
        message: L10n.Settings.Setting.LoadDataAutonomous.Asymptomatic.Alert.message,
        preferredStyle: .alert,
        actions: [
        .init(title: L10n.UploadData.ApiError.action, style: .cancel),
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
