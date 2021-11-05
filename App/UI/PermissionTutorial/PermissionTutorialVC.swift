// PermissionTutorialVC.swift
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

final class PermissionTutorialVC: ViewControllerWithLocalState<PermissionTutorialView> {
  override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
    self.localState.shouldAnimateContent = false
    super.present(viewControllerToPresent, animated: flag, completion: completion)
  }

  override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
    self.localState.shouldAnimateContent = true
    super.dismiss(animated: flag, completion: completion)
  }

  override func setupInteraction() {
    self.rootView.userDidTapClose = { [weak self] in
      // At the moment we don't have the need of informing the caller
      self?.dismiss(animated: true, completion: nil)
    }

    self.rootView.userDidTapActionButton = { [weak self] in
      guard let self = self, let dispatchable = self.localState.content.action else {
        return
      }

      self.store.anyDispatch(dispatchable)
    }

    self.rootView.userDidScroll = { [weak self] scrollOffset in
      if scrollOffset > 0 {
        self?.localState.isHeaderVisible = true
      } else if scrollOffset < -20 {
        self?.localState.isHeaderVisible = false
      }
    }

    self.rootView.willStartScrollAnimation = { [weak self] in
      self?.localState.shouldAnimateContent = false
    }

    self.rootView.didEndScrollAnimation = { [weak self] in
      self?.localState.shouldAnimateContent = true
    }
  }
}

struct PermissionTutorialLS: LocalState {
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  var isHeaderVisible: Bool
  /// Whether the animatable content should play. This is used to stop animated content while scrolling to improve performances.
  var shouldAnimateContent: Bool
  /// A struct containing all the info meant to be shown in the view.
  let content: PermissionTutorialVM.Content

  init(content: PermissionTutorialVM.Content) {
    self.isHeaderVisible = false
    self.shouldAnimateContent = true
    self.content = content
  }
}
