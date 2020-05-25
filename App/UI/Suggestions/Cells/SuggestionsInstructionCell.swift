// SuggestionsInstructionCell.swift
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
import Tempura

struct SuggestionsInstructionCellVM: ViewModel {
  enum Instruction {
    case ministerialDecree
    case washHands
    case useNapkins
    case socialDistance
    case wearMask
    case checkSymptoms
    case isolate
  }

  let instruction: Instruction

  var title: String {
    switch self.instruction {
    case .ministerialDecree:
      return L10n.Suggestions.Instruction.ministerialDecree
    case .washHands:
      return L10n.Suggestions.Instruction.washHands
    case .useNapkins:
      return L10n.Suggestions.Instruction.useNapkins
    case .socialDistance:
      return L10n.Suggestions.Instruction.socialDistance
    case .wearMask:
      return L10n.Suggestions.Instruction.mask
    case .checkSymptoms:
      return L10n.Suggestions.Instruction.CheckSymptoms.title
    case .isolate:
      return L10n.Suggestions.Instruction.Isolate.title
    }
  }

  var icon: UIImage {
    switch self.instruction {
    case .ministerialDecree:
      return Asset.Suggestions.ministry.image
    case .washHands:
      return Asset.Suggestions.washHands.image
    case .useNapkins:
      return Asset.Suggestions.useNapkins.image
    case .socialDistance:
      return Asset.Suggestions.socialDistance.image
    case .wearMask:
      return Asset.Suggestions.mask.image
    case .checkSymptoms:
      return Asset.Suggestions.checkSymptoms.image
    case .isolate:
      return Asset.Suggestions.isolate.image
    }
  }
}

class SuggestionsInstructionCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = SuggestionsInstructionCellVM

  private static let imageSize: CGFloat = 40
  private static let contentInset: CGFloat = 20
  private static let imageToMessage: CGFloat = 15
  private static let totalHorizontalMargin: CGFloat =
    2 * SuggestionsView.cellContainerInset + SuggestionsInstructionCell.imageSize +
      SuggestionsInstructionCell.imageToMessage + 2 * SuggestionsInstructionCell.contentInset

  let container = UIView()
  let message = UILabel()
  let icon = UIImageView()

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
    self.contentView.addSubview(self.container)
    self.container.addSubview(self.message)
    self.container.addSubview(self.icon)
  }

  func style() {
    Self.Style.container(self.container)
    Self.Style.shadow(self.contentView)
  }

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.title(self.message, content: model.title)
    Self.Style.icon(self.icon, icon: model.icon)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.container.pin
      .top()
      .bottom()
      .horizontally(SuggestionsView.cellContainerInset)

    self.icon.pin
      .size(Self.imageSize)
      .left(Self.contentInset)
      .vCenter()

    self.message.pin
      .left(Self.imageSize + Self.contentInset + Self.imageToMessage)
      .right(Self.contentInset)
      .sizeToFit(.width)
      .vCenter()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - SuggestionsInstructionCell.totalHorizontalMargin
    let titleSize = self.message.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))

    return CGSize(width: size.width, height: titleSize.height + 2 * SuggestionsView.cellContainerInset)
  }
}

private extension SuggestionsInstructionCell {
  enum Style {
    static func container(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.layer.masksToBounds = true
    }

    static func shadow(_ view: UIView) {
      view.layer.masksToBounds = false
      view.addShadow(.cardLightBlue)
    }

    static func icon(_ view: UIImageView, icon: UIImage) {
      view.image = icon
      view.contentMode = .scaleAspectFit
    }

    static func title(_ label: UILabel, content: String) {
      let boldStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.grayDark),
        .alignment(.left)
      )
      let textStyle = TextStyles.p.byAdding(
        .color(Palette.grayDark),
        .alignment(.left),
        .xmlRules([.style("b", boldStyle)])
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }
  }
}
