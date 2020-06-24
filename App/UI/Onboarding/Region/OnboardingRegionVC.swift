// OnboardingRegionVC.swift
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

final class OnboardingRegionVC: ViewControllerWithLocalState<OnboardingRegionView> {
  override func setupInteraction() {
    self.rootView.userDidTapClose = { [weak self] in
      self?.store.dispatch(Hide(Screen.updateProvince, animated: true))
    }

    self.rootView.userDidScroll = { [weak self] scrollOffset in
      if scrollOffset > 0 {
        self?.localState.isHeaderVisible = true
      } else if scrollOffset < -20 {
        self?.localState.isHeaderVisible = false
      }
    }

    self.rootView.userDidSelectRegion = { [weak self] region in
      self?.localState.currentRegion = region
      self?.onboardingContainer?.setNeedsRefreshControls()
    }

    self.rootView.userDidTapDiscoverMore = { [weak self] in
      self?.dispatch(Logic.PermissionTutorial.ShowWhyProvinceRegion())
    }
  }
}

extension OnboardingRegionVC: OnboardingViewController {
  func handleNext() {
    guard let region = self.localState.currentRegion else {
      return
    }

    if self.localState.isUpdatingRegion {
      // settings
      self.store.dispatch(Logic.Settings.HandleRegionStepCompleted(region: region))
    } else {
      // onboarding
      self.store.dispatch(Logic.Onboarding.HandleRegionStepCompleted(region: region))
    }
  }

  var nextButtonTitle: String {
    return L10n.Onboarding.Common.next
  }

  var shouldNextButtonBeEnabled: Bool {
    return self.localState.currentRegion != nil
  }

  var shouldShowBackButton: Bool {
    false
  }

  var shouldShowNextButton: Bool {
    true
  }

  var shouldShowGradient: Bool {
    true
  }
}

struct OnboardingRegionLS: LocalState {
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  var isHeaderVisible: Bool
  /// Whether the view is presented as an update or as part of the onboarding.
  /// This will change the close button visibility.
  let isUpdatingRegion: Bool
  /// The currently selected region.
  var currentRegion: Region?

  init(isUpdatingRegion: Bool, currentRegion: Region?) {
    self.isHeaderVisible = false
    self.isUpdatingRegion = isUpdatingRegion
    self.currentRegion = currentRegion
  }
}
