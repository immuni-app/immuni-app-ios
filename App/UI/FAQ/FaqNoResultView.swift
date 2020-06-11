// FaqNoResultView.swift
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

class FaqNoResultView: UIView {
  override public init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.style()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
    self.style()
  }

  private let icon = UIImageView()
  private let title = UILabel()
  private let subtitle = UILabel()

  func setup() {
    self.addSubview(self.icon)
    self.addSubview(self.title)
    self.addSubview(self.subtitle)
  }

  func style() {
    Self.Style.icon(self.icon)
    Self.Style.title(self.title)
    Self.Style.subtitle(self.subtitle)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.icon.pin
      .sizeToFit()
      .top()
      .hCenter()

    self.title.pin
      .horizontally()
      .sizeToFit(.width)
      .below(of: self.icon)
      .marginTop(30)

    self.subtitle.pin
      .horizontally()
      .sizeToFit(.width)
      .bottom()
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth: CGFloat = 260
    let iconSize = self.icon.intrinsicContentSize
    let titleSize = self.title.sizeThatFits(CGSize(width: labelWidth, height: .infinity))
    let subtitleSize = self.subtitle.sizeThatFits(CGSize(width: labelWidth, height: .infinity))

    return CGSize(width: labelWidth, height: iconSize.height + titleSize.height + subtitleSize.height + 40)
  }
}

extension FaqNoResultView {
  enum Style {
    static func icon(_ view: UIImageView) {
      view.image = Asset.Settings.Faq.noFaq.image
    }

    static func title(_ label: UILabel) {
      let textStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.grayDark),
        .alignment(.center)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: L10n.Faq.NoResult.title,
        style: textStyle
      )
    }

    static func subtitle(_ label: UILabel) {
      let textStyle = TextStyles.p.byAdding(
        .color(Palette.grayNormal),
        .alignment(.center)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: L10n.Faq.NoResult.message,
        style: textStyle
      )
    }
  }
}
