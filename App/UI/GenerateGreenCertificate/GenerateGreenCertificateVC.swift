// GenerateGreenCertificateVC.swift
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

class GenerateGreenCertificateVC: ViewControllerWithLocalState<GenerateGreenCertificateView> {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupInteraction() {
        rootView.didTapBack = { [weak self] in
            self?.dispatch(Hide(Screen.generateGreenCertificate, animated: true))
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
                    switch codeType {
                      case .cun:
                        message += L10n.HomeView.GenerateGreenCertificate.FormError.codeCunRequired
                      case .nrfe:
                        message += L10n.HomeView.GenerateGreenCertificate.FormError.codeNrfeRequired
                      case .nucg:
                        message += L10n.HomeView.GenerateGreenCertificate.FormError.codeNucgRequired
                      case .cuev:
                        message += L10n.HomeView.GenerateGreenCertificate.FormError.codeCuevRequired
                      case .authcode:
                        message += L10n.HomeView.GenerateGreenCertificate.FormError.codeAuthcodeRequired
                    }
                } else if code == nil {
                    switch codeType {
                      case .cun:
                        message += L10n.HomeView.GenerateGreenCertificate.FormError.codeCunWrong
                      case .nrfe:
                        message += L10n.HomeView.GenerateGreenCertificate.FormError.codeNfreWrong
                      case .nucg:
                        message += L10n.HomeView.GenerateGreenCertificate.FormError.codeNucgWrong
                      case .cuev:
                        message += L10n.HomeView.GenerateGreenCertificate.FormError.codeCuevWrong
                      case .authcode:
                        message += L10n.HomeView.GenerateGreenCertificate.FormError.codeAuthcodeWrong
                    }
                }
            }
            else {
                message += L10n.HomeView.GenerateGreenCertificate.FormError.codeTypeRequired
            }
            if !self.validateHealthCard(healthCard: self.localState.healtCard) {
                message += L10n.HomeView.GenerateGreenCertificate.FormError.healthCardRequired
            }
            if !self.validateHealthCardDate(date: self.localState.hisExpiringDate) {
                message += L10n.HomeView.GenerateGreenCertificate.FormError.healthCardDateRequired
            }
            
            if message != "" {
                self.dispatch(Logic.DataUpload.ShowAutonomousUploadErrorAlert(message: message))
                return
            } else {
                guard let code = code, let codeType = self.localState.codeType else { return }
                self.generateDgc(code: code, codeType: codeType, lastHisNumber: self.localState.healtCard, hisExpiringDate: self.localState.hisExpiringDate)
            }
        }

        rootView.didTapDiscoverMore = { [weak self] in
            self?.dispatch(Logic.PermissionTutorial.ShowHowToGenerateDigitalGreenCertificate())
        }
        rootView.didChangeCodeValue = { [weak self] value in
            self?.localState.code = self?.localState.codeType == .nrfe ? value : value.uppercased()
        }
        rootView.didChangeHealthCardValue = { [weak self] value in
            self?.localState.healtCard = value
        }
        rootView.didChangeHealthCardDateValue = { [weak self] value in
            self?.localState.hisExpiringDate = value
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
            return CodeType.validateNrfe(code: code)

          case .cun:
            return CodeType.validateCun(code: code)

          case .nucg:
            return CodeType.validateNucg(code: code)

          case .authcode:
            return CodeType.validateAuthcode(code: code)
            
        case .cuev:
          return CodeType.validateCuev(code: code)
        }
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

    private func generateDgc(code: String, codeType: CodeType, lastHisNumber: String, hisExpiringDate: String) {
        localState.isLoading = true

      self.__unsafeDispatch(Logic.DataUpload.GenerateDigitalGreenCertificate(code: code, lastHisNumber: lastHisNumber, hisExpiringDate: hisExpiringDate, codeType: codeType))
            .then {
                self.localState.isLoading = false
            }
            .catch { _ in
                self.localState.isLoading = false
            }
    }
}

// MARK: - LocalState

struct GenerateGreenCertificateLS: LocalState {
    var code: String = ""
    var healtCard: String = ""
    var hisExpiringDate: String = ""
    var codeType: CodeType?

    /// True if it's not possible to execute a new request.
    var isLoading: Bool = false
}
public enum CodeType: String {
    
    public static let prefixNrfe = ""
    public static let prefixCun = "CUN-"
    public static let prefixNucg = "NUCG-"
    public static let prefixAuthcode = ""
    public static let prefixCuev = "CUEV-"

    public static let lengthNrfe = 17
    public static let lengthCun = 10
    public static let lengthNucg = 10
    public static let lengthAuthcode = 12
    public static let lengthCuev = 10

    case nrfe = "NRFE"
    case cun = "CUN"
    case nucg = "NUCG"
    case authcode = "AUTHCODE"
    case cuev = "CUEV"

    static func getCodeList() -> [String] {
        return [
            CodeType.authcode.rawValue,
            CodeType.nrfe.rawValue,
            CodeType.cun.rawValue,
            CodeType.nucg.rawValue,
            CodeType.cuev.rawValue
        ]
    }
    static func validateCun(code: String?) -> String? {
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
    
    static func validateAuthcode(code: String?) -> String? {
        guard let code = code else {
            return nil
        }
        if code != "", code.count == CodeType.lengthAuthcode {
            let authcode = Authcode(code: code)
            if authcode.verifyCode() {
                return authcode.rawValue
            }
        }
        return nil
    }
    
    static func validateNucg(code: String?) -> String? {
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
    
    static func validateCuev(code: String?) -> String? {
        guard let code = code else {
            return nil
        }
        if code != "", code.count == CodeType.lengthCuev {
            let cuev = Cuev(code: code)
            if cuev.verifyCode() {
                return cuev.rawValue
            }
        }
        return nil
    }
    
    static func validateNrfe(code: String?) -> String? {
        guard let code = code else {
            return nil
        }
        if code != "", code.count == CodeType.lengthNrfe, code.hasPrefix("99")  {
            return code
        }
        return nil
    }
}

