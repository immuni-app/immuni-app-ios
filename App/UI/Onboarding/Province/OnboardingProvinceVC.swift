// OnboardingProvinceVC.swift
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

final class OnboardingProvinceVC: ViewControllerWithLocalState<OnboardingProvinceView> {
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

    self.rootView.userDidSelectProvince = { [weak self] province in
      self?.localState.currentProvince = province
      self?.onboardingContainer?.setNeedsRefreshControls()
    }

    self.rootView.userDidTapDiscoverMore = { [weak self] in
      self?.dispatch(Logic.PermissionTutorial.ShowWhyProvinceRegion())
    }
  }
}

extension OnboardingProvinceVC: OnboardingViewController {
  func handleNext() {
    guard let province = self.localState.currentProvince else {
      return
    }

    if self.localState.isUpdatingProvince {
      // settings
      self.store.dispatch(Logic.Settings.CompleteUpdateProvince(newProvince: province))
    } else {
      // onboarding
      self.store.dispatch(Logic.Onboarding.HandleProvinceStepCompleted(selectedProvince: province))
    }
  }

  var nextButtonTitle: String {
    if self.localState.isUpdatingProvince {
      return L10n.Settings.UpdateProvince.updateProvince
    } else {
      return L10n.Onboarding.Common.next
    }
  }

  var shouldNextButtonBeEnabled: Bool {
    return self.localState.currentProvince != nil
  }

  var shouldShowBackButton: Bool {
    return true
  }

  var shouldShowNextButton: Bool {
    true
  }

  var shouldShowGradient: Bool {
    true
  }
}

struct OnboardingProvinceLS: LocalState {
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  var isHeaderVisible: Bool
  /// Whether the view is presented as an update or as part of the onboarding.
  /// This will change the close button visibility.
  var isUpdatingProvince: Bool
  /// The selected region. Chosen in a previous step.
  var selectedRegion: Region
  /// The currently selected province.
  var currentProvince: Province?

  init(isUpdatingProvince: Bool, selectedRegion: Region, currentProvince: Province?) {
    self.isHeaderVisible = false
    self.isUpdatingProvince = isUpdatingProvince
    self.selectedRegion = selectedRegion
    self.currentProvince = currentProvince
  }
}
