// OnboardingCountryVM.swift
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

struct OnboardingCountryVM {
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  let isHeaderVisible: Bool
  
  /// The currently selected Country.
  let currentCountries: [CountrySelection]?
    
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

extension OnboardingCountryVM: ViewModelWithLocalState {
  init?(state: AppState?, localState: OnboardingCountryLS) {
    self.init(
      isHeaderVisible: localState.isHeaderVisible,
      currentCountries: localState.currentCountries
    )
  }

  init(isHeaderVisible: Bool, currentCountries: [CountrySelection]?) {
    self.isHeaderVisible = isHeaderVisible
    self.currentCountries = currentCountries

    let countryItems = Country.allCases
      .sorted().map {
        OnboardingCountryVM.CellType.radio(
            countryIdentifier: $0.rawValue,
            countryName: $0.humanReadableName,
            isSelected: currentCountries?.map{ $0.country }.contains($0) ?? false
        )
      }
   
    self.items = [
      .titleHeader(title: "In quale paese della comunità Europea devi andare?", description: "Seleziona il paese/i dove devi andare tra quelli che hanno aderito all’interoperabilità per contribuire al contenimento della diffusione del virus all’interno della comunità Europea."),
      .spacer(.big)
    ] + countryItems
  }
}

extension OnboardingCountryVM {
  enum CellType: Equatable {
    
    case titleHeader(title: String, description: String)
    case radio(countryIdentifier: String, countryName: String, isSelected: Bool)
    case spacer(OnboardingSpacerCellVM.Size)

    var cellVM: ViewModel {
      switch self {
      case .titleHeader(let title, let description):
        return OnboardingHeaderCellVM(title: title, description: description, actionButtonTitle: "")

      case .spacer(let size):
        return OnboardingSpacerCellVM(size: size)
        
      case .radio(_, let countryName, let isSelected):
        return OnboardingCheckCellVM(title: countryName, isSelected: isSelected)
      }
    }
  }
}
