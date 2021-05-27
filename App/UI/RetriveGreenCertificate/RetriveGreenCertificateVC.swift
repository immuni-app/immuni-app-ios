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
            var code: String?
            if let codeType = self.localState.codeType {
                code = self.validateCode(code: self.localState.code, codeType: codeType)
                if self.localState.code == "" {
                    message += L10n.Settings.Setting.LoadDataAutonomous.FormError.Cun.message
                } else if code == nil {
                    message += L10n.Settings.Setting.LoadDataAutonomous.FormError.Cun.Invalid.message
                }
            }
            else {
                message += "- Inserire la tipologia del codice\n"
                message += L10n.Settings.Setting.LoadDataAutonomous.FormError.Cun.message
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
                guard let code = code, let codeType = self.localState.codeType else { return }
                self.verifyCode(code: code, codeType: codeType, lastHisNumber: self.localState.healtCard, healthCardDate: self.localState.healtCardDate)
            }
        }

        rootView.didTapDiscoverMore = { [weak self] in
            self?.dispatch(Logic.PermissionTutorial.ShowHowToRetriveDigitalGreenCertificate())
        }
        rootView.didChangeCodeValue = { [weak self] value in
            self?.localState.code = self?.localState.codeType == .nrfe ? value : value.uppercased()
        }
        rootView.didChangeHealthCardValue = { [weak self] value in
            self?.localState.healtCard = value
        }
        rootView.didChangeHealthCardDateValue = { [weak self] value in
            self?.localState.healtCardDate = value
        }
        rootView.didChangeCodeType = { [weak self] value in
            self?.localState.code = ""
            self?.localState.codeType = value
        }
    }
    
    private func validateCode(code: String?, codeType: CodeType) -> String? {
        guard let code = code else {
            return nil
        }
        switch codeType {
          case .nrfe:
            return self.validateNrfe(code: code)

          case .cun:
            return self.validateCun(code: code)

          case .nucg:
            return self.validateNucg(code: code)

          case .otp:
            return self.validateOtp(code: code)
        }
    }

    private func validateCun(code: String?) -> String? {
        guard let code = code else {
            return nil
        }
        if code != "", code.count == CodeType.lengthCun {
            let cun = OTP(code: code)
            if cun.verifyCode() {
                return cun.rawValue
            }
        }
        return nil
    }
    
    private func validateOtp(code: String?) -> String? {
        guard let code = code else {
            return nil
        }
        if code != "", code.count == CodeType.lengthOtp {
            let otp = AuthCodeOtp(code: code)
            if otp.verifyCode() {
                return otp.rawValue
            }
        }
        return nil
    }
    
    private func validateNucg(code: String?) -> String? {
        guard let code = code else {
            return nil
        }
        if code != "", code.count == CodeType.lengthNucg {
            let nucg = Nucg(code: code)
            if nucg.verifyCode() {
                return nucg.rawValue
            }
        }
        return nil
    }
    
    private func validateNrfe(code: String?) -> String? {
        guard let code = code else {
            return nil
        }
        if code != "", code.count == CodeType.lengthNrfe, code.hasPrefix("99")  {
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

    private func verifyCode(code: String, codeType: CodeType, lastHisNumber: String, healthCardDate: String) {
        localState.isLoading = true

        dispatch(Logic.DataUpload.RetriveDigitalGreenCertificate(code: code, lastHisNumber: lastHisNumber, healthCardDate: healthCardDate, codeType: codeType))
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
    
    public static let prefixNrfe = ""
    public static let prefixCun = "CUN-"
    public static let prefixNucg = "NUCG-"
    public static let prefixOtp = ""
    
    public static let lengthNrfe = 17
    public static let lengthCun = 10
    public static let lengthNucg = 10
    public static let lengthOtp = 12

    case nrfe = "NRFE"
    case cun = "CUN"
    case nucg = "NUCG"
    case otp = "OTP"
    
    static func getCodeList() -> [String] {
        return [CodeType.nrfe.rawValue, CodeType.cun.rawValue, CodeType.nucg.rawValue, CodeType.otp.rawValue]
    }
}

