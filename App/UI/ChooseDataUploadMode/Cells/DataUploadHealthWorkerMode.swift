// DataUploadHealthWorkerMode.swift
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

import Foundation
import Tempura

import Extensions

struct DataUploadHealthWorkerModeVM: ViewModel {}

// MARK: - View

class DataUploadHealthWorkerModeView: UIView, ModellableView, ReusableView {
    typealias VM = DataUploadHealthWorkerModeVM
    
    static let containerInset: CGFloat = 25
    static let labelLeftMargin: CGFloat = 25
    static let labelBottomMargin: CGFloat = 10
    static let imageRightMargin: CGFloat = 10
    static let labelTopMargin: CGFloat = 10
    static let buttonTopMargin: CGFloat = 20
    static let buttonMinHeight: CGFloat = 55
    static let containerMinHeight: CGFloat = 245
    static let orderRightMargin: CGFloat = UIDevice.getByScreen(normal: 70, narrow: 50)

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

    private let container = UIView()
    private let title = UILabel()
    private let message = UILabel()
    private var actionButton = ButtonWithInsets()
    private var imageContent = UIImageView()

    var didTapAction: Interaction?

    // MARK: - Setup

    func setup() {
        addSubview(container)
        container.addSubview(title)
        container.addSubview(message)
        container.addSubview(actionButton)
        container.addSubview(imageContent)

        container.accessibilityElements = [title, message, actionButton, imageContent]

        actionButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapAction?()
        }
    }

    // MARK: - Style

    func style() {
        Self.Style.container(container)
        Self.Style.title(title)
        Self.Style.message(message)

        SharedStyle.primaryButton(actionButton, title: L10n.UploadData.Verify.button)
        Self.Style.imageContent(imageContent, image: Asset.Settings.UploadData.stethoscope.image)
        
    }

    // MARK: - Update

    func update(oldModel _: VM?) {
        guard let _ = model else {
            return
        }
        setNeedsLayout()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        container.pin
            .vertically()
            .horizontally(25)
            .marginTop(Self.labelTopMargin)

        title.pin
            .left(Self.labelLeftMargin)
            .right(Self.orderRightMargin)
            .top(Self.containerInset)
            .sizeToFit(.width)

        message.pin
            .left(Self.labelLeftMargin)
            .right(Self.orderRightMargin)
            .sizeToFit(.width)
            .below(of: title)
            .marginTop(Self.labelTopMargin)

        actionButton.pin
            .left(Self.labelLeftMargin)
            .right(Self.orderRightMargin)
            
            .size(buttonSize(for: bounds.width))
            .minHeight(Self.buttonMinHeight)
            .below(of: message)
            .marginTop(Self.buttonTopMargin)

        imageContent.pin
            .after(of: title, aligned: .center)
            .sizeToFit()
    }

    func buttonSize(for width: CGFloat) -> CGSize {
        let labelWidth = width - DataUploadHealthWorkerModeView.orderRightMargin - DataUploadHealthWorkerModeView.labelLeftMargin

        var buttonSize = actionButton.titleLabel?.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity)) ?? .zero

        buttonSize.width = width - DataUploadHealthWorkerModeView.orderRightMargin - DataUploadHealthWorkerModeView.labelLeftMargin-20
        buttonSize.height = DataUploadAutonomousModeView.buttonMinHeight

        return buttonSize
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let imageSize = imageContent.intrinsicContentSize
        let labelWidth = size.width - DataUploadHealthWorkerModeView.orderRightMargin - DataUploadHealthWorkerModeView.labelLeftMargin
            - 2 * DataUploadHealthWorkerModeView.containerInset - imageSize.width
        let titleSize = self.title.sizeThatFits(CGSize(width: labelWidth, height: .infinity))
        let messageSize = self.message.sizeThatFits(CGSize(width: labelWidth, height: .infinity))
        let buttonSize = self.actionButton.sizeThatFits(CGSize(width: labelWidth, height: .infinity))

        return CGSize(
            width: size.width,
            height: max(titleSize.height + messageSize.height + buttonSize.height + 2 * Self.containerInset
                            + Self.labelBottomMargin + Self.buttonTopMargin, Self.containerMinHeight)
        )
    }
}

// MARK: - Style

private extension DataUploadHealthWorkerModeView {
    enum Style {
        static func container(_ view: UIView) {
            view.backgroundColor = Palette.white
            view.layer.cornerRadius = SharedStyle.cardCornerRadius
            view.addShadow(.cardLightBlue)
        }

        static func title(_ label: UILabel) {
            let content = L10n.Settings.Setting.ChooseDataUpload.HealthWorkerMode.title
            let textStyle = TextStyles.h4.byAdding(
                .color(Palette.purple),
                .alignment(.left)
            )

            TempuraStyles.styleStandardLabel(
                label,
                content: content,
                style: textStyle
            )
        }

        static func message(_ label: UILabel) {
            let content = L10n.Settings.Setting.ChooseDataUpload.HealthWorkerMode.message
            let textStyle = TextStyles.p.byAdding(
                .color(Palette.grayNormal),
                .alignment(.left)
            )

            TempuraStyles.styleStandardLabel(
                label,
                content: content,
                style: textStyle
            )
        }

        static func imageContent(_ imageView: UIImageView, image: UIImage) {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
        }
    }
}
