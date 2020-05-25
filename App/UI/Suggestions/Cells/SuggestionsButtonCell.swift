// SuggestionsButtonCell.swift
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
import Models
import Tempura

struct SuggestionsButtonCellVM: ViewModel {
  enum ButtonInteraction: Equatable {
    case dismissContactNotifications
    case dismissCovidNotifications
    case covidNegative
  }

  let interaction: ButtonInteraction

  static func titleStyle(color: UIColor) -> TextStyles {
    return TextStyles.h4Bold.byAdding([
      .color(color),
      .alignment(.center)
    ])
  }

  static func underlinedTitleStyle(color: UIColor) -> TextStyles {
    return TextStyles.pLink.byAdding([
      .color(color),
      .alignment(.left)
    ])
  }

  var useSmallStyle: Bool {
    switch self.interaction {
    case .dismissContactNotifications:
      return true
    case .dismissCovidNotifications, .covidNegative:
      return false
    }
  }

  var title: String {
    switch self.interaction {
    case .dismissContactNotifications:
      return L10n.Suggestions.Instruction.HideIfContactDoctor.action
    case .dismissCovidNotifications:
      return L10n.Suggestions.Instruction.HideAlert.action
    case .covidNegative:
      return L10n.Suggestions.Positive.CovidNegative.action
    }
  }

  var backgroundColor: UIColor {
    return self.useSmallStyle ? .clear : Palette.grayPurple
  }

  var tintColor: UIColor {
    return self.useSmallStyle ? Palette.grayNormal : Palette.white
  }

  var shadow: UIView.Shadow {
    return self.useSmallStyle ? .none : .cardPurple
  }

  var textStyle: TextStyles {
    return self.useSmallStyle ? Self.underlinedTitleStyle(color: self.tintColor) : Self.titleStyle(color: self.tintColor)
  }

  var cornerRadius: CGFloat {
    return self.useSmallStyle ? 0 : 25
  }

  var contentAlignment: UIControl.ContentHorizontalAlignment {
    return self.useSmallStyle ? .left : .center
  }
}

class SuggestionsButtonCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = SuggestionsButtonCellVM

  var button = ButtonWithInsets()
  var didTapButton: CustomInteraction<SuggestionsButtonCellVM.ButtonInteraction>?

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

  func setup() {
    self.contentView.addSubview(self.button)

    self.button.on(.touchUpInside) { [weak self] _ in
      guard let interaction = self?.model?.interaction else {
        return
      }
      self?.didTapButton?(interaction)
    }
  }

  func style() {
    Self.Style.buttonBase(self.button)
  }

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    self.button.setBackgroundColor(model.backgroundColor, for: .normal)
    self.button.setAttributedTitle(model.title.styled(with: model.textStyle), for: .normal)
    self.button.tintColor = model.tintColor
    self.button.addShadow(model.shadow)
    self.button.layer.cornerRadius = model.cornerRadius
    self.button.contentHorizontalAlignment = model.contentAlignment

    self.setNeedsLayout()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.button.pin
      .horizontally(SuggestionsView.cellMessageInset)
      .vertically()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let buttonWidth = size.width - 2 * SuggestionsView.cellMessageInset
    let labelWidth = buttonWidth - self.button.insets.horizontal
    let titleSize = self.button.titleLabel?.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity)) ?? .zero

    let useSmallStyle = self.model?.useSmallStyle ?? false
    let minimumButtonHeight: CGFloat = useSmallStyle ? 40 : 52
    let buttonHeight = min(minimumButtonHeight, titleSize.height + self.button.insets.vertical)

    return CGSize(width: size.width, height: buttonHeight)
  }
}

private extension SuggestionsButtonCell {
  enum Style {
    static func buttonBase(_ button: ButtonWithInsets) {
      button.insets = UIEdgeInsets(deltaX: 30, deltaY: 15)
      button.titleLabel?.numberOfLines = 0
      button.adjustsImageWhenHighlighted = false
      button.setOverlayOpacity(0, for: .highlighted)
      button.setOpacity(0.85, for: .highlighted)
    }
  }
}
