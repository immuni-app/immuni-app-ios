// CustomerSupportContactCell.swift
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
import Tempura

struct CustomerSupportContactCellVM: ViewModel {
  enum Kind: Equatable {
    case email(email: String)
    case phone(number: String, openingTime: String, closingTime: String)
  }

  let kind: Kind

  func shouldInvalidateLayout(oldVM: Self?) -> Bool {
    guard let oldVM = oldVM else {
      return true
    }

    return self.kind != oldVM.kind
  }

  var icon: UIImage {
    switch self.kind {
    case .email:
      return Asset.Settings.ContactSupport.email.image
    case .phone:
      return Asset.Settings.ContactSupport.call.image
    }
  }

  var title: String {
    switch self.kind {
    case .email:
      return L10n.Support.Email.title
    case .phone:
      return L10n.Support.Phone.title
    }
  }

  var subtitle: String {
    switch self.kind {
    case .email:
      return L10n.Support.Email.description
    case .phone(_, let opening, let closing):
      return L10n.Support.Phone.description(opening, closing)
    }
  }

  var contact: String {
    switch self.kind {
    case .email(let email):
      return email
    case .phone(let number, _, _):
      return number
    }
  }
}

final class CustomerSupportContactCell: UICollectionViewCell, ModellableView, ReusableView {
  private static let iconSize: CGFloat = 28.0
  private static let iconToText: CGFloat = 13.0
  private static let textPadding: CGFloat = 5.0
  private static let horizontalPadding: CGFloat = 30.0
  private static let verticalPadding: CGFloat = 12.0

  private let icon = UIImageView()
  private let title = UILabel()
  private let subtitle = UILabel()
  private var contactButton = TextButton()

  var didTapContact: CustomInteraction<CustomerSupportContactCellVM.Kind>?

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

  override var isHighlighted: Bool {
    didSet {
      self.contactButton.isHighlighted = self.isHighlighted
    }
  }

  func setup() {
    self.contentView.addSubview(self.icon)
    self.contentView.addSubview(self.title)
    self.contentView.addSubview(self.subtitle)
    self.contentView.addSubview(self.contactButton)

    self.contactButton.on(.touchUpInside) { [weak self] _ in
      guard let kind = self?.model?.kind else {
        return
      }
      self?.didTapContact?(kind)
    }
  }

  func style() {}

  func update(oldModel: CustomerSupportContactCellVM?) {
    guard let model = self.model else {
      return
    }

    self.icon.image = model.icon
    Self.Style.title(self.title, content: model.title)
    Self.Style.subtitle(self.subtitle, content: model.subtitle)
    Self.Style.contactButton(self.contactButton, content: model.contact)

    if model.shouldInvalidateLayout(oldVM: oldModel) {
      self.setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.icon.pin
      .size(Self.iconSize)
      .left(Self.horizontalPadding)
      .vCenter()

    self.title.pin
      .left(Self.iconSize + Self.horizontalPadding + Self.iconToText)
      .right(Self.horizontalPadding)
      .sizeToFit(.width)
      .top(Self.verticalPadding)

    self.subtitle.pin
      .left(to: self.title.edge.left)
      .right(to: self.title.edge.right)
      .sizeToFit(.width)
      .below(of: self.title)
      .marginTop(Self.textPadding)

    self.contactButton.pin
      .left(to: self.subtitle.edge.left)
      .right(to: self.subtitle.edge.right)
      .sizeToFit(.width)
      .below(of: self.subtitle)
      .marginTop(Self.textPadding)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let space = CGSize(width: size.width - 2 * Self.horizontalPadding - Self.iconToText - Self.iconSize, height: .infinity)
    let titleSize = self.title.sizeThatFits(space)
    let subtitleSize = self.subtitle.sizeThatFits(space)
    let buttonSize = self.contactButton.sizeThatFits(space)
    return CGSize(
      width: size.width,
      height: titleSize.height + subtitleSize.height + buttonSize.height + 2 * Self.textPadding + 2 * Self.verticalPadding
    )
  }
}

extension CustomerSupportContactCell {
  enum Style {
    static func title(_ label: UILabel, content: String) {
      let textStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.grayDark)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }

    static func subtitle(_ label: UILabel, content: String) {
      let textStyle = TextStyles.s.byAdding(
        .color(Palette.grayNormal)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }

    static func contactButton(_ button: TextButton, content: String) {
      let textStyle = TextStyles.pLink.byAdding(
        .color(Palette.primary),
        .underline(.single, Palette.primary)
      )

      button.contentHorizontalAlignment = .left
      button.attributedTitle = content.styled(with: textStyle)
    }
  }
}
