// SettingsVC.swift
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

class SettingsVC: ViewControllerWithLocalState<SettingsView> {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .darkContent
  }

  override func setupInteraction() {
    self.rootView.userDidScroll = { [weak self] scrollOffset in
      if scrollOffset > 10 {
        self?.localState.isHeaderVisible = true
      } else if scrollOffset < 0 {
        self?.localState.isHeaderVisible = false
      }
    }

    self.rootView.didTapCell = { [weak self] setting in
      self?.handleInteraction(with: setting)
    }
  }
}

private extension SettingsVC {
  func handleInteraction(with setting: SettingsVM.Setting) {
    switch setting {
    case .loadData:
      self.dispatch(Logic.Settings.ShowChooseDataUploadMode())
    case .faq:
      self.dispatch(Logic.Settings.ShowFAQs())
    case .tos:
      self.dispatch(Logic.Settings.ShowTOU())
    case .privacy:
      self.dispatch(Logic.Settings.ShowPrivacyNotice())
    case .chageProvince:
      self.dispatch(Logic.Settings.ShowUpdateProvince())
    case .updateCountry:
      self.store.dispatch(Logic.Settings.ShowUpdateCountry())
    case .shareApp:
      self.dispatch(Logic.Settings.ShareApp())
    case .customerSupport:
      self.dispatch(Logic.Settings.ShowCustomerSupport())
    case .leaveReview:
      self.dispatch(Logic.Settings.LeaveReview())
    case .debugUtilities:
      self.dispatch(Logic.Settings.ShowDebugMenu())
    }
  }
}

struct SettingsLS: LocalState {
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  var isHeaderVisible: Bool = false
}
