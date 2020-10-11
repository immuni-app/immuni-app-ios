// SettingCell.swift
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

struct SettingCellVM: ViewModel, CellWithShadow {
  let setting: SettingsVM.Setting
  let shouldShowSeparator: Bool

  var title: String {
    switch self.setting {
    case .loadData:
      return L10n.Settings.Setting.loadData
    case .faq:
      return L10n.Settings.Setting.faq
    case .tos:
      return L10n.Settings.Setting.tos
    case .privacy:
      return L10n.Settings.Setting.privacy
    case .chageProvince:
      return L10n.Settings.Setting.chageProvince
    case .updateCountry:
      return L10n.Settings.Setting.chageCountries
    case .shareApp:
      return L10n.Settings.Setting.share
    case .leaveReview:
      return L10n.Settings.Setting.leaveReview
    case .customerSupport:
      return L10n.Settings.Setting.contactSupport
    case .debugUtilities:
      return L10n.Settings.Setting.debugUtilities
    }
  }

  var icon: UIImage? {
    switch self.setting {
    case .loadData, .faq:
      return Asset.Settings.settingsNext.image
    case .shareApp:
      return Asset.Settings.settingsShare.image
    case .tos, .privacy, .chageProvince, .updateCountry, .leaveReview, .customerSupport, .debugUtilities:
      return nil
    }
  }

  var shouldShowIcon: Bool {
    return self.icon != nil
  }
}

class SettingCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = SettingCellVM

  static let cellInset: CGFloat = 25
  static let iconInset: CGFloat = 30
  static let iconSize: CGFloat = 24
  static let titleToIcon: CGFloat = 15

  let title = UILabel()
  let separator = UIView()
  let icon = UIImageView()
  var overlayButton = Button()

  var didTapCell: CustomInteraction<SettingsVM.Setting>?

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
    self.contentView.addSubview(self.title)
    self.contentView.addSubview(self.separator)
    self.contentView.addSubview(self.icon)
    self.contentView.addSubview(self.overlayButton)

    self.title.isAccessibilityElement = false
    self.overlayButton.isAccessibilityElement = true

    self.overlayButton.on(.touchUpInside) { [weak self] _ in
      guard let setting = self?.model?.setting else {
        return
      }
      self?.didTapCell?(setting)
    }
  }

  func style() {
    Self.Style.container(self.contentView)
    Self.Style.separator(self.separator)
    Self.Style.overlayButton(self.overlayButton)
  }

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.title(self.title, content: model.title)
    Self.Style.icon(self.icon, icon: model.icon)

    self.overlayButton.accessibilityLabel = model.title

    self.separator.isHidden = !model.shouldShowSeparator
    self.icon.isHidden = !model.shouldShowIcon

    self.setNeedsLayout()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.separator.pin
      .bottom()
      .horizontally(SettingsView.collectionInset + Self.cellInset)
      .height(1)

    self.icon.pin
      .right(SettingsView.collectionInset + Self.iconInset)
      .vCenter()
      .size(Self.iconSize)

    let shouldShowIcon = self.model?.shouldShowIcon ?? false

    if shouldShowIcon {
      self.title.pin
        .left(SettingsView.collectionInset + Self.cellInset)
        .before(of: self.icon)
        .marginRight(Self.titleToIcon)
        .sizeToFit(.width)
        .vCenter()
    } else {
      self.title.pin
        .horizontally(SettingsView.collectionInset + Self.cellInset)
        .sizeToFit(.width)
        .vCenter()
    }

    self.overlayButton.pin
      .horizontally(SettingsView.collectionInset + 10)
      .vertically(10)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let shouldShowIcon = self.model?.shouldShowIcon ?? false
    let labelWidth = shouldShowIcon ?
      size.width - 2 * SettingsView.collectionInset - Self.cellInset - Self.titleToIcon - Self.iconSize - Self.iconInset
      :
      size.width - 2 * (SettingsView.collectionInset + Self.cellInset)
    let titleSize = self.title.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    return CGSize(width: size.width, height: titleSize.height + 45)
  }
}

private extension SettingCell {
  enum Style {
    static func container(_ view: UIView) {
      view.backgroundColor = .clear
    }

    static func separator(_ view: UIView) {
      view.backgroundColor = Palette.grayExtraWhite
    }

    static func icon(_ view: UIImageView, icon: UIImage?) {
      view.image = icon
    }

    static func overlayButton(_ button: Button) {
      button.setBackgroundColor(Palette.white.withAlphaComponent(0.4), for: .highlighted)
      button.adjustsImageWhenHighlighted = false
      button.setOverlayOpacity(0, for: .highlighted)
      button.accessibilityTraits = .button
    }

    static func title(_ label: UILabel, content: String) {
      let textStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.grayDark),
        .alignment(.left)
      )

      TempuraStyles.styleShrinkableLabel(
        label,
        content: content,
        style: textStyle
      )
    }
  }
}
