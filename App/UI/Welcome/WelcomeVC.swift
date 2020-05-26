// WelcomeVC.swift
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

import Tempura

class WelcomeVC: ViewControllerWithLocalState<WelcomeView> {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .darkContent
  }

  override func setupInteraction() {
    self.rootView.didScrollToPage = { [weak self] page in
      self?.localState.currentPage = page
    }

    self.rootView.didTapNext = { [weak self] in
      if self?.viewModel?.isFinalPage ?? false {
        self?.dispatch(Show(Screen.privacy, animated: true))
      } else {
        guard let currentPage = self?.viewModel?.currentPage else {
          return
        }
        let nextPage = currentPage + 1
        self?.localState.currentPage = nextPage
        self?.dispatch(Logic.Accessibility.PostNotification(
          notification: .layoutChanged,
          argument: self?.rootView.pages[safe: nextPage]
        ))
      }
    }

    self.rootView.didTapDiscoverMore = { [weak self] in
      self?.store.dispatch(Logic.PermissionTutorial.ShowHowImmuniWorks(showFaqButton: false))
    }
  }
}

// MARK: - LocalState

struct WelcomeLS: LocalState {
  /// The index of the currently visible page.
  var currentPage: Int = 0
}
