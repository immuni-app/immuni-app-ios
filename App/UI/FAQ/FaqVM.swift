// FaqVM.swift
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

struct FaqVM: ViewModelWithLocalState {
  /// The list of FAQ to show
  let faqs: [FAQ]
  /// Whether the view is presented modally. This will change the back/close button visibility.
  let isPresentedModally: Bool
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  let isHeaderVisible: Bool
  /// Whether the user is actively searching through the search bar.
  let isSearching: Bool
  /// The currently searching string.
  let searchFilter: String
  /// The keyboard height
  let keyboardHeight: CGFloat

  func shouldUpdateHeader(oldModel: FaqVM?) -> Bool {
    return self.isHeaderVisible != oldModel?.isHeaderVisible
  }

  func shouldUpdateSearchStatus(oldModel: FaqVM?) -> Bool {
    return self.isSearching != oldModel?.isSearching
  }

  func shouldUpdateLayout(oldModel: FaqVM?) -> Bool {
    return self.keyboardHeight != oldModel?.keyboardHeight
  }

  func shouldReloadCollection(oldModel: FaqVM?) -> Bool {
    guard let oldModel = oldModel else {
      return true
    }

    if self.faqs != oldModel.faqs {
      return true
    }

    if self.searchFilter != oldModel.searchFilter {
      return true
    }

    return false
  }

  func cellModel(for indexPath: IndexPath) -> ViewModel? {
    guard let faq = self.faqs[safe: indexPath.item] else {
      return nil
    }
    return FaqCellVM(faq: faq, searchFilter: self.searchFilter)
  }

  var searchBarVM: SearchBarVM { SearchBarVM(isSearching: self.isSearching) }
  var shouldShowNoResult: Bool { self.faqs.isEmpty }
  var shouldShowSeparator: Bool { !self.isHeaderVisible }
  var shouldShowTitle: Bool { !self.isSearching }
  var shouldShowBackButton: Bool { !self.isPresentedModally && !self.isSearching }
  var shouldShowCloseButton: Bool { self.isPresentedModally && !self.isSearching }
}

extension FaqVM {
  init?(state: AppState?, localState: FAQLS) {
    guard
      let state = state,
      let faqs = state.faq.faqs(for: state.environment.userLanguage)
    else {
      return nil
    }

    if localState.searchFilter.isEmpty {
      self.faqs = faqs
    } else {
      self.faqs = faqs.filter(with: localState.searchFilter)
    }

    self.isPresentedModally = localState.isPresentedModally
    self.isHeaderVisible = localState.isHeaderVisible
    self.isSearching = localState.isSearching
    self.searchFilter = localState.searchFilter
    self.keyboardHeight = state.environment.keyboardState.height
  }
}

// MARK: - Helper

extension Array where Element == FAQ {
  /// Returns an array of the FAQs that contain the given string in the title or in the content.
  /// The first elements of the result are the FAQs that contain the exact match with the passed string in the title.
  /// The following elements are the FAQs that have a fuzzy match in the title or an exact match in the content.
  func filter(with filterString: String) -> [FAQ] {
    let exactMatching = self.filter { $0.title.lowercased().contains(filterString.lowercased()) }
    let fuzzyMatching = self.filter {
      !exactMatching.contains($0) &&
        (
          $0.title.lowercased().fuzzyContains(filterString.lowercased()) ||
            $0.content.lowercased().contains(filterString.lowercased())
        )
    }
    return exactMatching + fuzzyMatching
  }
}
