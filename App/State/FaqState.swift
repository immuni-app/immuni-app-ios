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

/// Slice of state that manages the app's FAQs
struct FaqState: Codable {
  /// The latest fetched FAQs
  // swiftlint:disable:next discouraged_optional_collection
  var fetchedFAQs: [FAQ]? = nil

  /// The language of the latest fetched FAQs
  var latestFetchLanguage: UserLanguage? = nil

  /// Helper function that returns the fetched FAQs (if any) only if they match the given `language`, nil otherwise.
  // swiftlint:disable:next discouraged_optional_collection
  func faqs(for language: UserLanguage) -> [FAQ]? {
    guard let faqs = self.fetchedFAQs, self.latestFetchLanguage == language else {
      return nil
    }

    return faqs
  }
}
