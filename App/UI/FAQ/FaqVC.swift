// FaqVC.swift
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

class FaqVC: ViewControllerWithLocalState<FaqView> {
  override func setupInteraction() {
    self.rootView.userDidScroll = { [weak self] scrollOffset in
      if scrollOffset > 0 {
        self?.localState.isHeaderVisible = true
      } else if scrollOffset < -20 {
        self?.localState.isHeaderVisible = false
      }
    }

    self.rootView.didChangeSearchStatus = { [weak self] isSearching in
      self?.localState.isSearching = isSearching
    }

    self.rootView.didChangeSearchedValue = { [weak self] value in
      self?.localState.searchFilter = value
    }

    self.rootView.didTapBack = { [weak self] in
      self?.dispatch(Hide(Screen.faq, animated: true))
    }

    self.rootView.didTapCell = { [weak self] faq in
      self?.dispatch(Logic.Settings.ShowFAQ(faq: faq))
    }
  }
}

struct FAQLS: LocalState {
  /// Whether the view is presented modally. This will change the back/close button visibility.
  let isPresentedModally: Bool
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  var isHeaderVisible: Bool = false
  /// Whether the user is actively searching through the search bar.
  var isSearching: Bool = false
  /// The currently searching string.
  var searchFilter: String = ""
}
