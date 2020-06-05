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
}

class HomeButtonCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = HomeButtonCellVM

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

  func update(oldModel: VM?) {}

  override func layoutSubviews() {
    super.layoutSubviews()

    let labelWidth = self.bounds.width - 2 * HomeView.cellHorizontalInset
    let buttonSize = self.button.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))

    self.button.pin
      .size(buttonSize)
      .hCenter()
      .vCenter()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - 2 * HomeView.cellHorizontalInset
    let buttonSize = self.button.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))

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
        insets: UIEdgeInsets(deltaX: 10, deltaY: 8),
        cornerRadius: 21,
        shadow: .grayDark
      )
    }
  }
}
