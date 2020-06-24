// OnboardingProvinceVM.swift
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

struct OnboardingProvinceVM {
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  let isHeaderVisible: Bool
  /// Whether the view is presented as an update or as part of the onboarding.
  /// This will change the close button visibility.
  let isUpdatingProvince: Bool
  /// The currently selected province.
  let currentProvince: Province?
  /// The array of items shown in the collection.
  let items: [CellType]

  func shouldReloadCollection(oldVM: Self?) -> Bool {
    guard let oldVM = oldVM else {
      return true
    }

    return self.items != oldVM.items
  }

  func shouldUpdateHeader(oldVM: Self?) -> Bool {
    return self.isHeaderVisible != oldVM?.isHeaderVisible
  }

  var shouldShowCloseButton: Bool { self.isUpdatingProvince }
}

extension OnboardingProvinceVM: ViewModelWithLocalState {
  init?(state: AppState?, localState: OnboardingProvinceLS) {
    self.init(
      isHeaderVisible: localState.isHeaderVisible,
      isUpdatingProvince: localState.isUpdatingProvince,
      selectedRegion: localState.selectedRegion,
      currentProvince: localState.currentProvince
    )
  }

  init(isHeaderVisible: Bool, isUpdatingProvince: Bool, selectedRegion: Region, currentProvince: Province?) {
    self.isHeaderVisible = isHeaderVisible
    self.isUpdatingProvince = isUpdatingProvince
    self.currentProvince = currentProvince

    let provinceItems = selectedRegion.provinces
      .sorted { $0.humanReadableName < $1.humanReadableName }
      .map {
        OnboardingProvinceVM.CellType.radio(
          provinceIdentifier: $0.rawValue,
          provinceName: $0.humanReadableName,
          isSelected: $0 == currentProvince
        )
      }

    self.items = [
      .titleHeader(title: L10n.Onboarding.Province.title, description: L10n.Onboarding.Province.description),
      .spacer(.big)
    ] + provinceItems
  }
}

extension OnboardingProvinceVM {
  enum CellType: Equatable {
    case titleHeader(title: String, description: String)
    case radio(provinceIdentifier: String, provinceName: String, isSelected: Bool)
    case spacer(OnboardingSpacerCellVM.Size)

    var cellVM: ViewModel {
      switch self {
      case .titleHeader(let title, let description):
        return OnboardingHeaderCellVM(
          title: title,
          description: description,
          actionButtonTitle: L10n.Onboarding.Common.discoverMore
        )

      case .spacer(let size):
        return OnboardingSpacerCellVM(size: size)

      case .radio(_, let provinceName, let isSelected):
        return OnboardingRadioCellVM(title: provinceName, isSelected: isSelected)
      }
    }
  }
}
