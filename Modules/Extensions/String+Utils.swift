// String+Utils.swift
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

import CryptoKit
import Foundation

public extension String {
  /// Helper to strip XML from string using a regular expression.
  ///
  /// -note: This method performs a best-effort stripping of the XML tags, stripping only words, slash or whitespace characters
  /// contained between two angle brackets. It is meant to be used for accessibility labels with localized content and not as a
  /// fully fledged XML stripper.
  /// This implementation assumes that the stripped tags are related to the BonMot's XML style feature.
  var byStrippingXML: String {
    return self.replacingOccurrences(of: "\\s?\\<[\\w\\s\\/]*\\>", with: "", options: .regularExpression)
  }

  /// Returns the hex string representation of the SHA256 of this string, encoded in utf8.
  var sha256: String {
    return SHA256
      .hash(data: Data(self.utf8))
      .hexString
  }

  /// Returns a string of random hexadecimal digits with the given `size`
  static func random(length: Int) -> Self {
    let requiredBytesOfRandomness = length / 2 + 1
    let randomData = Data.randomData(with: requiredBytesOfRandomness)
    return String(randomData.hexString.prefix(length))
  }

  /// Reimplements fuzzier string contains that tries to match the string with all possible ordered substrings of the query,
  /// kind of like the symbol/file search feature of Xcode
  ///
  /// Usage:
  /// ```
  /// "Immuni App".fuzzyContains("Immuni") // return true
  /// "Immuni App".fuzzyContains("ImmApp") // return true
  /// "Immuni App".fuzzyContains("Immani") // return false
  /// ```
  func fuzzyContains(_ other: String) -> Bool {
    if other == self {
      return true
    }

    guard other.count <= self.count else {
      return false
    }

    var selfIdx = other.startIndex
    var otherIdx = self.startIndex

    while selfIdx != other.endIndex {
      if otherIdx == self.endIndex {
        return false
      }

      if other[selfIdx] == self[otherIdx] {
        selfIdx = other.index(after: selfIdx)
      }

      otherIdx = self.index(after: otherIdx)
    }

    return true
  }
}
