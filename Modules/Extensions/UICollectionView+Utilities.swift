// UICollectionView+Utilities.swift
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
import UIKit

public extension UICollectionView {
  /// Helper to dequeue a cell with proper typing
  /// - parameter: the type of cell to dequeue
  /// - indexPath: the indexpath of the cell
  /// - warning: the method will crahs in case of wrong combination of type and indexpath
  func dequeueReusableCell<C: ReusableView>(_ type: C.Type, for indexPath: IndexPath) -> C {
    let cell = self.dequeueReusableCell(withReuseIdentifier: type.reuseIdentifier, for: indexPath)
    let typedCell = cell as? C ?? LibLogger.fatalError("Cannot decode cell for \(indexPath) of type \(type)")
    return typedCell
  }

  /// Register a cell
  func register<C: ReusableView>(_ cellClass: C.Type) {
    self.register(cellClass, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
  }

  /// Helper to dequeue an header with proper typing
  /// - parameter: the type of header to dequeue
  /// - indexPath: the indexpath of the header
  /// - warning: the method will crahs in case of wrong combination of type and indexpath
  func dequeueReusableHeader<C: ReusableView>(_ type: C.Type, for indexPath: IndexPath) -> C {
    let header = self.dequeueReusableSupplementaryView(
      ofKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: type.reuseIdentifier,
      for: indexPath
    )
    let typedHeader = header as? C ?? LibLogger.fatalError("Cannot decode header for \(indexPath) of type \(type)")
    return typedHeader
  }

  /// Register an header
  func registerHeader<C: ReusableView>(_ cellClass: C.Type) {
    self.register(
      cellClass,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: cellClass.reuseIdentifier
    )
  }

  /// Helper to dequeue an header with proper typing
  /// - parameter: the type of header to dequeue
  /// - indexPath: the indexpath of the header
  /// - warning: the method will crahs in case of wrong combination of type and indexpath
  func dequeueReusableFooter<C: ReusableView>(_ type: C.Type, for indexPath: IndexPath) -> C {
    let header = self.dequeueReusableSupplementaryView(
      ofKind: UICollectionView.elementKindSectionFooter,
      withReuseIdentifier: type.reuseIdentifier,
      for: indexPath
    )
    let typedHeader = header as? C ?? LibLogger.fatalError("Cannot decode footer for \(indexPath) of type \(type)")
    return typedHeader
  }

  /// Register an header
  func registerFooter<C: ReusableView>(_ cellClass: C.Type) {
    self.register(
      cellClass,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
      withReuseIdentifier: cellClass.reuseIdentifier
    )
  }
}

/// A protocol that aguments an `UIView` with a reuse identifier. Meant to be used for `UICollectionViewCell`
/// and `UICollectionReusableView`.
public protocol ReusableView: UIView {
  /// The reusable identifier of the cell
  static var reuseIdentifier: String { get }
}

public extension ReusableView {
  static var reuseIdentifier: String {
    String(describing: self.self)
  }
}
