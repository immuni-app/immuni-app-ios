// TextFieldCun.swift
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

public struct TextFieldCunVM: ViewModel {}

open class TextFieldCun: UIView, ModellableView {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        style()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        style()
    }

    private let container = UIView()
    private let textFieldIcon = UIImageView()
    private let textfield = UITextField()

    var didChangeSearchStatus: CustomInteraction<Bool>?
    var didChangeTextValue: CustomInteraction<String>?

    public func setup() {
        addSubview(container)
        container.addSubview(textFieldIcon)
        container.addSubview(textfield)

        textfield.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapContainer))
        container.addGestureRecognizer(tapGesture)
    }

    @objc private func didTapContainer() {
        if textfield.isFirstResponder {
            textfield.resignFirstResponder()
        } else {
            textfield.becomeFirstResponder()
        }
    }

    public func style() {
        Self.Style.container(container)
        Self.Style.textfield(textfield)
    }

    public func update(oldModel _: TextFieldCunVM?) {
        guard let model = self.model else {
            return
        }

        Self.Style.shadow(container)
        Self.Style.textFieldIcon(textFieldIcon)

        setNeedsLayout()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        container.pin
            .vertically()
            .horizontally(25)

        textFieldIcon.pin
            .size(24)
            .left(12)
            .vCenter()

        textfield.pin
            .after(of: textFieldIcon)
            .horizontally(36)
            .marginHorizontal(10)
            .vertically(5)
    }

    // Helpers

    @discardableResult override open func resignFirstResponder() -> Bool {
        return textfield.resignFirstResponder()
    }
}

// MARK: - Style

extension TextFieldCun {
    enum Style {
        static func container(_ view: UIView) {
            view.backgroundColor = Palette.white
            view.layer.cornerRadius = 15
        }

        static func shadow(_ view: UIView) {
            view.addShadow(.textfieldFocus)
        }

        static func textFieldIcon(_ view: UIImageView) {
            view.image = Asset.Privacy.ministry.image
            view.contentMode = .scaleAspectFit
            view.tintColor = Palette.grayNormal
        }

        static func textfield(_ textfield: UITextField) {
            let textStyle = TextStyles.p.byAdding([
                .color(Palette.grayNormal)
            ])
            let placeholderStyle = TextStyles.p.byAdding([
                .color(Palette.grayNormal)
            ])

            textfield.returnKeyType = .search
            textfield.tintColor = Palette.primary
            textfield.typingAttributes = textStyle.attributes
            textfield.defaultTextAttributes = textStyle.attributes
            let placeholder: NSAttributedString = NSAttributedString(string: L10n.Settings.Setting.LoadDataAutonomous.Cun.placeholder)
            textfield.attributedPlaceholder =  placeholder.styled(with: placeholderStyle)
        }
    }
}

// MARK: - Delegate

extension TextFieldCun: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_: UITextField) {
//    self.didChangeSearchStatus?(self.isSearching)
    }

    public func textFieldDidEndEditing(_: UITextField) {
//    self.didChangeSearchStatus?(self.isSearching)
    }

    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        didChangeTextValue?(result)

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

