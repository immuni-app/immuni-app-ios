// PickerSymptomsDate.swift
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

public struct PickerSymptomsDateVM: ViewModel {}

open class PickerSymptomsDate: UIView, ModellableView {
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
    private let pickerIcon = UIImageView()
    private let textfield = UITextField()

    var didChangePickerValue: CustomInteraction<String>?

    @objc func tapDone() {
        if let datePicker = textfield.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .medium
            textfield.text = dateformatter.string(from: datePicker.date)
            didChangePickerValue?(dateformatter.string(from: datePicker.date))
        }
        textfield.resignFirstResponder()
    }

    public func setup() {
        
        textfield.setInputViewDatePicker(target: self, selector: #selector(tapDone))

        addSubview(container)
        container.addSubview(pickerIcon)
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

    public func update(oldModel _: PickerSymptomsDateVM?) {
        guard let _ = model else {
            return
        }

        Self.Style.shadow(container)
        Self.Style.pickerIcon(pickerIcon)

        setNeedsLayout()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        container.pin
            .vertically()
            .horizontally(25)

        pickerIcon.pin
            .size(24)
            .left(12)
            .vCenter()

        textfield.pin
            .after(of: pickerIcon)
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

extension PickerSymptomsDate {
    enum Style {
        static func container(_ view: UIView) {
            view.backgroundColor = Palette.white
            view.layer.cornerRadius = 15
        }

        static func shadow(_ view: UIView) {
            view.addShadow(.textfieldFocus)
        }

        static func pickerIcon(_ view: UIImageView) {
            view.image = Asset.Settings.UploadData.calendar.image
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
            
            let placeholder: NSAttributedString = NSAttributedString(string: L10n.Settings.Setting.LoadDataAutonomous.SymptomsDate.placeholder)
            textfield.attributedPlaceholder =  placeholder.styled(with: placeholderStyle)
        }
    }
}

// MARK: - Delegate

extension PickerSymptomsDate: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_: UITextField) {
    }

    public func textFieldDidEndEditing(_: UITextField) {
    }

    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        didChangePickerValue?(result)

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

extension UITextField {
    func setInputViewDatePicker(target: Any, selector: Selector) {
        // Create a UIDatePicker object and assign to inputView
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))

        datePicker.datePickerMode = .date 
        // iOS 14 and above
        if #available(iOS 14, *) { // Added condition for iOS 14
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        datePicker.backgroundColor = .white

        inputView = datePicker
        // Create a toolbar and assign it to inputAccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: L10n.cancel, style: .plain, target: nil, action: #selector(tapCancel))
       
        let barButton = UIBarButtonItem(title: L10n.confirm, style: .plain, target: target, action: selector)
        cancel.tintColor = Palette.purple
        barButton.tintColor = Palette.purple
        toolBar.setItems([cancel, flexible, barButton], animated: true)
        inputAccessoryView = toolBar
    }

    @objc func tapCancel() {
        resignFirstResponder()
    }
}
