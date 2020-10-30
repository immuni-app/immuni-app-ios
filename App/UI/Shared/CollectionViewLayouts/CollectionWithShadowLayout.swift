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

/// This is a special UICollectionViewFlowLayout that adds a background container with shadow shared for contiguous cells for
/// group cells that implement the CellWithShadow protocol in their view model.
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

  private var startPath: IndexPath?
  private var endPath: IndexPath?
  private var decorationIndex: Int = 0
  // cached decorated cell paths. This is necessary as `cellForItem` could return `nil` when the cell is not visible.
  fileprivate var decoratedCellPaths: Set<IndexPath> = []

  // swiftlint:disable discouraged_optional_collection
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    // swiftlint:enable discouraged_optional_collection
    let parent = super.layoutAttributesForElements(in: rect)
    guard let attributes = parent, !attributes.isEmpty else {
      return parent
    }

    var backgroundItemShadowAttributes: [UICollectionViewLayoutAttributes] = []

    if let collection = self.collectionView {
      // reset shadow index when layouting
      self.decorationIndex = 0
      for section in 0 ..< collection.numberOfSections {
        for item in 0 ..< collection.numberOfItems(inSection: section) {
          let path = IndexPath(item: item, section: section)

          if self.decoratedCellPaths.contains(path) {
            // start or extend decoration
            self.startOrExtendDecoration(with: path)
          } else {
            // close decoration
            if let attribute = self.decorationAttributes() {
              backgroundItemShadowAttributes.append(attribute)
            }
            self.closeDecoration()
          }
        }

        // section ended, close decoration if needed
        if let attribute = self.decorationAttributes() {
          backgroundItemShadowAttributes.append(attribute)
        }
        self.closeDecoration()
      }
    }

    return attributes + backgroundItemShadowAttributes
  }

  private func startOrExtendDecoration(with path: IndexPath) {
    if self.startPath == nil {
      self.startPath = path
    }
    self.endPath = path
  }

  private func closeDecoration() {
    self.startPath = nil
    self.endPath = nil
  }

  private func decorationAttributes() -> UICollectionViewLayoutAttributes? {
    guard
      let start = self.startPath,
      let end = self.endPath,
      let attribute = self.layoutAttributesForDecorationViewItem(from: start, to: end, index: self.decorationIndex)
    else {
      return nil
    }

    self.decorationIndex += 1
    return attribute
  }

  /// Layout attributes for the item-specific decoration view
  private func layoutAttributesForDecorationViewItem(
    from startingCell: IndexPath,
    to endingCell: IndexPath,
    index: Int
  ) -> UICollectionViewLayoutAttributes? {
    let decorationViewAttributes = UICollectionViewLayoutAttributes(
      forDecorationViewOfKind: self.decorationViewKind,
      with: IndexPath(item: index, section: 0)
    )

    guard
      let topItemAttributes = self.layoutAttributesForItem(at: startingCell),
      let bottomItemAttributes = self.layoutAttributesForItem(at: endingCell)
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

/// The view model of a cell that have a section shadow in the collection.
protocol CellWithShadow: ViewModel {}

extension UICollectionView {
  func updateDecoratedCellPaths(_ cellHasShadow: (IndexPath) -> Bool) {
    guard let layout = self.collectionViewLayout as? CollectionWithShadowLayout else {
      return
    }
    for section in 0 ..< self.numberOfSections {
      for item in 0 ..< self.numberOfItems(inSection: section) {
        let path = IndexPath(item: item, section: section)
        if cellHasShadow(path) {
          layout.decoratedCellPaths.insert(path)
        }
      }
    }
  }
}
