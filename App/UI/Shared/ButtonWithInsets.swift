// ButtonWithInsets.swift
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

class ButtonWithInsets: Button {
  // MARK: - Properties

  var insets: UIEdgeInsets

  // MARK: Initialization

  init(frame: CGRect = .zero, insets: UIEdgeInsets = .zero) {
    self.insets = insets
    super.init(frame: frame)
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // override to adapt attributed string to the current trait collection
  override func setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) {
    let scaled = title?.adapted()
    super.setAttributedTitle(scaled, for: state)
  }

  // MARK: - Layout

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let insetRect = CGRect(origin: .zero, size: size).inset(by: self.insets)
    let size = super.sizeThatFits(insetRect.size)
    return CGSize(
      width: size.width + self.insets.horizontal,
      height: size.height + self.insets.vertical
    )
  }
}
