// AsymptomaticCheckBox.swift
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

import BonMot
import Extensions
import Foundation
import Katana
import PinLayout
import Tempura

// MARK: - Model

struct AsymptomaticCheckBoxVM: ViewModel, Hashable {
    var isSelected: Bool
    var isEnabled: Bool

    var accessibilityTraits: UIAccessibilityTraits {
        if isSelected {
            return [.button, .selected]
        } else {
            return .button
        }
    }
}

// MARK: - View

class AsymptomaticCheckBox: UICollectionViewCell, ModellableView, ReusableView {
    private static let titleToCheckmarkMargin: CGFloat = 20

    // we cannot rely on the proper asset size, as the checked one
    // is bigger because of the shadow. The keep it visually consistent, we need
    // to use a fixed size
    private static let checkmarkSize: CGFloat = 25.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        style()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        style()
    }

    var checkmark = UIButton()
    let title = UILabel()
    var didTapCheckBox: CustomInteraction<Bool?>?

    // MARK: Setup

    func setup() {
        contentView.addSubview(checkmark)
        contentView.addSubview(title)

        checkmark.on(.touchUpInside) { [weak self] _ in
            self?.didTapCheckBox?(self?.model?.isSelected)
        }

        isAccessibilityElement = true
    }

    // MARK: Style

    func style() {}

    // MARK: Update

    func update(oldModel: AsymptomaticCheckBoxVM?) {
        guard let model = self.model else {
            title.attributedText = nil
            return
        }

        accessibilityTraits = model.accessibilityTraits

        Self.Style.checkmark(checkmark, isSelected: model.isSelected, isEnabled: model.isEnabled)
        Self.Style.title(title, content: L10n.Settings.Setting.LoadDataAutonomous.Asymptomatic.message)
        setNeedsLayout()
    }

    // MARK: Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        title.pin
            .after(of: checkmark)
            .horizontally(25)
            .vertically()

        checkmark.pin
            .size(50)
            .vCenter()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let availableWidth = size.width - 2 * OnboardingContainerAccessoryView.horizontalSpacing - Self
            .titleToCheckmarkMargin - Self.checkmarkSize

        let titleSize = title.sizeThatFits(CGSize(width: availableWidth, height: CGFloat.infinity))

        return CGSize(
            width: size.width,
            height: titleSize.height
        )
    }
}

// MARK: - Style

private extension AsymptomaticCheckBox {
    enum Style {
        static func checkmark(_ view: UIButton, isSelected: Bool, isEnabled: Bool) {
            if isSelected, isEnabled {
                view.setImage(Asset.Privacy.checkboxSelected.image, for: .normal)
            } else if isSelected, !isEnabled {
                view.setImage(Asset.Privacy.checkboxSelectedDisable.image, for: .normal)
            } else {
                view.setImage(Asset.Privacy.checkbox.image, for: .normal)
            }
            view.imageView?.contentMode = .scaleAspectFit
            view.imageEdgeInsets = UIEdgeInsets(top: 5.0, left: 0.0, bottom: 5.0, right: 0.0)
        }

        static func title(_ label: UILabel, content: String) {

            let textStyle = TextStyles.p.byAdding(
                .color(Palette.grayNormal),
                .alignment(.left),
                .font(UIFont.boldSystemFont(ofSize: 12.0))

            )

            TempuraStyles.styleStandardLabel(
                label,
                content: content,
                style: textStyle
            )
        }
    }
}
