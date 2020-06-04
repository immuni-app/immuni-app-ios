// SuggestionsMessageCell.swift
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

struct SuggestionsMessageCellVM: ViewModel {
  let message: String
}

class SuggestionsMessageCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = SuggestionsMessageCellVM

  let message = UITextView()

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
    self.contentView.addSubview(self.message)
  }

  func style() {}

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.title(self.message, content: model.message, url: nil)

    self.setNeedsLayout()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.message.pin
      .horizontally(SuggestionsView.cellMessageInset)
      .sizeToFit(.width)
      .vCenter()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - 2 * SuggestionsView.cellMessageInset
    let titleSize = self.message.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))

    return CGSize(width: size.width, height: titleSize.height)
  }
}

private extension SuggestionsMessageCell {
  enum Style {
    static func title(_ textView: UITextView, content: String, url: URL?) {
      textView.isSelectable = false
      textView.isEditable = false
      textView.isScrollEnabled = false
      textView.isUserInteractionEnabled = false
      textView.backgroundColor = .clear
      textView.linkTextAttributes = [.foregroundColor: Palette.primary]

      let boldStyle = TextStyles.pSemibold.byAdding(
        // note: it looks like that by removing this parameter
        // (which shouldn't be necessary) the calculation of
        // the height breaks
        .lineBreakMode(.byWordWrapping),
        .color(Palette.grayDark)
      )

      let linkStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.primary),
        .underline(.single, Palette.primary)
      )

      let textStyle = TextStyles.p.byAdding(
        .lineBreakMode(.byWordWrapping),
        .color(Palette.grayDark),
        .alignment(.left),
        .xmlRules([
          .style("b", boldStyle),
          .style("l", linkStyle)
        ])
      )

      textView.attributedText = content.styled(with: textStyle).adapted()
    }
  }
}
