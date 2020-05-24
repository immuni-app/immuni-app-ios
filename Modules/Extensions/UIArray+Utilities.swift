// UIArray+Utilities.swift
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

public extension Array {
  /**
   Returns the element at the specified index iff it is within bounds, otherwise nil.
   Complexity: O(1).

   - parameter index: the index
   - returns: the value that corresponds to the index. nil if the value cannot be found
   */
  subscript(safe index: Index) -> Iterator.Element? {
    return self.isIndexValid(index) ? self[index] : nil
  }

  /**
   Checks whether the index is valid for the array.
   Complexity: O(1).

   - parameter index: the index to check
   - returns: true if the index is valid for the collection, false otherwise
   */
  func isIndexValid(_ index: Index) -> Bool {
    return index >= self.startIndex && index < self.endIndex
  }

  /// Given an array, returns an array removing all the duplicates according to the given
  /// comparator while preserving the array order. Complexity: O(nˆ2).
  ///
  /// - parameter predicate: a closure that performs the comparison.
  func unique(by isEqual: (Element, Element) -> Bool) -> [Element] {
    var newArray: [Element] = []

    for element in self {
      if !newArray.contains(where: { isEqual(element, $0) }) {
        newArray.append(element)
      }
    }

    return newArray
  }
}
