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
        
        rootView.didTapRetriveGreenCertificate = { [weak self] in
            self?.dispatch(Logic.Home.ShowRetriveGreenCertificate())
        }
        rootView.didTapDeleteGreenCertificate = { [weak self] in
            let deleteConfirmBox = UIAlertController(
                title: L10n.HomeView.GreenCertificate.Confirm.title,
                message: L10n.HomeView.GreenCertificate.Confirm.messagge,
                preferredStyle: UIAlertController.Style.alert
            )
            deleteConfirmBox.addAction(UIAlertAction(title: L10n.confirm, style: .default, handler: { (_: UIAlertAction!) in
                self?.dispatch(Logic.Home.DeleteGreenCertificate())
            }))
            deleteConfirmBox.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
            self?.present(deleteConfirmBox, animated: true, completion: nil)
            
        }
        rootView.didTapDiscoverMore = { [weak self] in
            self?.dispatch(Logic.PermissionTutorial.ShowHowToUploadWhenPositiveAutonomous())
        }

    }
}

// MARK: - LocalState

struct GreenCertificateLS: LocalState {
    
    var greenCertificate: String?

    /// True if it's not possible to execute a new request.
    var isLoading: Bool = false
}
