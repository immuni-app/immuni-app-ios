// SuggestionsHeaderCell.swift
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

struct SuggestionsHeaderCellVM: ViewModel {
  let covidStatus: CovidStatus
  let dayOfContact: CalendarDay?

  var dayOfContactString: String {
    return self.dayOfContact?.dateString ?? ""
  }

  var gradient: Gradient? {
    switch self.covidStatus {
    case .neutral:
      return nil
    case .positive:
      return Palette.gradientPrimary
    case .risk:
      return Palette.gradientRed
    }
  }

  var shadow: UIView.Shadow {
    switch self.covidStatus {
    case .neutral, .positive:
      return .cardPrimary
    case .risk:
      return .cardRed
    }
  }

  var title: String {
    switch self.covidStatus {
    case .neutral:
      return L10n.Suggestions.Header.ShortTitle.neutral
    case .risk:
      return L10n.Suggestions.Risk.title
    case .positive:
      return L10n.Suggestions.Positive.title
    }
  }

  var subtitle: String {
    switch self.covidStatus {
    case .neutral:
      return ""
    case .risk:
      return L10n.Suggestions.Risk.subtitle(self.dayOfContactString)
    case .positive:
      return L10n.Suggestions.Positive.subtitle
    }
  }

  var image: UIImage? {
    switch self.covidStatus {
    case .neutral:
      return Asset.Suggestions.doctorBig.image
    case .risk, .positive:
      return nil
    }
  }

  var shouldShowImage: Bool {
    return self.image != nil
  }

  var shouldShowGradient: Bool {
    return self.gradient != nil
  }
}

class SuggestionsHeaderCell: UICollectionViewCell, ModellableView, ReusableView, StickyCell {
  typealias VM = SuggestionsHeaderCellVM
  private static let topOffset: CGFloat = 60
  private static let titleToSubtitle: CGFloat = 10
  private static let bottomOffset: CGFloat = 30
  private static let labelIconMargin: CGFloat = UIDevice.getByScreen(normal: 160, narrow: 120)
  private static let totalVerticalOffset: CGFloat =
    SuggestionsHeaderCell.topOffset + SuggestionsHeaderCell.bottomOffset + SuggestionsHeaderCell.titleToSubtitle

  let shadow = UIView()
  let container = UIView()
  let gradient = GradientView()
  let title = UILabel()
  let subtitle = UILabel()
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
    self.contentView.addSubview(self.shadow)
    self.shadow.addSubview(self.container)
    self.container.addSubview(self.gradient)
    self.container.addSubview(self.title)
    self.container.addSubview(self.subtitle)
    self.container.addSubview(self.icon)
  }

  func style() {
    Self.Style.background(self)
    Self.Style.container(self.container)
  }

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.shadow(self.shadow, shadow: model.shadow)
    Self.Style.gradient(self.gradient, gradient: model.gradient)
    Self.Style.title(self.title, content: model.title)
    Self.Style.subtitle(self.subtitle, content: model.subtitle)
    Self.Style.icon(self.icon, image: model.image)
  }

  var minimumHeight: CGFloat {
    guard let suggestionsView = self.superview?.superview as? SuggestionsView else {
      return 77
    }
    // return the height of the header view to support all font sizes.
    return suggestionsView.headerView.bounds.height
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.shadow.pin.all()
    self.container.pin.all()
    self.gradient.pin.all()

    let shouldShowImage = self.model?.shouldShowImage ?? false
    let rightMargin = shouldShowImage ? Self.labelIconMargin : HomeView.cellHorizontalInset

    self.title.pin
      .left(SuggestionsView.cellMessageInset)
      .right(rightMargin)
      .sizeToFit(.width)

    self.subtitle.pin
      .left(SuggestionsView.cellMessageInset)
      .right(rightMargin)
      .sizeToFit(.width)

    let neededHeight = self.title.bounds.height + self.subtitle.bounds.height + Self.totalVerticalOffset
    if neededHeight > self.bounds.height {
      // layout top to bottom
      self.title.pin
        .top(Self.topOffset)

      self.subtitle.pin
        .below(of: self.title)
        .marginTop(Self.titleToSubtitle)
    } else {
      // layout bottom to top
      self.subtitle.pin
        .bottom(Self.bottomOffset)

      self.title.pin
        .above(of: self.subtitle)
        .marginBottom(Self.titleToSubtitle)
    }

    if shouldShowImage {
      self.icon.pin
        .bottom()
        .right()
        .aspectRatio(self.icon.intrinsicContentSize.width / self.icon.intrinsicContentSize.height)
        .width(Self.labelIconMargin)
    }

    self.updateAfterLayout()
  }

  private func updateAfterLayout() {
    // Needed to handle bottom corners' shadow.
    self.backgroundColor = (self.bounds.height > self.minimumHeight) ? Palette.white : .clear
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let shouldShowImage = self.model?.shouldShowImage ?? false

    if shouldShowImage {
      let labelWidth = size.width - SuggestionsView.cellMessageInset - Self.labelIconMargin
      let titleSize = self.title.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
      let titleHeight = max(titleSize.height, 60)
      return CGSize(
        width: size.width,
        height: titleHeight + 2 * SuggestionsHeaderCell.topOffset
      )
    } else {
      let labelWidth = size.width - 2 * SuggestionsView.cellMessageInset
      let titleSize = self.title.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
      let subtitleSize = self.subtitle.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
      return CGSize(
        width: size.width,
        height: titleSize.height + subtitleSize.height + SuggestionsHeaderCell.totalVerticalOffset
      )
    }
  }
}

private extension SuggestionsHeaderCell {
  enum Style {
    static func background(_ view: UIView) {
      view.clipsToBounds = false
      // make sure shadow overlaps next cell
      view.layer.zPosition = 1000
    }

    static func container(_ view: UIView) {
      view.backgroundColor = Palette.purple
      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
      view.clipsToBounds = true
    }

    static func shadow(_ view: UIView, shadow: Shadow) {
      view.addShadow(shadow)
      view.clipsToBounds = false
    }

    static func gradient(_ view: GradientView, gradient: Gradient?) {
      guard let gradient = gradient else {
        return
      }
      view.gradient = gradient
    }

    static func title(_ label: UILabel, content: String) {
      let textStyle = TextStyles.h2.byAdding(
        .color(Palette.white),
        .alignment(.left)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }

    static func subtitle(_ label: UILabel, content: String) {
      let boldStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.white),
        .alignment(.left)
      )
      let textStyle = TextStyles.p.byAdding(
        .color(Palette.white),
        .alignment(.left),
        .xmlRules([.style("b", boldStyle)])
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }

    static func icon(_ view: UIImageView, image: UIImage?) {
      view.image = image
      view.contentMode = .scaleAspectFit
    }
  }
}

private extension CalendarDay {
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
  }()

  var dateString: String {
    return Self.dateFormatter.string(from: self.dateAtBeginningOfTheDay)
  }
}
