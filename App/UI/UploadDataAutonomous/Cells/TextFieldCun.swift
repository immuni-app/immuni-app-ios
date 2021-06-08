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

import Models
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
    private let label = UILabel()
    private let container = UIView()
    private let textFieldIcon = UIImageView()
    private let textfield = UITextField()
    static let prefixCun: String = OTP.prefixCun
    var onFocus: Bool = false

    var didChangeSearchStatus: CustomInteraction<Bool>?
    var didChangeTextValue: CustomInteraction<String>?

    public func setup() {
        addSubview(container)
        addSubview(label)
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
        Self.Style.title(label)
    }

    public func update(oldModel _: TextFieldCunVM?) {
        guard model != nil else {
            return
        }
        Self.Style.shadow(container)
        Self.Style.textFieldIcon(textFieldIcon, onFocus: onFocus)

        setNeedsLayout()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        label.pin
            .horizontally(25)
            .sizeToFit(.width)
        
        container.pin
            .marginTop(30)
            .vertically()
            .horizontally(15)
            .below(of: label)

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

extension TextFieldCun {
    enum Style {
        static func title(_ label: UILabel) {
            let content = L10n.Settings.Setting.LoadDataAutonomous.Cun.label
            TempuraStyles.styleShrinkableLabel(
                label,
                content: content,
                style: TextStyles.pSemibold.byAdding(
                    .color(Palette.grayDark),
                    .alignment(.left)
                ),
                numberOfLines: 1
            )
        }
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
            let placeholder = NSAttributedString(string: L10n.Settings.Setting.LoadDataAutonomous.Cun.placeholder)
            textfield.attributedPlaceholder = placeholder.styled(with: placeholderStyle)
        }
    }
}

// MARK: - Delegate

extension TextFieldCun: UITextFieldDelegate {
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

extension String {
    func deletingPrefixCun(prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }
}
