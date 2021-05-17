// HomeVC.swift
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
import Tempura

class HomeVC: ViewController<HomeView> {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    if self.viewModel?.hasHeaderCard ?? false {
      return .lightContent
    } else {
      return .darkContent
    }
  }

  override func didUpdate(old: HomeVM?) {
    super.didUpdate(old: old)
    self.setNeedsStatusBarAppearanceUpdate()
  }

  override func setupInteraction() {
    self.rootView.didTapActivateService = { [weak self] in
      self?.dispatch(Logic.Home.ShowFixActiveService())
    }

    self.rootView.didTapHeaderCardInfo = { [weak self] in
      self?.dispatch(Logic.Suggestions.ShowSuggestions())
    }

    self.rootView.didTapInfo = { [weak self] info in
      self?.handleDidTapInfo(info)
    }
    
    self.rootView.didTapDoToday = { [weak self] todo in
      self?.handleDidTapDoToday(todo)
    }

    self.rootView.didTapDeactivateService = { [weak self] in
      self?.dispatch(Logic.Home.ShowDeactivateService())
    }

    self.rootView.didTapActiveServiceDiscoverMore = { [weak self] in
      self?.dispatch(Logic.PermissionTutorial.ShowVerifyImmuniWorks())
    }
  }

  func handleDidTapInfo(_ info: HomeVM.InfoKind) {
    switch info {
    case .app:
      self.dispatch(Logic.PermissionTutorial.ShowHowImmuniWorks(showFaqButton: true))

    case .protection:
      self.dispatch(Logic.Suggestions.ShowSuggestions())
    }
  }
    
  func handleDidTapDoToday(_ todo: HomeVM.DoTodayKind) {
    switch todo {

      case .updateCountry:
        self.dispatch(Logic.Settings.ShowUpdateCountry())
          
      case .dataUpload:
        self.dispatch(Logic.Settings.ShowChooseDataUploadMode())
          
      case .greenCertificate:
        self.dispatch(Logic.Home.ShowGreenCertificate())
      }
    }
}

