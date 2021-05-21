// RetriveGreenCertificateVC.swift
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
import Models
import Tempura

class RetriveGreenCertificateVC: ViewControllerWithLocalState<RetriveGreenCertificateView> {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupInteraction() {
        rootView.didTapBack = { [weak self] in
            self?.dispatch(Hide(Screen.retriveGreenCertificate, animated: true))
        }

        rootView.didTapActionButton = { [weak self] in

            guard let self = self else {
                return
            }
            var message = ""
            let code = self.validateCun(cun: self.localState.code)
            if self.localState.code == "" {
                message += L10n.Settings.Setting.LoadDataAutonomous.FormError.Cun.message
            } else if code == nil {
                message += L10n.Settings.Setting.LoadDataAutonomous.FormError.Cun.Invalid.message
            }
            if !self.validateHealthCard(healthCard: self.localState.healtCard) {
                message += L10n.Settings.Setting.LoadDataAutonomous.FormError.HealtCard.message
            }
            if !self.validateHealthCardDate(date: self.localState.healtCardDate) {
                message += L10n.Settings.Setting.LoadDataAutonomous.FormError.SymptomsDate.message
            }
            if message != "" {
                self.dispatch(Logic.DataUpload.ShowAutonomousUploadErrorAlert(message: message))
                return
            } else {
                self.verifyCode(code: code!.rawValue, lastHisNumber: self.localState.healtCard, healthCardDate: self.localState.healtCardDate)
            }
        }

        rootView.didTapDiscoverMore = { [weak self] in
            self?.dispatch(Logic.PermissionTutorial.ShowHowToRetriveDigitalGreenCertificate())
        }
        rootView.didChangeCodeValue = { [weak self] value in
            self?.localState.code = value
        }
        rootView.didChangeHealthCardValue = { [weak self] value in
            self?.localState.healtCard = value
        }
        rootView.didChangeHealthCardDateValue = { [weak self] value in
            self?.localState.healtCardDate = value
        }
        rootView.didChangeCodeType = { [weak self] value in
            self?.localState.codeType = value
        }
    }

    private func validateCun(cun: String?) -> OTP? {
        guard let cun = cun else {
            return nil
        }
        if cun != "", cun.count == 10 {
            let otp = OTP(cun: cun)
            if otp.verifyCun() {
                return otp
            }
        }
        return nil
    }
    
    private func validateNucg(code: String?) -> String? {
        guard let code = code else {
            return nil
        }
        if code != "", code.count == CodeType.lengthNucg {
            return code
        }
        return nil
    }
    
    private func validateNrfe(code: String?) -> String? {
        guard let code = code else {
            return nil
        }
        if code != "", code.count == CodeType.lengthNrfe {
            return code
        }
        return nil
    }

    private func validateHealthCardDate(date: String?) -> Bool {
        guard let date = date else {
            return false
        }
        if date != "" {
            return true
        }
        return false
    }

    private func validateHealthCard(healthCard: String?) -> Bool {
        guard let healthCard = healthCard else {
            return false
        }
        if healthCard != "", healthCard.isNumeric, healthCard.count == 8 {
            return true
        }
        return false
    }

    private func verifyCode(code: String, lastHisNumber: String, healthCardDate: String) {
        localState.isLoading = true

        dispatch(Logic.DataUpload.VerifyCodeGreenCertificate(code: code, lastHisNumber: lastHisNumber, healthCardDate: healthCardDate))
            .then {
                self.localState.isLoading = false
            }
            .catch { _ in
                self.localState.isLoading = false
            }
    }
}

// MARK: - LocalState

struct RetriveGreenCertificateLS: LocalState {
    var code: String = ""
    var healtCard: String = ""
    var healtCardDate: String = ""
    var codeType: CodeType?

    /// True if it's not possible to execute a new request.
    var isLoading: Bool = false
}
public enum CodeType: String {
    
    public static let prefixNrfe = "NRFE-"
    public static let prefixCun = "CUN-"
    public static let prefixNucg = "NUCG-"
    public static let prefixOtp = "OTP-"
    
    public static let lengthNrfe = 11
    public static let lengthCun = 10
    public static let lengthNucg = 9
    public static let lengthOtp = 8

    case nrfe = "NRFE"
    case cun = "CUN"
    case nucg = "NUCG"
    case otp = "OTP"
    
    static func getCodeList() -> [String] {
        return [CodeType.nrfe.rawValue, CodeType.cun.rawValue, CodeType.nucg.rawValue, CodeType.otp.rawValue]
    }
}

