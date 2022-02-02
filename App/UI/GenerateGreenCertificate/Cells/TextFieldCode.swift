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
    var codeType: CodeType?
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
    
    private let label = UILabel()
    private let container = UIView()
    private let textFieldIcon = UIImageView()
    private let textfield = UITextField()
    private var prefixCode: String?
    var onFocus: Bool = false

    var didChangeTextValue: CustomInteraction<String>?

    public func setup() {
        
        addSubview(label)
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

    public func update(oldModel: TextFieldCodeVM?) {
        guard model != nil else {
            return
        }

        if oldModel?.codeType != nil, oldModel?.codeType != model?.codeType {
          self.textfield.text = ""
          self.textfield.isEnabled = false
          self.textfield.isEnabled = true
        }
        self.prefixCode = self.getPrefix(codeType: model?.codeType)
        self.textfield.isEnabled = model?.codeType != nil
        Self.Style.shadow(container)
        Self.Style.textFieldIcon(textFieldIcon, onFocus: onFocus, isEnabled: self.textfield.isEnabled)
        Self.Style.textfield(textfield, isEnabled: self.textfield.isEnabled, codeType: model?.codeType)
        Self.Style.title(label, codeType: model?.codeType)

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

extension TextFieldCode {
    enum Style {
        static func title(_ label: UILabel, codeType: CodeType?) {
            var content: String
            switch (codeType) {
              case .nrfe:
                content = L10n.HomeView.GenerateGreenCertificate.inputCodeNrfeLabel
              case .cun:
                content = L10n.HomeView.GenerateGreenCertificate.inputCodeCunLabel
              case .nucg:
                content = L10n.HomeView.GenerateGreenCertificate.inputCodeNucgLabel
              case .cuev:
                content = L10n.HomeView.GenerateGreenCertificate.inputCodeCuevLabel
              case .authcode:
                content = L10n.HomeView.GenerateGreenCertificate.inputCodeAuthcodeLabel
              case .none:
                content = L10n.HomeView.GenerateGreenCertificate.inputCodeLabel
            }
            
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

        static func textfield(_ textfield: UITextField, isEnabled: Bool, codeType: CodeType?) {
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
            
            let placeholder: NSAttributedString
            
            switch (codeType) {
              case .nrfe:
                placeholder = NSAttributedString(string: L10n.HomeView.GenerateGreenCertificate.inputCodeNrfePlaceholder)
              case .cun:
                placeholder = NSAttributedString(string: L10n.HomeView.GenerateGreenCertificate.inputCodeCunPlaceholder)
              case .nucg:
                placeholder = NSAttributedString(string: L10n.HomeView.GenerateGreenCertificate.inputCodeNucgPlaceholder)
              case .cuev:
               placeholder = NSAttributedString(string: L10n.HomeView.GenerateGreenCertificate.inputCodeCuevPlaceholder)
              case .authcode:
                placeholder = NSAttributedString(string: L10n.HomeView.GenerateGreenCertificate.inputCodeAuthcodePlaceholder)
              case .none:
                placeholder = NSAttributedString(string: L10n.HomeView.GenerateGreenCertificate.inputCodePlaceholder)
                }
            
            textfield.attributedPlaceholder = placeholder.styled(with: placeholderStyle)
        }
    
    }
    func getPrefix(codeType: CodeType?) -> String {
        switch codeType {
          case .nrfe:
            return CodeType.prefixNrfe
          case .cun:
            return CodeType.prefixCun
          case .nucg:
            return CodeType.prefixNucg
          case .cuev:
            return CodeType.prefixCuev
          case .authcode:
            return CodeType.prefixAuthcode
        case .none:
            return ""
        }
    }
}

// MARK: - Delegate

extension TextFieldCode: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        onFocus = true
        if textField.text?.isEmpty ?? true {
            textfield.text = self.prefixCode
        }

        DispatchQueue.main.async {
            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        onFocus = false
        if textField.text == self.prefixCode {
            textField.text = nil
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
            if let text:String = textfield.text {
                DispatchQueue.main.async {
                    self.textfield.text = self.model?.codeType == .nrfe ? text : text.uppercased()
                }
            }

    }

    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        var lengthCode:Int
        switch model?.codeType {
          case .nrfe:
            lengthCode = CodeType.lengthNrfe
          case .cun:
            lengthCode = CodeType.lengthCun
          case .nucg:
            lengthCode = CodeType.lengthNucg
          case .cuev:
            lengthCode = CodeType.lengthCuev
          case .authcode:
            lengthCode = CodeType.lengthAuthcode
          default:
            return false
        }
        guard let prefixCode = prefixCode else { return false }
        let limitCode = prefixCode.count + lengthCode - 1
        let prefixLength = prefixCode.count
        let protectedRange = NSRange(location: 0, length: prefixLength)
        let intersection = NSIntersectionRange(protectedRange, range)
        if range.location < prefixCode.count || textField.text?.count ?? 0 > limitCode {
            if string.isEmpty && range.location > prefixLength-1{
                let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
                didChangeTextValue?(result.deletingPrefix(prefix: self.prefixCode))
                return true
            }
            return false
        }

        if intersection.length > 0 {
            return false
        }
        if range.location == limitCode {
            let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
            didChangeTextValue?(result.deletingPrefix(prefix: self.prefixCode))
            return true
        }
        if range.location + range.length > limitCode {
            return false
        }

        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        didChangeTextValue?(result.deletingPrefix(prefix: self.prefixCode))

        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

private extension String {
    func deletingPrefix(prefix: String?) -> String {
        guard let prefix = prefix, hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }
}
