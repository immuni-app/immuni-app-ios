// PrivacyCheckboxCell.swift
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

struct PrivacyCheckboxCellVM: ViewModel, Equatable {
  let type: CellType
  let isSelected: Bool
  let isErrored: Bool
  let linkedURL: URL?

  func shouldInvalidateLayout(oldVM: Self?) -> Bool {
    return self != oldVM
  }

  var checkboxImage: UIImage {
    if self.isSelected {
      return Asset.Privacy.checkboxSelected.image
    } else if self.isErrored {
      return Asset.Privacy.checkboxError.image
    } else {
      return Asset.Privacy.checkbox.image
    }
  }

  var checkboxAccessibilityTraits: UIAccessibilityTraits {
    if self.isSelected {
      return [.button, .selected]
    } else {
      return .button
    }
  }
}

extension PrivacyCheckboxCellVM {
  enum CellType: Equatable {
    case above14
    case privacyNoticeRead

    var description: String {
      switch self {
      case .above14:
        return L10n.Privacy.Checkbox.above14
      case .privacyNoticeRead:
        return L10n.Privacy.Checkbox.privacyPolicyRead
      }
    }
  }
}

final class PrivacyCheckboxCell: UICollectionViewCell, ModellableView, ReusableView {
  private static let horizontalPadding: CGFloat = 25.0
  private static let verticalExternalPadding: CGFloat = 10.0
  private static let verticalInternalPadding: CGFloat = 25.0
  private static let imageToTextPadding: CGFloat = 15.0
  private static let imageDedicatedSize: CGFloat = 30.0

  var userDidTapCell: Interaction?
  var userDidTapURL: CustomInteraction<URL>?

  private var containerView = UIView()
  private var details = UITextView()
  private var checkbox = UIImageView()

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
    self.contentView.addSubview(self.containerView)

    self.containerView.addSubview(self.details)
    self.containerView.addSubview(self.checkbox)

    let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
    self.containerView.addGestureRecognizer(gesture)
  }

  func style() {
    Self.Style.shadow(self.contentView)
    self.checkbox.isAccessibilityElement = true
  }

  func update(oldModel: PrivacyCheckboxCellVM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.textualContent(self.details, content: model.type.description, url: model.linkedURL)
    Self.Style.checkbox(self.checkbox, image: model.checkboxImage)
    Self.Style.container(self.containerView, isErrored: model.isErrored)

    self.checkbox.accessibilityLabel = model.type.description.byStrippingXML
    self.checkbox.accessibilityTraits = model.checkboxAccessibilityTraits

    if model.shouldInvalidateLayout(oldVM: oldModel) {
      self.setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.containerView.pin.vertically(Self.verticalExternalPadding).horizontally(Self.horizontalPadding)

    // note: here we use imageDedicatedSize, instead of the real size, because
    // the visual space of the chexkbox is that one. However, the image with
    // the shadow is bigger
    self.details.pin
      .right((Self.horizontalPadding / 2.0).rounded(.up))
      .top(Self.verticalInternalPadding)
      .left(Self.horizontalPadding + Self.imageDedicatedSize + Self.imageToTextPadding)
      .sizeToFit(.width)

    self.checkbox.pin
      .sizeToFit()
      .before(of: self.details, aligned: .center)
      .left(Self.horizontalPadding - Self.imageToTextPadding)
      .justify(.center)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let availableSpace = size.width
      - Self.horizontalPadding * 2 // external container
      - Self.horizontalPadding // internal container (left)
      - Self.horizontalPadding / 2.0 // internal container (right)
      - Self.imageDedicatedSize
      - Self.imageToTextPadding

    let labelSpace = CGSize(
      width: availableSpace.rounded(.down),
      height: .infinity
    )

    let labelSize = self.details.sizeThatFits(labelSpace)

    let cellHeight = labelSize.height
      + 2 * Self.verticalExternalPadding // top and bottom external container (needed for shadows)
      + 2 * Self.verticalInternalPadding // top and bottom internal contaienr

    return CGSize(width: size.width, height: cellHeight)
  }

  @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
    guard
      self.details.frame.contains(gestureRecognizer.location(in: self.containerView)),
      let textPosition = self.details.closestPosition(to: gestureRecognizer.location(in: self.details)),
      let url = self.details.textStyling(at: textPosition, in: .forward)?[NSAttributedString.Key.link] as? URL,
      let modelURL = self.model?.linkedURL,
      url == modelURL
    else {
      self.userDidTapCell?()
      return
    }

    self.userDidTapURL?(url)
  }
}

private extension PrivacyCheckboxCell {
  enum Style {
    static func textualContent(_ textView: UITextView, content: String, url: URL?) {
      textView.isSelectable = false
      textView.isEditable = false
      textView.isScrollEnabled = false
      textView.backgroundColor = .clear
      textView.linkTextAttributes = [.foregroundColor: Palette.primary]

      var tosStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.primary),
        .underline(.single, Palette.primary)
      )

      tosStyle.link = url

      let textStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.grayDark),
        .alignment(.left),
        .lineBreakMode(.byWordWrapping),
        .xmlRules([
          .style("l", tosStyle)
        ])
      )

      textView.attributedText = content.styled(with: textStyle).adapted()
      textView.isUserInteractionEnabled = false
    }

    static func checkbox(_ imageView: UIImageView, image: UIImage) {
      imageView.image = image
      imageView.contentMode = .scaleAspectFit
    }

    static func shadow(_ view: UIView) {
      view.addShadow(.headerLightBlue)
    }

    static func container(_ view: UIView, isErrored: Bool) {
      view.backgroundColor = Palette.white
      view.layer.cornerRadius = SharedStyle.cardCornerRadius

      view.layer.borderColor = Palette.redLight.cgColor
      view.layer.borderWidth = isErrored ? 2 : 0
    }
  }
}
