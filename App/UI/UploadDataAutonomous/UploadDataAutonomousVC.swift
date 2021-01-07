// UploadDataAutonomousVC.swift
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

class UploadDataAutonomousVC: ViewControllerWithLocalState<UploadDataAutonomousView> {
    override func viewDidLoad() {
        super.viewDidLoad()
        startCountDownIfNecessary()
    }

    override func setupInteraction() {
        rootView.didTapBack = { [weak self] in
            self?.dispatch(Hide(Screen.uploadDataAutonomous, animated: true))
        }

        rootView.didTapVerifyCode = { [weak self] in

            guard let self = self else {
                return
            }

            guard let code = self.viewModel?.code else {
                return
            }

            print("cun", self.localState.cun.description)
            print("healthCard", self.localState.healtCard.description)
            print("symptomsDate", self.localState.symptomsDate.description)

            var message = ""
            if !self.validateCun(cun: self.localState.cun) {
                message += L10n.Settings.Setting.LoadDataAutonomous.FormError.Cun.message
            }
            if !self.validateHealthCard(healthCard: self.localState.healtCard) {
                message += L10n.Settings.Setting.LoadDataAutonomous.FormError.HealtCard.message
            }
            if !self.validateSymptomsDate(date: self.localState.symptomsDate) {
                message += L10n.Settings.Setting.LoadDataAutonomous.FormError.SymptomsDate.message
            }
            if message != "" {
                self.dispatch(Logic.DataUpload.ShowAutonomousUploadErrorAlert(message: message))
                return
            }

//            self.verifyCode(code: code)
        }

        rootView.didTapDiscoverMore = { [weak self] in
            self?.dispatch(Logic.PermissionTutorial.ShowHowToUploadWhenPositiveAutonomous())
        }
        rootView.didChangeCunTextValue = { [weak self] value in
            self?.localState.cun = value
        }
        rootView.didChangeHealthCardTextValue = { [weak self] value in
            self?.localState.healtCard = value
        }
        rootView.didChangeSymptomsDateValue = { [weak self] value in
            self?.localState.symptomsDate = value
        }
    }

    private func validateCun(cun: String?) -> Bool {
        guard let cun = cun else {
            return false
        }
        if cun != "", cun.count == 10, cun.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) == nil {
            return true
        }
        return false
    }

    private func validateSymptomsDate(date: String?) -> Bool {
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

    private func verifyCode(code: OTP) {
        localState.isLoading = true

        dispatch(Logic.DataUpload.VerifyCode(code: code))
            .then {
                self.localState.isLoading = false
                self.localState.recentFailedAttempts = 0
            }
            .catch { _ in
                self.localState.isLoading = false
                self.localState.recentFailedAttempts += 1
                self.localState.errorSecondsLeft = UploadDataLS.backOffDuration(failedAttempts: self.localState.recentFailedAttempts)
                self.startCountDownIfNecessary()
//          self.dispatch(Logic.Accessibility.PostNotification(
//            notification: .layoutChanged,
//            argument: self.rootView.verifyCard.error
//          ))
            }
    }

    private func startCountDownIfNecessary() {
        countdown(from: localState.errorSecondsLeft)
    }

    private func countdown(from value: Int) {
        localState.errorSecondsLeft = value
        guard value > 0 else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.countdown(from: value - 1)
        }
    }
}

extension String {
    var isNumeric: Bool {
        guard count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}

// MARK: - LocalState

struct UploadDataAutonomousLS: LocalState {
    var cun: String = ""
    var healtCard: String = ""
    var symptomsDate: String = ""

    /// True if it's not possible to execute a new request.
    var isLoading: Bool = false
    /// The number of recently failed attempts. Used to evaluate the backoff duration.
    var recentFailedAttempts: Int
    /// The number of seconds until a new request can be performed.
    var errorSecondsLeft: Int

    /// Exponential backoff capped at 30 minutes
    static func backOffDuration(failedAttempts: Int) -> Int {
        let exponent = min(failedAttempts, 60) // avoid Int overflow
        return (Int(pow(2, Double(exponent - 1))) * 5).bounded(max: 30 * 60)
    }
}
