// TextFieldCode.swift
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

import Models
import Tempura
import UIKit

public struct TextFieldCodeVM: ViewModel {
    var codeType: String?
}

open class TextFieldCode: UIView, ModellableView {
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
    static let prefixCun: String = OTP.prefixCun
    var onFocus: Bool = false

    var didChangeTextValue: CustomInteraction<String>?

    public func setup() {
        addSubview(container)
        container.addSubview(textFieldIcon)
        container.addSubview(textfield)

        textfield.delegate = self
        textfield.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
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
    }

    public func update(oldModel _: TextFieldCodeVM?) {
        guard model != nil else {
            return
        }
        self.textfield.isEnabled = model?.codeType != nil
        Self.Style.shadow(container)
        Self.Style.textFieldIcon(textFieldIcon, onFocus: onFocus, isEnabled: self.textfield.isEnabled)
        Self.Style.textfield(textfield, isEnabled: self.textfield.isEnabled, codeType: model?.codeType)

        setNeedsLayout()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        container.pin
            .vertically()
            .horizontally(15)

        textFieldIcon.pin
            .size(24)
            .left(12)
            .vCenter()

        textfield.pin
            .after(of: textFieldIcon)
            .horizontally(36)
            .marginLeft(5)
            .vertically(5)
    }

    // Helpers

    @discardableResult override open func resignFirstResponder() -> Bool {
        return textfield.resignFirstResponder()
    }
}

// MARK: - Style

extension TextFieldCode {
    enum Style {
        static func container(_ view: UIView) {
            view.backgroundColor = Palette.white
            view.layer.cornerRadius = 15
        }

        static func shadow(_ view: UIView) {
            view.addShadow(.textfieldFocus)
        }

        static func textFieldIcon(_ view: UIImageView, onFocus: Bool, isEnabled: Bool) {
            view.image = Asset.Settings.UploadData.cun.image
            view.contentMode = .scaleAspectFit
            view.image = view.image?.withRenderingMode(.alwaysTemplate)
            if isEnabled {
                view.tintColor = onFocus ? Palette.primary : Palette.grayNormal
            }
            else {
                view.tintColor = Palette.grayExtraWhite
            }
        }

        static func textfield(_ textfield: UITextField, isEnabled: Bool, codeType: String?) {
            let textStyle = TextStyles.p.byAdding([
                .color(Palette.primary)
            ])
            let placeholderStyle = TextStyles.p.byAdding([
                .color(isEnabled ? Palette.grayNormal : Palette.grayExtraWhite),
                .font(UIFont.boldSystemFont(ofSize: 14.0))
            ])

            textfield.returnKeyType = .search
            textfield.tintColor = Palette.primary
            textfield.typingAttributes = textStyle.attributes
            textfield.defaultTextAttributes = textStyle.attributes
            
            let placeholder:NSAttributedString
            
            if let codeType = codeType {
                switch (codeType) {
                  case "NRFE":
                    placeholder = NSAttributedString(string: "Inserisci il codice NRFE")
                  case "CUN":
                    placeholder = NSAttributedString(string: "Inserisci il codice CUN")
                  case "NUCG":
                    placeholder = NSAttributedString(string: "Inserisci il codice NUCG")
                  case "OTP":
                    placeholder = NSAttributedString(string: "Inserisci il codice OTP")
                default:
                    placeholder = NSAttributedString(string: "Inserisci il codice")
                }
            }
            else{
                placeholder = NSAttributedString(string: "Inserisci il codice")
            }
            textfield.attributedPlaceholder = placeholder.styled(with: placeholderStyle)
        }
    }
}

// MARK: - Delegate

extension TextFieldCode: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        onFocus = true
        if textField.text?.isEmpty ?? true {
            textfield.text = Self.prefixCun
        }

        DispatchQueue.main.async {
            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        onFocus = false
        if textField.text == Self.prefixCun {
            textField.text = nil
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
            if let text:String = textfield.text {
                DispatchQueue.main.async {
                    self.textfield.text = text.uppercased()
                }
            }

    }

    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let protectedRange = NSRange(location: 0, length: 4)
        let intersection = NSIntersectionRange(protectedRange, range)
        if range.location < 4 || textField.text?.count ?? 0 > 13 {
            if string.isEmpty && range.location > 3{
                let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
                didChangeTextValue?(result.deletingPrefixCun(prefix: Self.prefixCun))
                return true
            }
            return false
        }

        if intersection.length > 0 {
            return false
        }
        if range.location == 13 {
            let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
            didChangeTextValue?(result.deletingPrefixCun(prefix: Self.prefixCun))
            return true
        }
        if range.location + range.length > 13 {
            return false
        }

        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        didChangeTextValue?(result.deletingPrefixCun(prefix: Self.prefixCun))

        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

//private extension String {
//    func deletingPrefixCun(prefix: String) -> String {
//        guard hasPrefix(prefix) else { return self }
//        return String(dropFirst(prefix.count))
//    }
//}
