// SuggestionsVC.swift
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

class SuggestionsVC: ViewControllerWithLocalState<SuggestionsView> {
  override func setupInteraction() {
    self.rootView.didTapClose = { [weak self] in
      self?.dispatch(Hide(Screen.suggestions, animated: true))
    }

    self.rootView.userDidScroll = { [weak self] scrollOffset in
      guard let self = self else { return }
      let headerShift = self.rootView.headerDefaultSize - self.rootView.headerMinHeight

      if scrollOffset > headerShift {
        self.localState.isHeaderVisible = true
      } else if scrollOffset < headerShift {
        self.localState.isHeaderVisible = false
      }
    }

    self.rootView.didTapCollectionButton = { [weak self] interaction in
      self?.handleInteraction(interaction)
    }

    self.rootView.userDidTapURL = { [weak self] url in
      self?.store.dispatch(Logic.Shared.OpenURL(url: url))
    }
    
    self.rootView.didTapDiscoverMoreStayHome = { [weak self] in
      self?.dispatch(Logic.Home.ShowStayHomeDiscoverMore())
    }
  }

  private func handleInteraction(_ interaction: SuggestionsButtonCellVM.ButtonInteraction) {
    switch interaction {
    case .dismissContactNotifications:
      self.dispatch(Logic.Suggestions.DismissContactNotifications())
    case .dismissCovidNotifications:
      self.dispatch(Logic.Suggestions.HideAlert())
    case .covidNegative:
      self.dispatch(Logic.Suggestions.NoLongerPositive())
    }
  }
}

// MARK: - LocalState

struct SuggestionsLS: LocalState {
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  var isHeaderVisible: Bool = false
}
