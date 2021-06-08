// GreenCertificateRecoveryDetailVC.swift
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

class GreenCertificateRecoveryDetailVC: ViewControllerWithLocalState<GreenCertificateRecoveryDetailView> {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupInteraction() {
        rootView.didTapBack = { [weak self] in
            self?.dispatch(Hide(Screen.greenCertificateRecoveryDetail, animated: true))
        }
        rootView.didTapContact = { [weak self] url in
            guard let url = URL(string: url) else { return }
            self?.dispatch(Logic.Shared.OpenURL(url: url))
        }
    }
}

// MARK: - LocalState

struct GreenCertificateRecoveryDetailLS: LocalState {
    
    let greenCertificate: GreenCertificate
}
