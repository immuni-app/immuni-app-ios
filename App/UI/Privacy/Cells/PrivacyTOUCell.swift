// PrivacyTOUCell.swift
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

import BonMot
import Extensions
import Foundation
import Katana
import PinLayout
import Tempura

struct PrivacyTOUCellVM: ViewModel, Equatable {
  let content: String
  let tosURL: URL?

  func shouldInvalidateLayout(oldVM: Self?) -> Bool {
    return self != oldVM
  }
}

final class PrivacyTOUCell: UICollectionViewCell, ModellableView, ReusableView {
  private static let horizontalPadding: CGFloat = 30.0

  var userDidTapURL: CustomInteraction<URL>?

  private var content = UITextView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.style()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.setup()
    self.style()
  }

  func setup() {
    self.contentView.addSubview(self.content)

    let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
    self.content.addGestureRecognizer(gesture)
  }

  func style() {}

  func update(oldModel: PrivacyTOUCellVM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.content(self.content, content: model.content, url: model.tosURL)

    if model.shouldInvalidateLayout(oldVM: oldModel) {
      self.setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.content.pin
      .top()
      .right(Self.horizontalPadding)
      .bottom()
      .left(Self.horizontalPadding)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let space = CGSize(width: size.width - 2 * Self.horizontalPadding, height: .infinity)
    let labelSize = self.content.sizeThatFits(space)

    return CGSize(width: size.width, height: labelSize.height)
  }
}

extension PrivacyTOUCell {
  @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
    guard
      let textPosition = self.content.closestPosition(to: gestureRecognizer.location(in: self.content)),
      let url = self.content.textStyling(at: textPosition, in: .forward)?[NSAttributedString.Key.link] as? URL,
      let modelURL = self.model?.tosURL,
      url == modelURL
    else {
      return
    }

    self.userDidTapURL?(url)
  }
}

private extension PrivacyTOUCell {
  enum Style {
    static func content(_ textView: UITextView, content: String, url: URL?) {
      textView.isSelectable = false
      textView.isEditable = false
      textView.isScrollEnabled = false
      textView.backgroundColor = .clear
      textView.linkTextAttributes = [.foregroundColor: Palette.primary]

      var tosStyle = TextStyles.s.byAdding(
        .color(Palette.primary),
        .underline(.single, Palette.primary)
      )

      tosStyle.link = url

      let textStyle = TextStyles.s.byAdding(
        .color(Palette.grayNormal),
        .alignment(.left),
        .lineBreakMode(.byWordWrapping),
        .xmlRules([
          .style("l", tosStyle)
        ])
      )

      textView.attributedText = content.styled(with: textStyle).adapted()
    }
  }
}
