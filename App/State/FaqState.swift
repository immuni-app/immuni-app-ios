// FaqState.swift
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

struct FaqState {
  /// The latest fetched FAQs
  var fetchedFAQs: [FAQ]? = nil

  /// The language of the latest fetched FAQs
  var latestFetchLanguage: UserLanguage? = nil

  /// Returns the most updated FAQs available for the given language.
  /// - note: the app currently supports only one language at the time
  /// when it comes to fetched FAQs. In case of a change in the language,
  /// then the default FAQs are used instead
  func faqs(for language: UserLanguage) -> [FAQ] {
    if self.latestFetchLanguage == language, let faqs = self.fetchedFAQs {
      // use fetched language if possible
      return faqs
    }

    // fallback on default FAQs
    switch language {
    case .english:
      return FAQ.englishDefaultValues

    case .italian:
      return FAQ.italianDefaultValues

    case .german:
      return FAQ.germanDefaultValues
    }
  }
}
