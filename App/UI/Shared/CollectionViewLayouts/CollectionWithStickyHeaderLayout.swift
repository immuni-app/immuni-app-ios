// CollectionWithStickyHeaderLayout.swift
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

import Tempura
import UIKit

/// This is a special UICollectionViewFlowLayout that blocks the top position of the cells that implement the StickyCell protocol.
/// A minimum height needs to be passed for each StickyCell.
class CollectionWithStickyCellsLayout: UICollectionViewFlowLayout {
  // MARK: - Init

  override init() {
    super.init()
    self.setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
  }

  private func setup() {}

  // swiftlint:disable discouraged_optional_collection
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    // swiftlint:enable discouraged_optional_collection
    let parent = super.layoutAttributesForElements(in: rect)
    guard
      let collectionView = self.collectionView,
      let attributes = parent,
      !attributes.isEmpty
    else {
      return parent
    }

    // manage header attributes

    for cellAttributes in attributes {
      if
        cellAttributes.indexPath.item == 0,
        let cell = collectionView.cellForItem(at: cellAttributes.indexPath) as? StickyCell
      {
        let offset = collectionView.contentOffset

        var frame = cellAttributes.frame
        let cellStandardHeight = frame.height
        let cellMinimumHeight = max(0, cell.minimumHeight)

        frame.size.height = max(cellMinimumHeight, cellStandardHeight - offset.y)
        frame.origin.y = frame.minY + offset.y

        if frame != cellAttributes.frame {
          cellAttributes.frame = frame
          cell.frame = frame
        }
      }
    }

    return attributes
  }
}

/// A cell that won't scroll with the collection.
protocol StickyCell: UICollectionViewCell {
  /// The minimum height of the cell.
  var minimumHeight: CGFloat { get }
}
