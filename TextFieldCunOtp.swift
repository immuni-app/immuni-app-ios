// TextFieldCunOtp.swift
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

public struct TextFieldCunOtpVM: ViewModel {}

open class TextFieldCunOtp: UIView, ModellableView {
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

    var didChangeSearchStatus: CustomInteraction<Bool>?
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
        Self.Style.textfield(textfield)
    }

    public func update(oldModel _: TextFieldCunOtpVM?) {
        guard model != nil else {
            return
        }
        Self.Style.shadow(container)
        Self.Style.textFieldIcon(textFieldIcon, onFocus: onFocus)

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

extension TextFieldCunOtp {
    enum Style {
        static func container(_ view: UIView) {
            view.backgroundColor = Palette.white
            view.layer.cornerRadius = 15
        }

        static func shadow(_ view: UIView) {
            view.addShadow(.textfieldFocus)
        }

        static func textFieldIcon(_ view: UIImageView, onFocus: Bool) {
            view.image = Asset.Settings.UploadData.cun.image
            view.contentMode = .scaleAspectFit
            view.image = view.image?.withRenderingMode(.alwaysTemplate)
            view.tintColor = onFocus ? Palette.primary : Palette.grayNormal
        }

        static func textfield(_ textfield: UITextField) {
            let textStyle = TextStyles.p.byAdding([
                .color(Palette.primary)
            ])
            let placeholderStyle = TextStyles.p.byAdding([
                .color(Palette.grayNormal),
                .font(UIFont.boldSystemFont(ofSize: 14.0))
            ])

            textfield.returnKeyType = .search
            textfield.tintColor = Palette.primary
            textfield.typingAttributes = textStyle.attributes
            textfield.defaultTextAttributes = textStyle.attributes
            let placeholder = NSAttributedString(string: "NRFE/CUN/NUCG/OTP")
            textfield.attributedPlaceholder = placeholder.styled(with: placeholderStyle)
        }
    }
}

// MARK: - Delegate

extension TextFieldCunOtp: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        onFocus = true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        onFocus = false
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
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText)
        else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        if count <= 20 {
            let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
            didChangeTextValue?(result)
        }
        return count <= 20
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

