// FaqUITests.swift
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
import TempuraTesting
import XCTest

@testable import Immuni

class FaqUITests: AppViewTestCase, ViewTestCase {
  typealias V = FaqView

  func testFaq() {
    self.uiTest(
      testCases: [
        "faq_italian": FaqVM(
          faqs: FAQ.mockedFAQs,
          isPresentedModally: false,
          isHeaderVisible: false,
          isSearching: false,
          searchFilter: "",
          keyboardHeight: 0
        ),
        "faq_empty": FaqVM(
          faqs: [],
          isPresentedModally: false,
          isHeaderVisible: false,
          isSearching: false,
          searchFilter: "",
          keyboardHeight: 0
        ),
        "faq_modal": FaqVM(
          faqs: FAQ.mockedFAQs,
          isPresentedModally: true,
          isHeaderVisible: false,
          isSearching: false,
          searchFilter: "",
          keyboardHeight: 0
        ),
        "faq_with_header": FaqVM(
          faqs: FAQ.mockedFAQs,
          isPresentedModally: false,
          isHeaderVisible: true,
          isSearching: false,
          searchFilter: "",
          keyboardHeight: 0
        ),
        "faq_modal_with_header": FaqVM(
          faqs: FAQ.mockedFAQs,
          isPresentedModally: true,
          isHeaderVisible: true,
          isSearching: false,
          searchFilter: "",
          keyboardHeight: 0
        ),
        "faq_searching": FaqVM(
          faqs: FAQ.mockedFAQs,
          isPresentedModally: true,
          isHeaderVisible: false,
          isSearching: true,
          searchFilter: "",
          keyboardHeight: 0
        ),
        "faq_searching_with_header": FaqVM(
          faqs: FAQ.mockedFAQs,
          isPresentedModally: true,
          isHeaderVisible: true,
          isSearching: true,
          searchFilter: "",
          keyboardHeight: 0
        ),
        "faq_searching_string": FaqVM(
          faqs: FAQ.mockedFAQs,
          isPresentedModally: true,
          isHeaderVisible: false,
          isSearching: true,
          searchFilter: "Immuni",
          keyboardHeight: 0
        )
      ],
      context: UITests.Context<V>(renderSafeArea: false)
    )
  }

  func scrollViewsToTest(in view: FaqView, identifier: String) -> [String: UIScrollView] {
    return [
      "collection": view.collection
    ]
  }
}

extension FAQ {
  // swiftlint:disable line_length
  static var mockedFAQ: FAQ {
    FAQ(
      title: "Immuni dice che potrei essere a rischio, ma io mi sento bene. Cosa devo fare?",
      content: """
      Ti suggeriamo vivamente di seguire tutte le raccomandazioni di Immuni. Ci sono molte persone asintomatiche che hanno diffuso il virus senza rendersene conto. Uno dei punti di forza di Immuni è proprio la capacità di avvertire queste persone. Per favore, fai la tua parte seguendo le raccomandazioni, anche se pensi di non essere contagioso.
      """
    )
  }

  static var mockedFAQs: [FAQ] {
    Array(repeating: Self.mockedFAQ, count: 30)
  }
}
