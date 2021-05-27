// GreenCertificateHeaderView.swift
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
import Lottie
import Tempura

struct GreenCertificateHeaderVM: ViewModel {}

// MARK: - View

class GreenCertificateHeaderView: UIView, ModellableView {
    static let horizontalMargin: CGFloat = 30.0
    static let textMargin: CGFloat = 10.0

    typealias VM = GreenCertificateHeaderVM

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

    private let message = UILabel()
    private var label = UILabel()

    // MARK: - Setup

    func setup() {
        addSubview(message)
        addSubview(label)

    }

    // MARK: - Style

    func style() {
        Self.Style.background(self)
        Self.Style.message(message)
        Self.Style.label(label)
    }

    // MARK: - Update

    func update(oldModel _: VM?) {}

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        label.pin
            .bottom()
            .horizontally(Self.horizontalMargin)
            .sizeToFit(.width)

        message.pin
            .above(of: label, aligned: .left)
            .marginBottom(Self.textMargin)
            .horizontally(Self.horizontalMargin)
            .sizeToFit(.width)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let availableWidth = size.width - 2 * Self.horizontalMargin
        let availableSize = CGSize(width: availableWidth, height: .infinity)

        let messageSize = message.sizeThatFits(availableSize)
        let labelSize = label.sizeThatFits(availableSize)

        return CGSize(width: size.width, height: messageSize.height + labelSize.height + Self.textMargin)
    }
}

// MARK: - Style

private extension GreenCertificateHeaderView {
    enum Style {
        static func background(_ view: UIView) {
            view.backgroundColor = .clear
        }

        static func message(_ label: UILabel) {
            let content = L10n.HomeView.GreenCertificate.header

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

        static func label(_ label: UILabel) {
            let content = L10n.HomeView.GreenCertificate.label

            let textStyle = TextStyles.pSemibold.byAdding(
                .color(Palette.grayDark),
                .alignment(.left)
            )

            TempuraStyles.styleStandardLabel(
                label,
                content: content,
                style: textStyle
            )
        }
    }
}
