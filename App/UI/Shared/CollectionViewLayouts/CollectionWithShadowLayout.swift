// CollectionWithShadowLayout.swift
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

/// This is a special UICollectionViewFlowLayout that adds a background container with shadow for each section.
/// All the shadows are at the same level without overlapping each other.
class CollectionWithShadowLayout: UICollectionViewFlowLayout {
  // Decoration view used as background of the collection
  private let decorationViewKind = "\(ShadowedDecorationView.self)"

  // MARK: - Init

  override init() {
    super.init()
    self.setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
  }

  private func setup() {
    self.register(ShadowedDecorationView.self, forDecorationViewOfKind: self.decorationViewKind)
  }

  // swiftlint:disable discouraged_optional_collection
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    // swiftlint:enable discouraged_optional_collection
    let parent = super.layoutAttributesForElements(in: rect)
    guard let attributes = parent, !attributes.isEmpty else {
      return parent
    }

    var backgroundItemShadowAttributes: [UICollectionViewLayoutAttributes] = []
    if let collection = self.collectionView {
      for section in 0 ..< collection.numberOfSections {
        let numberOfItems = collection.numberOfItems(inSection: section)
        if let attribute = self.layoutAttributesForDecorationViewItem(at: section, cellsCount: numberOfItems) {
          backgroundItemShadowAttributes.append(attribute)
        }
      }
    }

    return attributes + backgroundItemShadowAttributes
  }

  /// Layout attributes for the item-specific decoration view
  func layoutAttributesForDecorationViewItem(at section: Int, cellsCount: Int) -> UICollectionViewLayoutAttributes? {
    let decorationViewAttributes = UICollectionViewLayoutAttributes(
      forDecorationViewOfKind: self.decorationViewKind,
      with: IndexPath(item: 0, section: section)
    )

    guard
      let topItemAttributes = self.layoutAttributesForItem(at: IndexPath(item: 0, section: section)),
      let bottomItemAttributes = self.layoutAttributesForItem(at: IndexPath(item: cellsCount - 1, section: section))
      else {
        return nil
    }

    decorationViewAttributes.frame = CGRect(
      x: topItemAttributes.frame.minX + SettingsView.collectionInset,
      y: topItemAttributes.frame.minY - SettingsView.shadowVerticalInset,
      width: topItemAttributes.frame.width - 2 * SettingsView.collectionInset,
      height: bottomItemAttributes.frame.maxY - topItemAttributes.frame.minY + 2 * SettingsView.shadowVerticalInset
    )
    decorationViewAttributes.zIndex = -1
    return decorationViewAttributes
  }
}

// MARK: DecorationView with Shadow

/// A decoration view with a shadow and white background to be applied behind the cells.
private class ShadowedDecorationView: UICollectionReusableView, View {
  // swiftlint:enable private_over_fileprivate
  override init(frame: CGRect) {
    super.init(frame: .zero)
    self.setup()
    self.style()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
    self.style()
  }

  func setup() {}

  func style() {
    self.backgroundColor = Palette.white
    self.layer.cornerRadius = SharedStyle.cardCornerRadius
    self.addShadow(.cardLightBlue)
  }

  func update() {}
}
