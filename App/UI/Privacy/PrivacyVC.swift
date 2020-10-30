// PrivacyVC.swift
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
import Katana
import Tempura

final class PrivacyVC: ViewControllerWithLocalState<PrivacyView> {
  override func setupInteraction() {
    self.rootView.userDidScroll = { [weak self] scrollOffset in
      if scrollOffset > 0 {
        self?.localState.isHeaderVisible = true
      } else if scrollOffset < -20 {
        self?.localState.isHeaderVisible = false
      }
    }

    self.rootView.userDidTapAbove14Checkbox = { [weak self] in
      guard let self = self else {
        return
      }

      self.localState = self.localState.byTogglingAbove14()
    }

    self.rootView.userDidTapReadPrivacyNoticeCheckbox = { [weak self] in
      guard let self = self else {
        return
      }

      self.localState = self.localState.byTogglingReadPrivacyNotice()
    }

    self.rootView.userDidTapActionButton = { [weak self] in
      guard let self = self else {
        return
      }

      switch self.localState.kind {
      case .onboarding:
        self.handleOnboardingActionButtonTap()

      case .settings:
        self.handleSettingsActionButtonTap()
      }
    }

    self.rootView.userDidTapURL = { [weak self] url in
      self?.store.dispatch(Logic.Shared.OpenURL(url: url))
    }

    self.rootView.userDidTapClose = { [weak self] in
      self?.store.dispatch(Hide(Screen.privacy, animated: true, context: nil))
    }
  }

  private func handleSettingsActionButtonTap() {
    self.store.dispatch(Logic.Settings.ShowFullPrivacyNotice())
  }

  private func handleOnboardingActionButtonTap() {
    guard !self.localState.isReadPrivacyNoticeChecked || !self.localState.isAbove14Checked else {
      self.store.dispatch(Logic.Privacy.UserHasCompletedPrivacyScreen())
      return
    }

    let checkBoxCell = self.rootView.contentCollection.visibleCells.first { $0 is PrivacyCheckboxCell }

    guard
      let cell = checkBoxCell,
      cell.convert(cell.bounds.origin, to: nil).y + cell.bounds.size.height <
      self.rootView.frame.height - self.rootView.scrollableGradientView.bounds.size.height
    else {
      let items = self.viewModel?.items.count ?? 0
      self.rootView.contentCollection.scrollToItem(at: IndexPath(item: items - 1, section: 0), at: .bottom, animated: true)
      return
    }

    self.localState = self.localState.erroredVersion()
    self.dispatch(Logic.Accessibility.PostNotification(
      notification: .layoutChanged,
      argument: self.rootView.getFirstErroredCell()
    ))
  }
}

struct PrivacyLS: LocalState {
  /// Whether the view is shown as part of the onboarding or from the settings.
  let kind: Kind

  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  var isHeaderVisible: Bool

  /// Whether the above 14 checkbox is checked.
  var isAbove14Checked: Bool
  /// Whether the privacy policy checkbox is checked.
  var isReadPrivacyNoticeChecked: Bool

  /// Whether the above 14 checkbox is errored.
  var isAbove14Errored: Bool
  /// Whether the privacy policy checkbox is errored.
  var isReadPrivacyNoticeErrored: Bool

  init(kind: Kind) {
    self.kind = kind
    self.isHeaderVisible = false
    self.isAbove14Checked = false
    self.isReadPrivacyNoticeChecked = false
    self.isAbove14Errored = false
    self.isReadPrivacyNoticeErrored = false
  }

  func erroredVersion() -> Self {
    var copy = self
    copy.isAbove14Errored = !copy.isAbove14Checked
    copy.isReadPrivacyNoticeErrored = !copy.isReadPrivacyNoticeChecked
    return copy
  }

  func byTogglingAbove14() -> Self {
    var copy = self
    copy.isAbove14Errored = false
    copy.isAbove14Checked.toggle()
    return copy
  }

  func byTogglingReadPrivacyNotice() -> Self {
    var copy = self
    copy.isReadPrivacyNoticeErrored = false
    copy.isReadPrivacyNoticeChecked.toggle()
    return copy
  }
}

extension PrivacyLS {
  enum Kind {
    case onboarding
    case settings
  }
}
