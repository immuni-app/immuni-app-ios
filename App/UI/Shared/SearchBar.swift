// SearchBar.swift
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
import UIKit

public struct SearchBarVM: ViewModel {
  let isSearching: Bool
}

open class SearchBar: UIView, ModellableView {
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

  private let container = UIView()
  private let searchIcon = UIImageView()
  private let textfield = UITextField()
  private var cancelButton = TextButton()
  private var clearButton = ImageButton()

  var isSearching: Bool {
    self.textfield.isFirstResponder
  }

  var shouldShowClearButton: Bool {
    // swiftlint:disable:next empty_string
    self.isSearching && self.textfield.text != ""
  }

  var didChangeSearchStatus: CustomInteraction<Bool>?
  var didChangeSearchedValue: CustomInteraction<String>?

  public func setup() {
    self.addSubview(self.cancelButton)
    self.addSubview(self.container)
    self.container.addSubview(self.searchIcon)
    self.container.addSubview(self.textfield)
    self.container.addSubview(self.clearButton)

    self.textfield.delegate = self

    self.cancelButton.on(.touchUpInside) { [weak self] _ in
      self?.cancelSearch()
    }

    self.clearButton.on(.touchUpInside) { [weak self] _ in
      self?.clearTextfield()
    }

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapContainer))
    self.container.addGestureRecognizer(tapGesture)
  }

  @objc private func didTapContainer() {
    if self.textfield.isFirstResponder {
      self.textfield.resignFirstResponder()
    } else {
      self.textfield.becomeFirstResponder()
    }
  }

  public func style() {
    Self.Style.container(self.container)
    Self.Style.textfield(self.textfield)
    Self.Style.clearButton(self.clearButton)
    Self.Style.cancelButton(self.cancelButton)
  }

  public func update(oldModel: SearchBarVM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.shadow(self.container, isSearching: model.isSearching)
    Self.Style.searchIcon(self.searchIcon, isSearching: model.isSearching)
    self.clearButton.isAccessibilityElement = false

    self.setNeedsLayout()

    UIView.animate(withDuration: 0.2) {
      self.cancelButton.alpha = model.isSearching.cgFloat
      self.clearButton.alpha = self.shouldShowClearButton.cgFloat
      self.layoutIfNeeded()
    }
  }

  override open func layoutSubviews() {
    super.layoutSubviews()

    let isSearching = self.model?.isSearching ?? false

    self.cancelButton.pin
      .vertically()
      .right(25)
      .sizeToFit(.height)

    if isSearching {
      self.container.pin
        .vertically()
        .left(25)
        .before(of: self.cancelButton)
        .marginRight(20)
    } else {
      self.container.pin
        .vertically()
        .horizontally(25)
    }

    self.searchIcon.pin
      .size(24)
      .left(12)
      .vCenter()

    self.clearButton.pin
      .size(24)
      .right(15)
      .vCenter()

    self.textfield.pin
      .before(of: self.clearButton)
      .after(of: self.searchIcon)
      .marginHorizontal(10)
      .vertically(5)
  }

  // Helpers

  @discardableResult override open func resignFirstResponder() -> Bool {
    return self.textfield.resignFirstResponder()
  }

  private func clearTextfield() {
    self.textfield.text = ""
    self.didChangeSearchedValue?("")
    self.update(oldModel: self.model)
  }

  private func cancelSearch() {
    self.clearTextfield()
    self.textfield.resignFirstResponder()
    self.didChangeSearchStatus?(self.isSearching)
  }
}

// MARK: - Style

extension SearchBar {
  enum Style {
    static func container(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.cornerRadius = 25
    }

    static func shadow(_ view: UIView, isSearching: Bool) {
      view.addShadow(isSearching ? .textfieldFocus : .cardLightBlue)
    }

    static func searchIcon(_ view: UIImageView, isSearching: Bool) {
      view.image = Asset.Settings.Faq.search.image
      view.tintColor = isSearching ? Palette.primary : Palette.grayNormal
    }

    static func clearButton(_ button: ImageButton) {
      button.image = Asset.Settings.Faq.clear.image
    }

    static func cancelButton(_ button: TextButton) {
      let textStyle = TextStyles.p.byAdding([
        .color(Palette.grayNormal)
      ])

      button.attributedTitle = L10n.cancel.styled(with: textStyle)
    }

    static func textfield(_ textfield: UITextField) {
      let textStyle = TextStyles.p.byAdding([
        .color(Palette.primary)
      ])
      let placeholderStyle = TextStyles.p.byAdding([
        .color(Palette.grayNormal)
      ])

      textfield.returnKeyType = .search
      textfield.tintColor = Palette.primary
      textfield.typingAttributes = textStyle.attributes
      textfield.defaultTextAttributes = textStyle.attributes
      textfield.attributedPlaceholder = L10n.Faq.SearchBar.placeholder.styled(with: placeholderStyle)
    }
  }
}

// MARK: - Delegate

extension SearchBar: UITextFieldDelegate {
  public func textFieldDidBeginEditing(_ textField: UITextField) {
    self.didChangeSearchStatus?(self.isSearching)
  }

  public func textFieldDidEndEditing(_ textField: UITextField) {
    self.didChangeSearchStatus?(self.isSearching)
  }

  public func textField(
    _ textField: UITextField,
    shouldChangeCharactersIn range: NSRange,
    replacementString string: String
  ) -> Bool {
    let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
    self.didChangeSearchedValue?(result)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      // don't do it sync as the textfield is not immediately updated
      self.update(oldModel: self.model)
    }

    return true
  }

  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}