//
// public struct TextFieldVM: ViewModel {
//  let isSearching: Bool
// }
//
// open class TextField: UIView, ModellableView {
//  override public init(frame: CGRect) {
//    super.init(frame: frame)
//    self.setup()
//    self.style()
//  }
//
//  public required init?(coder aDecoder: NSCoder) {
//    super.init(coder: aDecoder)
//    self.setup()
//    self.style()
//  }
//
//  private let container = UIView()
//  private let searchIcon = UIImageView()
//  private let textfield = UITextField()
//
//  var isSearching: Bool {
//    self.textfield.isFirstResponder
//  }
//
//  var didChangeSearchStatus: CustomInteraction<Bool>?
//  var didChangeSearchedValue: CustomInteraction<String>?
//
//  public func setup() {
//
//    self.addSubview(self.container)
//    self.container.addSubview(self.searchIcon)
//    self.container.addSubview(self.textfield)
//
//    self.textfield.delegate = self
//
//    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapContainer))
//    self.container.addGestureRecognizer(tapGesture)
//  }
//
//  @objc private func didTapContainer() {
//    if self.textfield.isFirstResponder {
//      self.textfield.resignFirstResponder()
//    } else {
//      self.textfield.becomeFirstResponder()
//    }
//  }
//
//  public func style() {
//    Self.Style.container(self.container)
//    Self.Style.textfield(self.textfield)
//  }
//
//  public func update(oldModel: TextFieldVM?) {
//    guard let model = self.model else {
//      return
//    }
//
//    Self.Style.shadow(self.container, isSearching: model.isSearching)
//    Self.Style.searchIcon(self.searchIcon, isSearching: model.isSearching)
//
//    self.setNeedsLayout()
//  }
//
//  override open func layoutSubviews() {
//    super.layoutSubviews()
//
//    let isSearching = self.model?.isSearching ?? false
//
//    if isSearching {
//      self.container.pin
//        .vertically()
//        .horizontally(25)
//        .marginRight(20)
//    } else {
//      self.container.pin
//        .vertically()
//        .horizontally(25)
//    }
//
//    self.searchIcon.pin
//      .size(24)
//      .left(12)
//      .vCenter()
//
//    self.textfield.pin
//
//      .after(of: self.searchIcon)
//      .horizontally()
//      .marginHorizontal(10)
//      .vertically(5)
//  }
//
//  // Helpers
//
//  @discardableResult override open func resignFirstResponder() -> Bool {
//    return self.textfield.resignFirstResponder()
//  }
//
//  private func clearTextfield() {
//    self.textfield.text = ""
//    self.didChangeSearchedValue?("")
//    self.update(oldModel: self.model)
//  }
//
//  private func cancelSearch() {
//    self.clearTextfield()
//    self.textfield.resignFirstResponder()
//    self.didChangeSearchStatus?(self.isSearching)
//  }
// }
//
// MARK: - Style
//
// extension TextField {
//  enum Style {
//    static func container(_ view: UIView) {
//      view.backgroundColor = Palette.white
//      view.layer.cornerRadius = 25
//    }
//
//    static func shadow(_ view: UIView, isSearching: Bool) {
////      view.addShadow(isSearching ? .textfieldFocus : .cardLightBlue)
//    }
//
//    static func searchIcon(_ view: UIImageView, isSearching: Bool) {
//      view.image = Asset.Settings.Faq.search.image
//      view.tintColor = isSearching ? Palette.primary : Palette.grayNormal
//    }
//
//    static func textfield(_ textfield: UITextField) {
//      let textStyle = TextStyles.p.byAdding([
//        .color(Palette.primary)
//      ])
//      let placeholderStyle = TextStyles.p.byAdding([
//        .color(Palette.grayNormal)
//      ])
//
//      textfield.returnKeyType = .search
//      textfield.tintColor = Palette.primary
//      textfield.typingAttributes = textStyle.attributes
//      textfield.defaultTextAttributes = textStyle.attributes
//      textfield.attributedPlaceholder = L10n.Faq.SearchBar.placeholder.styled(with: placeholderStyle)
//    }
//  }
// }
//
// MARK: - Delegate
//
// extension TextField: UITextFieldDelegate {
//  public func textFieldDidBeginEditing(_ textField: UITextField) {
//    self.didChangeSearchStatus?(self.isSearching)
//  }
//
//  public func textFieldDidEndEditing(_ textField: UITextField) {
//    self.didChangeSearchStatus?(self.isSearching)
//  }
//
//  public func textField(
//    _ textField: UITextField,
//    shouldChangeCharactersIn range: NSRange,
//    replacementString string: String
//  ) -> Bool {
//    let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
//    self.didChangeSearchedValue?(result)
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//      // don't do it sync as the textfield is not immediately updated
//      self.update(oldModel: self.model)
//    }
//
//    return true
//  }
//
//  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//    textField.resignFirstResponder()
//    return false
//  }
// }
