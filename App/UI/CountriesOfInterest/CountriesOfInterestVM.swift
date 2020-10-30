// CountriesOfInterestVM.swift
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

// swiftlint:disable all

struct CountriesOfInterestVM {
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  let isHeaderVisible: Bool

  /// The currently selected Country.
  let currentCountries: [CountryOfInterest]?

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
}

extension CountriesOfInterestVM: ViewModelWithLocalState {
  init?(state: AppState?, localState: CountriesOfInterestLS) {
    self.init(
      dummyIngestionWindowDuration: localState.dummyIngestionWindowDuration,
      isHeaderVisible: localState.isHeaderVisible,
      currentCountries: localState.currentCountries,
      countryList: localState.countryList
    )
  }

  init(
    dummyIngestionWindowDuration: Double,
    isHeaderVisible: Bool,
    currentCountries: [CountryOfInterest]?,
    countryList: [String: String]
  ) {
    self.isHeaderVisible = isHeaderVisible
    self.currentCountries = currentCountries

    var cellList: [(String, String, Bool, Bool)] = []

    for (countryId, countryName) in countryList {
      let index = currentCountries?
        .firstIndex(of: CountryOfInterest(country: Country(
          countryId: countryId,
          countryHumanReadableName: countryName
        )))

      if index == nil || currentCountries?.isEmpty ?? true {
        cellList.append((countryId, countryName, false, false))
        continue
      }

      let currentCountry = currentCountries?[index!]

      if currentCountry!.selectionDate == nil || Date()
        .timeIntervalSince(currentCountry!.selectionDate!) > dummyIngestionWindowDuration
      {
        cellList.append((countryId, countryName, true, false))
      } else {
        cellList.append((countryId, countryName, true, true))
      }
    }

    cellList.sort { $0.1 < $1.1 }
    var countryItems = [CountriesOfInterestVM.CellType]()
    for element in cellList {
      countryItems.append(
        CountriesOfInterestVM.CellType.radio(
          countryIdentifier: element.0,
          countryName: element.1,
          isSelected: element.2,
          isDisable: element.3
        )
      )
    }

    self.items = [
      .titleHeader(title: L10n.CountriesOfInterest.title, description: L10n.CountriesOfInterest.description),
      .spacer(.big)
    ] + countryItems
  }
}

extension CountriesOfInterestVM {
  enum CellType: Equatable {
    case titleHeader(title: String, description: String)
    case radio(countryIdentifier: String, countryName: String, isSelected: Bool, isDisable: Bool)
    case spacer(OnboardingSpacerCellVM.Size)

    var cellVM: ViewModel {
      switch self {
      case .titleHeader(let title, let description):
        return OnboardingHeaderCellVM(title: title, description: description, actionButtonTitle: "")

      case .spacer(let size):
        return OnboardingSpacerCellVM(size: size)

      case .radio(_, let countryName, let isSelected, let isDisable):
        return OnboardingCheckCellVM(title: countryName, isSelected: isSelected, isDisable: isDisable)
      }
    }
  }
}
