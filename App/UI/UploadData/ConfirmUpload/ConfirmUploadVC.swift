// ConfirmUploadVC.swift
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

class ConfirmUploadVC: ViewControllerWithLocalState<ConfirmUploadView> {
  override func setupInteraction() {
    self.rootView.didTapClose = { [weak self] in
      self?.dispatch(Hide(animated: true))
    }

    self.rootView.didTapAction = { [weak self] in
      guard let self = self else { return }
      self.dispatch(Logic.DataUpload.ConfirmData(code: self.localState.validatedCode))
    }
  }
}

// MARK: - LocalState

struct ConfirmUploadLS: LocalState {
  enum DataKind {
    case result
    case proximityData
    case expositionData
    case province
  }

  /// The OTP that has just been validated.
  let validatedCode: OTP
  /// The kind of data that are going to be uploaded.
  let dataKindsInfo: [DataKind]
}
