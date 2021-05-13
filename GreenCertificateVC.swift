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
        
        rootView.didTapGenerate = { [weak self] in
            self?.changeStatus()

        }
        rootView.didTapDiscoverMore = { [weak self] in
            self?.dispatch(Logic.PermissionTutorial.ShowHowToUploadWhenPositiveAutonomous())
        }

    }
    func changeStatus() {
        self.dispatch(Logic.Home.ShowRetriveGreenCertificate())

      guard let oldStatus = self.viewModel?.status else {
        return
      }
        if oldStatus == .active {
            self.viewModel?.status = .inactive
      }
        else{
            self.viewModel?.status = .active
        }
    }
    
    func handleTap(on newStatus: GreenCertificateVM.StatusGreenCertificate) {
      guard let oldStatus = self.viewModel?.status else {
        return
      }
      if oldStatus != newStatus {
        self.viewModel?.status = newStatus
      }
    }

}

// MARK: - LocalState

struct GreenCertificateLS: LocalState {
    
    var greenCertificate: String?

    /// True if it's not possible to execute a new request.
    var isLoading: Bool = false
}
