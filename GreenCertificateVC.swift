// GreenCertificateVC.swift
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

class GreenCertificateVC: ViewControllerWithLocalState<GreenCertificateView> {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupInteraction() {
        rootView.didTapBack = { [weak self] in
            self?.dispatch(Hide(Screen.greenCertificate, animated: true))
        }
        rootView.didSelectCell = { [unowned self] newTab in
          self.handleTap(on: newTab)
        }

        rootView.didTapDiscoverMore = { [weak self] in
            self?.dispatch(Logic.PermissionTutorial.ShowHowToUploadWhenPositiveAutonomous())
        }
        rootView.didTapActiveButton = { [weak self] in
            self?.handleTap(on: .active)
        }
        rootView.didTapExpiredButton = { [weak self] in
            self?.handleTap(on: .expired)
        }

    }
    
    func handleTap(on newTab: GreenCertificateVM.Tab) {
      guard let oldTab = self.viewModel?.selectedTab else {
        return
      }

      if oldTab != newTab {
        self.changeTab(to: newTab)
      } else {
//        if let navigationController = self.vc[newTab] as? UINavigationController {
//          navigationController.popViewController(animated: true)
//        }
      }
    }

    func changeTab(to newTab: GreenCertificateVM.Tab) {
      guard let oldTab = self.viewModel?.selectedTab,
            oldTab != newTab
      else {
        return
      }
        self.viewModel?.selectedTab = newTab

//      if let newVC = self.vc[newTab] {
//        // remove the current child
//        self.vc[oldTab]?.remove()
//
//        let traitCollectionDidChange = self.traitCollection != newVC.traitCollection
//        self.add(newVC, frame: self.rootView.frame)
//        self.dispatch(Logic.Accessibility.PostNotification(notification: .screenChanged, argument: nil))
//
//        if traitCollectionDidChange {
//          // Post a `UIContentSizeCategory.didChangeNotification` to trigger the update for subviews that adopt the
//          // `AdaptableTextContainer` protocol if trait collection did change.
//          NotificationCenter.default.post(name: UIContentSizeCategory.didChangeNotification, object: nil)
//        }
//
//        self.dispatch(Logic.Shared.UpdateSelectedTab(tab: newTab))
//      }
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

    private func verifyCun(cun: OTP, lastHisNumber: String, symptomsStartedOn: String) {
        localState.isLoading = true

        dispatch(Logic.DataUpload.VerifyCun(code: cun, lastHisNumber: lastHisNumber, symptomsStartedOn: symptomsStartedOn))
            .then {
                self.localState.isLoading = false
            }
            .catch { _ in
                self.localState.isLoading = false
            }
    }
}

// MARK: - LocalState

struct GreenCertificateLS: LocalState {
    var cun: String = ""
    var healtCard: String = ""
    var symptomsDate: String = ""
    var symptomsDateIsEnabled: Bool = true
    var asymptomaticCheckBoxIsChecked: Bool = false

    /// True if it's not possible to execute a new request.
    var isLoading: Bool = false
}
