// CertificatesVM.swift
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

import Models
import Tempura

struct CertificatesVM: ViewModelWithLocalState {
    
  /// The list of greenCertificates to show
  var greenCertificates: [GreenCertificate]?

  func shouldReloadCollection(oldModel: CertificatesVM?) -> Bool {
    guard let oldModel = oldModel else {
      return true
    }

      if self.greenCertificates?.count != oldModel.greenCertificates?.count {
      return true
    }

    return false
  }
    //TODO
  func cellModel(for indexPath: IndexPath) -> ViewModel? {
    guard let greenCertificates2 = self.greenCertificates, let greenCertificates = greenCertificates2[safe: indexPath.item] else {
      return nil
    }
    return CertificateCellVM(greenCertificate: greenCertificates)
  }

  var shouldShowNoResult: Bool { self.greenCertificates?.isEmpty ?? true }

}

extension CertificatesVM {
  init?(state: AppState?, localState: CertificatesLS) {
    guard
      let state = state,
      let greenCertificates = state.user.greenCertificates
    else {
      return nil
    }
      self.greenCertificates = greenCertificates.reversed()
  }
}

