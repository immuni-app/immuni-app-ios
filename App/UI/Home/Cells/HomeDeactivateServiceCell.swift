// HomeDeactivateServiceCell.swift
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

import Extensions
import Foundation
import Lottie
import Tempura

struct HomeDeactivateServiceCellVM: ViewModel {
  let isEnabled: Bool
}

class HomeDeactivateServiceCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = HomeDeactivateServiceCellVM

  static let iconSize: CGFloat = 27
  static let iconToTitle: CGFloat = 8

  let button = ButtonWithInsets()

  var didTapButton: Interaction?

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.style()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
    self.style()
  }

  override var isHighlighted: Bool {
    didSet {
      self.button.isHighlighted = self.isHighlighted
    }
  }

  func setup() {
    self.contentView.addSubview(self.button)

    self.button.on(.touchUpInside) { [weak self] _ in
      guard self?.model?.isEnabled == true else {
        return
      }
      self?.didTapButton?()
    }
  }

  func style() {
    Self.Style.actionButton(self.button)
  }

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    self.button.isEnabled = model.isEnabled
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.button.pin
      .size(self.buttonSize(for: self.bounds.width))
      .hCenter()
      .vCenter()
  }

  func buttonSize(for width: CGFloat) -> CGSize {
    let labelWidth = width - 2 * HomeView.cellHorizontalInset - HomeDeactivateServiceCell.iconSize
      - self.button.insets.horizontal - self.button.titleEdgeInsets.horizontal
    var buttonSize = self.button.titleLabel?.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity)) ?? .zero
    buttonSize.width += HomeDeactivateServiceCell.iconSize + HomeDeactivateServiceCell.iconToTitle + self.button.insets.horizontal
    buttonSize.height = max(buttonSize.height, HomeDeactivateServiceCell.iconSize) + self.button.insets.vertical

    return buttonSize
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let buttonSize = self.buttonSize(for: size.width)

    return CGSize(width: size.width, height: buttonSize.height + 100)
  }
}

private extension HomeDeactivateServiceCell {
  enum Style {
    static func actionButton(_ button: ButtonWithInsets) {
      SharedStyle.primaryButton(
        button,
        title: L10n.HomeView.Service.deactivate,
        icon: Asset.Home.disableService.image,
        spacing: HomeDeactivateServiceCell.iconToTitle,
        tintColor: Palette.white,
        backgroundColor: Palette.grayDark,
        insets: UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 20),
        cornerRadius: 21,
        shadow: .grayDark
      )
    }
  }
}
