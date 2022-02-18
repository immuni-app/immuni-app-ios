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
import CoreImage
import SwiftDGC

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
    /// Shows the alert that there is an error in saving data
    struct ShowSaveGreenCertificateErrorAlert: AppSideEffect {
        
        func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
            let model = Alert.Model(
                title: L10n.UploadData.UnauthorizedCun.title,
                message: L10n.ConfirmData.GreenCertificate.Error.Alert.title,
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
                try Hydra.await(context.dependencies.networkManager.validateOTP(self.code, requestSize: requestSize))
                try context.awaitDispatch(MarkOTPValidationSuccessfulAttempt())
            } catch NetworkManager.Error.unauthorizedOTP {
                // User is not authorized. Bubble up the error to the calling ViewController
                try Hydra.await(context.dispatch(Logic.Loading.Hide()))
                try context.awaitDispatch(MarkOTPValidationFailedAttempt(date: context.dependencies.now()))
                throw Error.verificationFailed
            } catch {
                try Hydra.await(context.dispatch(Logic.Loading.Hide()))
                try context.awaitDispatch(ShowErrorAlert(error: error, retryDispatchable: self))
                return
            }
            
            try Hydra.await(context.dispatch(Logic.Loading.Hide()))
            try context.awaitDispatch(ShowConfirmData(code: self.code))
        }
    }
    /// Generate digital green certificate
    struct GenerateDigitalGreenCertificate: AppSideEffect {
        
        let code: String
        let lastHisNumber: String
        let hisExpiringDate: String
        let codeType: CodeType
        
        enum Error: Swift.Error {
            case verificationFailed
        }
        
        func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
            let state = context.getState()
            try context.awaitDispatch(Logic.Loading.Show(message: L10n.HomeView.GenerateGreenCertificate.loading))
            
            do {
                let requestSize = state.configuration.ingestionRequestTargetSize
                let body = GenerateDgcRequest.Body(
                    lastHisNumber: lastHisNumber,
                    hisExpiringDate: hisExpiringDate,
                    tokenType: codeType.rawValue.lowercased()
                )
                let data = try Hydra.await(context.dependencies.networkManager.generateDigitalGreenCertificate(
                    body: body,
                    code: code,
                    requestSize: requestSize))
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                
                if let object = json as? [String: Any] {
                    if let qrcode = object["qrcode"] as? String {
                        let dgc = detectQRCode(qr: qrcode, dgcType: object["fglTipoDgc"] as? String)
                        if let dgc = dgc {
                            try context.awaitDispatch(Logic.CovidStatus.UpdateGreenCertificate(newGreenCertificate: dgc))
                        }
                        else {
                            try Hydra.await(context.dispatch(Logic.Loading.Hide()))
                            try context.awaitDispatch(ShowCustomErrorAlert(message: L10n.HomeView.GreenCertificate.Decode.error))
                            return
                        }
                    }
                    else {
                        try Hydra.await(context.dispatch(Logic.Loading.Hide()))
                        try context.awaitDispatch(ShowCustomErrorAlert(message: L10n.HomeView.GreenCertificate.Decode.error))
                        return
                    }
                }
                else {
                    try Hydra.await(context.dispatch(Logic.Loading.Hide()))
                    try context.awaitDispatch(ShowCustomErrorAlert(message: L10n.HomeView.GreenCertificate.Decode.error))
                    return
                }
                
            } catch NetworkManager.Error.noDgcFound {
                try Hydra.await(context.dispatch(Logic.Loading.Hide()))
                try context.awaitDispatch(ShowCustomErrorAlert(message: L10n.HomeView.GreenCertificate.Error.noDgcFound))
                return
            } catch {
                try Hydra.await(context.dispatch(Logic.Loading.Hide()))
                try context.awaitDispatch(ShowErrorAlert(error: error, retryDispatchable: self))
                return
            }
            try Hydra.await(context.dispatch(Logic.Loading.Hide()))
            
            try context.awaitDispatch(Show(Screen.confirmation, animated: true, context: ConfirmationLS.generateGreenCertificateCompleted))
            try Hydra.await(Promise<Void>(resolved: ()).defer(2))
            
            try context.awaitDispatch(Hide(Screen.confirmation, animated: true))
            try context.awaitDispatch(Hide(Screen.generateGreenCertificate, animated: true))
        }
        
        private func detectQRCode(qr: String, dgcType: String?) -> GreenCertificate? {
            let data = Data(base64Encoded: qr)
            guard let data = data else { return nil }
            let image = UIImage(data: data)
            
            if let image = image, let ciImage = CIImage.init(image: image){
                var options: [String: Any]
                let context = CIContext()
                options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
                let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
                if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                    options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
                } else {
                    options = [CIDetectorImageOrientation: 1]
                }
                let features = qrDetector?.features(in: ciImage, options: options)
                var hcert : HCert?
                var dgc: GreenCertificate? = nil
                for case let row as CIQRCodeFeature in features! {
                    hcert = HCert(from: row.messageString!)
                    guard let hcert = hcert else { return nil }
                    
                    var type: CertificateType?

                    if hcert.body["t"].count > 0 {
                        type = .test
                    }
                    else if hcert.body["v"].count > 0 {
                        type = .vaccine
                    }
                    else if hcert.body["r"].count > 0 {
                        type = .recovery
                    }
                    else if hcert.body["e"].count > 0 {
                        type = .exemption
                    }
                    else {
                        type = nil
                    }
                    guard let type = type else { return nil }
                    
                    dgc = GreenCertificate(
                        id: hcert.uvci,
                        name: "\(hcert.body["nam"]["fn"].string ?? "---") \(hcert.body["nam"]["gn"].string ?? "---")",
                        birth: hcert.dateOfBirth,
                        greenCertificate: qr,
                        certificateType: type
                    )
                    dgc?.dgcType = dgcType
                    switch type {
                    case .test:
                        let detail = DetailTestCertificate(
                            disease: TargetDisease.COVID19,
                            typeOfTest: hcert.body["t"][0]["tt"].string ?? "---",
                            testResult: hcert.body["t"][0]["tr"].string ?? "---",
                            ratTestNameAndManufacturer: hcert.body["t"][0]["ma"].string ?? "",
                            dateTimeOfSampleCollection: hcert.body["t"][0]["sc"].string ?? "---",
                            testingCentre: hcert.body["t"][0]["tc"].string ?? "---",
                            countryOfTest: hcert.body["t"][0]["co"].string ?? "---",
                            certificateIssuer: L10n.HomeView.GreenCertificate.Detail.certificateIssuer
                        )
                        dgc?.detailTestCertificate = detail
                        
                    case .vaccine:
                        let detail = DetailVaccineCertificate(
                            disease: TargetDisease.COVID19,
                            vaccineType: hcert.body["v"][0]["vp"].string ?? "---",
                            vaccineName: hcert.body["v"][0]["mp"].string ?? "---",
                            vaccineProducer: hcert.body["v"][0]["ma"].string ?? "---",
                            doseNumber: hcert.body["v"][0]["dn"].description,
                            totalSeriesOfDoses: hcert.body["v"][0]["sd"].description,
                            dateLastAdministration: hcert.body["v"][0]["dt"].string ?? "---",
                            vaccinationCuntry: hcert.body["v"][0]["co"].string ?? "---",
                            certificateAuthority: L10n.HomeView.GreenCertificate.Detail.certificateIssuer
                        )
                        dgc?.detailVaccineCertificate = detail
                        
                    case .recovery:
                        let detail = DetailRecoveryCertificate(
                            disease: TargetDisease.COVID19,
                            dateFirstTestResult: hcert.body["r"][0]["fr"].string ?? "---",
                            countryOfTest: hcert.body["r"][0]["co"].string ?? "---",
                            certificateIssuer: L10n.HomeView.GreenCertificate.Detail.certificateIssuer,
                            certificateValidFrom: hcert.body["r"][0]["df"].string ?? "---",
                            certificateValidUntil: hcert.body["r"][0]["du"].string ?? "---"
                        )
                        dgc?.detailRecoveryCertificate = detail
                    case .exemption:
                        let detail = DetailExemptionCertificate(
                            disease: TargetDisease.COVID19,
                            fiscalCodeDoctor: hcert.body["e"][0]["fc"].string ?? "---",
                            certificateValidUntil: hcert.body["e"][0]["du"].string ?? "---",
                            vaccinationCuntry: hcert.body["e"][0]["co"].string ?? "---",
                            cuev: hcert.body["e"][0]["cu"].description,
                            certificateAuthority: L10n.HomeView.GreenCertificate.Detail.certificateIssuer,
                            certificateValidFrom: hcert.body["e"][0]["df"].string ?? "---"
                        )
                        dgc?.id = hcert.body["e"][0]["ci"].description
                        dgc?.detailExemptionCertificate = detail
                    }
                    
                    return dgc
                }
            }
            return nil
        }
    }
    
    /// Save digital green certificate in gallery
    struct SaveDigitalGreenCertificate: AppSideEffect {
        
        func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
            
            try context.awaitDispatch(Show(Screen.confirmation, animated: true, context: ConfirmationLS.saveGreenCertificateCompleted))
            try Hydra.await(Promise<Void>(resolved: ()).defer(2))
            
            try context.awaitDispatch(Hide(Screen.confirmation, animated: true))
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
                try Hydra.await(context.dependencies.networkManager.validateCUN(self.code, lastHisNumber: self.lastHisNumber, symptomsStartedOn: self.symptomsStartedOn, requestSize: requestSize))
            } catch NetworkManager.Error.unauthorizedOTP {
                // User is not authorized. Bubble up the error to the calling ViewController
                try Hydra.await(context.dispatch(Logic.Loading.Hide()))
                try context.awaitDispatch(ShowCunErrorAlert(title: L10n.UploadData.VpnError.title, message: L10n.UploadData.ErrorCun.message))
                throw Error.verificationFailed
            } catch NetworkManager.Error.otpAlreadyAuthorized {
                // cun Already Authorized. Bubble up the error to the calling ViewController
                try Hydra.await(context.dispatch(Logic.Loading.Hide()))
                try context.awaitDispatch(ShowCunErrorAlert(title: L10n.UploadData.UnauthorizedCun.title, message: L10n.UploadData.UnauthorizedCun.message))
                
                throw Error.verificationFailed
            } catch {
                try Hydra.await(context.dispatch(Logic.Loading.Hide()))
                try context.awaitDispatch(ShowErrorAlert(error: error, retryDispatchable: self))
                return
            }
            try Hydra.await(context.dispatch(Logic.Loading.Hide()))
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
                keys = try Hydra.await(context.dependencies.exposureNotificationManager.getDiagnosisKeys())
                try context.awaitDispatch(Hide(Screen.permissionOverlay, animated: false))
            } catch {
                // The user declined sharing the keys.
                try context.awaitDispatch(Hide(Screen.permissionOverlay, animated: false))
                return
            }
            
            // Wait for the key window to be restored
            if #available(iOS 13.7, *) {
                try Hydra.await(context.dependencies.application.waitForWindowRestored())
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
                try Hydra.await(context.dependencies.networkManager.uploadData(body: requestBody, otp: self.code, requestSize: requestSize))
                try Hydra.await(context.dispatch(Logic.Loading.Hide()))
            } catch {
                try Hydra.await(context.dispatch(Logic.Loading.Hide()))
                try context.awaitDispatch(ShowErrorAlert(error: error, retryDispatchable: self))
                return
            }
            
            let now = context.dependencies.now()
            context.dispatch(Logic.CovidStatus.UpdateStatusWithEvent(event: .dataUpload(currentDate: now.calendarDay)))
            
            try context.awaitDispatch(Show(Screen.confirmation, animated: true, context: ConfirmationLS.uploadDataCompleted))
            try Hydra.await(Promise<Void>(resolved: ()).defer(3))
            
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
    /// Shows custom alert
    struct ShowCustomErrorAlert: AppSideEffect {
        let message: String
        func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
            let model = Alert.Model(
                title: L10n.Settings.Setting.LoadDataAutonomous.Asymptomatic.Alert.title,
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
                
            case .noDgcFound:
                title = L10n.UploadData.ApiError.title
                message = L10n.HomeView.GreenCertificate.Error.noDgcFound
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
