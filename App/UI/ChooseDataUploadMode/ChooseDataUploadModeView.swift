// ChooseDataUploadModeView.swift
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
import Models
import Tempura

struct ChooseDataUploadModeVM: ViewModelWithLocalState {}

extension ChooseDataUploadModeVM {
    init?(state: AppState?, localState _: ChooseDataUploadModeLS) {
        guard let _ = state else {
            return nil
        }
    }
}

// MARK: - View

class ChooseDataUploadModeView: UIView, ViewControllerModellableView {
    typealias VM = ChooseDataUploadModeVM

    private static let horizontalSpacing: CGFloat = 30.0
    static let orderRightMargin: CGFloat = UIDevice.getByScreen(normal: 70, narrow: 50)
    static let labelLeftMargin: CGFloat = 25

    private let backgroundGradientView = GradientView()
    private let title = UILabel()
    private var backButton = ImageButton()
    let scrollView = UIScrollView()

    private let healthWorkerModeCard = DataUploadHealthWorkerModeView()
    private let autonomousModeCard = DataUploadAutonomousModeView()

    var didTapBack: Interaction?
    var didTapHealthWorkerMode: Interaction?
    var didTapAutonomousMode: Interaction?

    // MARK: - Setup

    func setup() {
        addSubview(backgroundGradientView)
        addSubview(scrollView)
        addSubview(title)
        addSubview(backButton)

        scrollView.addSubview(healthWorkerModeCard)
        scrollView.addSubview(autonomousModeCard)

        backButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapBack?()
        }

        healthWorkerModeCard.didTapAction = { [weak self] in
            self?.didTapHealthWorkerMode?()
        }
        
        autonomousModeCard.didTapAction = { [weak self] in
            self?.didTapAutonomousMode?()
        }
    }

    // MARK: - Style

    func style() {
        Self.Style.background(self)
        Self.Style.backgroundGradient(backgroundGradientView)

        Self.Style.scrollView(scrollView)
        Self.Style.title(title)

        SharedStyle.navigationBackButton(backButton)
    }

    // MARK: - Update

    func update(oldModel _: VM?) {
        guard let _ = self.model else {
            return
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundGradientView.pin.all()

        backButton.pin
            .left(Self.horizontalSpacing)
            .top(universalSafeAreaInsets.top + 20)
            .sizeToFit()

        title.pin
            .vCenter(to: backButton.edge.vCenter)
            .horizontally(Self.horizontalSpacing + backButton.intrinsicContentSize.width + 5)
            .sizeToFit(.width)

        scrollView.pin
            .horizontally()
            .below(of: title)
            .marginTop(5)
            .bottom(universalSafeAreaInsets.bottom)

        healthWorkerModeCard.pin
            .horizontally()
            .sizeToFit(.width)
            .marginTop(25)

        autonomousModeCard.pin
            .horizontally()
            .sizeToFit(.width)
            .below(of: healthWorkerModeCard)
            .marginTop(22)

        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: autonomousModeCard.frame.maxY)
    }
}

// MARK: - Style

private extension ChooseDataUploadModeView {
    enum Style {
        static func background(_ view: UIView) {
            view.backgroundColor = Palette.grayWhite
        }

        static func separator(_ view: UIView) {
            view.backgroundColor = Palette.primary.withAlphaComponent(0.4)
        }

        static func backgroundGradient(_ gradientView: GradientView) {
            gradientView.isUserInteractionEnabled = false
            gradientView.gradient = Palette.gradientBackgroundBlueOnBottom
        }

        static func scrollView(_ scrollView: UIScrollView) {
            scrollView.backgroundColor = .clear
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            scrollView.showsVerticalScrollIndicator = false
        }

        static func title(_ label: UILabel) {
            let content = L10n.Settings.Setting.loadData
            TempuraStyles.styleShrinkableLabel(
                label,
                content: content,
                style: TextStyles.navbarSmallTitle.byAdding(
                    .color(Palette.grayDark),
                    .alignment(.center)
                ),
                numberOfLines: 1
            )
        }
    }
}
