// ForceUpdateView.swift
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

import Tempura

// MARK: - View Model

struct ForceUpdateVM: Equatable {
  enum UpdateType {
    case app
    case operatingSystem
  }

  /// The type of update to force.
  let type: ForceUpdateVM.UpdateType

  var title: String {
    switch self.type {
    case .app:
      return L10n.ForceUpdateView.App.title

    case .operatingSystem:
      return L10n.ForceUpdateView.Os.title
    }
  }

  var subtitle: String {
    switch self.type {
    case .app:
      return L10n.ForceUpdateView.App.details

    case .operatingSystem:
      return L10n.ForceUpdateView.Os.details
    }
  }

  var shouldShowSecondaryButton: Bool {
    switch self.type {
    case .app:
      return false

    case .operatingSystem:
      return true
    }
  }

  var secondaryButtonTitle: String {
    switch self.type {
    case .app:
      return ""

    case .operatingSystem:
      return L10n.ForceUpdateView.Os.secondayButton
    }
  }
}

extension ForceUpdateVM: ViewModelWithLocalState {
  init?(state: AppState?, localState: ForceUpdateLS) {
    self.type = localState.type
  }
}

// MARK: - View

class ForceUpdateView: UIView, ViewControllerModellableView {
  let downloadImageView = UIImageView()
  let contentContainerView = UIView()
  let titleLabel = UILabel()
  let detailsLabel = UILabel()
  let updateButton = ButtonWithInsets()
  var secondaryButton = TextButton()

  var didTapUpdate: Interaction?
  var didTapSecondaryButton: Interaction?

  // MARK: - Setup

  func setup() {
    self.addSubview(self.contentContainerView)
    self.addSubview(self.updateButton)
    self.addSubview(self.secondaryButton)

    self.contentContainerView.addSubview(self.downloadImageView)
    self.contentContainerView.addSubview(self.titleLabel)
    self.contentContainerView.addSubview(self.detailsLabel)

    self.updateButton.on(.touchUpInside) { [unowned self] _ in
      self.didTapUpdate?()
    }

    self.secondaryButton.on(.touchUpInside) { [unowned self] _ in
      self.didTapSecondaryButton?()
    }
  }

  // MARK: - Style

  func style() {
    Self.Style.root(self)
    Self.Style.image(self.downloadImageView, image: Asset.ForceUpdate.download.image)
    Self.Style.updateButton(self.updateButton, title: L10n.ForceUpdateView.update)
  }

  // MARK: - Update

  func update(oldModel: ForceUpdateVM?) {
    guard let model = self.model, model != oldModel else { return }

    Self.Style.title(self.titleLabel, title: model.title)
    Self.Style.details(self.detailsLabel, details: model.subtitle)

    self.secondaryButton.isHidden = !model.shouldShowSecondaryButton
    Self.Style.secondaryButton(self.secondaryButton, content: model.secondaryButtonTitle)

    self.setNeedsLayout()
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    let shouldShowSecondaryButton = self.model?.shouldShowSecondaryButton ?? false

    self.contentContainerView.pin.all(self.safeAreaInsets)

    self.titleLabel.pin
      .horizontally(30)
      .sizeToFit(.width)
      .vCenter()

    self.downloadImageView.pin
      .sizeToFit()
      .above(of: self.titleLabel, aligned: .center)
      .marginBottom(30)

    self.detailsLabel.pin
      .horizontally(30)
      .sizeToFit(.width)
      .below(of: self.titleLabel)
      .marginTop(20)

    if shouldShowSecondaryButton {
      self.secondaryButton.pin
        .horizontally(30)
        .height(44)
        .bottom(self.safeAreaInsets.bottom + 15)

      self.updateButton.pin
        .horizontally(30)
        .height(55)
        .above(of: self.secondaryButton)
        .marginBottom(30)
    } else {
      self.updateButton.pin
        .horizontally(30)
        .height(55)
        .bottom(self.safeAreaInsets.bottom + 25)
    }

    self.contentContainerView.pin
      .wrapContent()
      .top(self.safeAreaInsets.top)
      .bottom(to: self.updateButton.edge.top)
      .hCenter()
      .align(.center)
  }
}

// MARK: - Style

extension ForceUpdateView {
  enum Style {
    static func root(_ view: UIView) {
      view.backgroundColor = Palette.primary
    }

    static func image(_ imageView: UIImageView, image: UIImage) {
      imageView.image = image
    }

    static func title(_ label: UILabel, title: String) {
      let style = TextStyles.h1.byAdding(
        .color(Palette.white),
        .alignment(.center)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: title,
        style: style
      )
    }

    static func details(_ label: UILabel, details: String?) {
      let style = TextStyles.p.byAdding(
        .color(Palette.white),
        .alignment(.center)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: details,
        style: style
      )
    }

    static func updateButton(
      _ button: ButtonWithInsets,
      title: String,
      insets: UIEdgeInsets = .primaryButtonInsets,
      cornerRadius: CGFloat = 28
    ) {
      let textStyle = TextStyles.h4Bold.byAdding(
        .color(Palette.primary),
        .alignment(.center)
      )

      button.insets = insets
      button.setBackgroundColor(Palette.white, for: .normal)
      button.layer.cornerRadius = cornerRadius
      button.layer.masksToBounds = true
      button.setAttributedTitle(title.styled(with: textStyle), for: .normal)
    }

    static func secondaryButton(_ button: TextButton, content: String) {
      let style = TextStyles.pLink.byAdding(
        .color(Palette.white),
        .alignment(.center)
      )

      button.titleLabel?.numberOfLines = 0
      button.attributedTitle = content.styled(with: style)
    }
  }
}
