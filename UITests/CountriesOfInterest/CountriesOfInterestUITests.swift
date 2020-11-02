// CountriesOfInterestUITests.swift
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

@testable import Immuni
import Models
import TempuraTesting
import XCTest

class CountriesOfInterestUITests: AppViewTestCase, ViewTestCase {
  typealias V = CountriesOfInterestView

  func testUI() {
    self.uiTest(
      testCases: [
        "countries_of_interest": CountriesOfInterestVM(
          isHeaderVisible: true,
          currentCountries: [],
          items: self.mockItems()
        )
      ],
      context: UITests.Context<V>(renderSafeArea: false)
    )
  }

  func scrollViewsToTest(in view: V, identifier: String) -> [String: UIScrollView] {
    return [
      "scrollable_content": view.contentCollection
    ]
  }
}

extension CountriesOfInterestUITests {
  func mockItems() -> [CountriesOfInterestVM.CellType] {
    let countryList = [
      "AT": "AUSTRIA",
      "DK": "DANIMARCA",
      "EE": "ESTONIA",
      "DE": "GERMANIA",
      "IE": "IRLANDA",
      "LV": "LETTONIA",
      "NL": "OLANDA",
      "PL": "POLONIA",
      "CZ": "REPUBBLICA CECA",
      "ES": "SPAGNA"
    ]

    let currentCountries: [CountryOfInterest] = [
      CountryOfInterest(country: Country(countryId: "PL", countryHumanReadableName: "POLONIA")),
      CountryOfInterest(country: Country(countryId: "DE", countryHumanReadableName: "GERMANIA"), selectionDate: Date()),
      CountryOfInterest(country: Country(countryId: "DK", countryHumanReadableName: "POLONIA"))
    ]
    var cellList: [(String, String, Bool, Bool)] = []

    for (key, value) in countryList {
      let index = currentCountries
        .firstIndex(of: CountryOfInterest(country: Country(countryId: key, countryHumanReadableName: value)))

      if index == nil || currentCountries.isEmpty {
        cellList.append((key, value, false, false))
        continue
      }

      // swiftlint:disable:next force_unwrapping
      let currentCountry = currentCountries[index!]

      if currentCountry.selectionDate == nil {
        cellList.append((key, value, true, false))
      } else {
        cellList.append((key, value, true, true))
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

    return [
      .titleHeader(title: L10n.CountriesOfInterest.title, description: L10n.CountriesOfInterest.description),
      .spacer(.big)
    ] + countryItems
  }
}
