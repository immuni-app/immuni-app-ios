// OnboardingRegionVM.swift
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
import Models
import Tempura

struct OnboardingRegionVM {
  /// Whether the view is presented as an update or as part of the onboarding.
  /// This will change the close button visibility.
  let isUpdatingRegion: Bool
  /// The array of items shown in the collection.
  let items: [CellType]
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  let isHeaderVisible: Bool

  func shouldReloadCollection(oldVM: Self?) -> Bool {
    guard let oldVM = oldVM else {
      return true
    }

    return self.items != oldVM.items
  }

  func shouldUpdateHeader(oldVM: Self?) -> Bool {
    return self.isHeaderVisible != oldVM?.isHeaderVisible
  }

  var shouldShowCloseButton: Bool { self.isUpdatingRegion }
}

extension OnboardingRegionVM: ViewModelWithLocalState {
  init?(state: AppState?, localState: OnboardingRegionLS) {
    self.init(
      isHeaderVisible: localState.isHeaderVisible,
      isUpdatingRegion: localState.isUpdatingRegion,
      currentRegion: localState.currentRegion
    )
  }

  init(isHeaderVisible: Bool, isUpdatingRegion: Bool, currentRegion: Region?) {
    self.isHeaderVisible = isHeaderVisible
    self.isUpdatingRegion = isUpdatingRegion

    let regionItems = Region.allCases
      .sorted().map {
        OnboardingRegionVM.CellType.radio(
          regionRawValue: $0.rawValue,
          regionName: $0.humanReadableName(with: L10n.Onboarding.Region.Abroad.item),
          isSelected: $0 == currentRegion
        )
      }

    self.items = [
      .titleHeader(title: L10n.Onboarding.Region.title, description: L10n.Onboarding.Region.description),
      .spacer(.big)
    ] + regionItems
  }
}

extension OnboardingRegionVM {
  enum CellType: Equatable {
    case titleHeader(title: String, description: String)
    case radio(regionRawValue: String, regionName: String, isSelected: Bool)
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

      case .radio(_, let ragionName, let isSelected):
        return OnboardingRadioCellVM(title: ragionName, isSelected: isSelected)
      }
    }
  }
}
