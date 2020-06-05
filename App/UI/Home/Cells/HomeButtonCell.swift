//
//  HomeButtonCell.swift
//  DebugMenu
//
//  Created by Paride on 05/06/2020.
//

import Extensions
import Foundation
import Lottie
import Tempura

struct HomeButtonCellVM: ViewModel {
  let isEnabled: Bool
}

class HomeButtonCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = HomeButtonCellVM

  static let iconSize: CGFloat = 27

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
    let labelWidth = width - 2 * HomeView.cellHorizontalInset - HomeButtonCell.iconSize
    var buttonSize = self.button.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    buttonSize.width += HomeButtonCell.iconSize
    return buttonSize
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let buttonSize = self.buttonSize(for: size.width)

    return CGSize(width: size.width, height: buttonSize.height + 100)
  }
}

private extension HomeButtonCell {
  enum Style {
    static func actionButton(_ button: ButtonWithInsets) {
      SharedStyle.primaryButton(
        button,
        title: L10n.HomeView.Service.deactivate,
        icon: Asset.Home.disableService.image,
        spacing: 8,
        tintColor: Palette.white,
        backgroundColor: Palette.grayDark,
        insets: UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 20),
        cornerRadius: 21,
        shadow: .grayDark
      )
    }
  }
}
