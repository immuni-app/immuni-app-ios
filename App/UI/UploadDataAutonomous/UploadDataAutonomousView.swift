// UploadDataAutonomousView.swift
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

struct UploadDataAutonomousVM: ViewModelWithLocalState {
    var textFieldCunVM: TextFieldCunVM { TextFieldCunVM() }
    var textFieldHealthCardVM: TextFieldHealthCardVM { TextFieldHealthCardVM() }
    var pickerFieldSymptomsDateVM: PickerSymptomsDateVM { PickerSymptomsDateVM() }

    /// True if it's not possible to execute a new request.
    let isLoading: Bool
}

extension UploadDataAutonomousVM {
    init?(state _: AppState?, localState: UploadDataAutonomousLS) {
        isLoading = localState.isLoading
    }
}

// MARK: - View

class UploadDataAutonomousView: UIView, ViewControllerModellableView {
    typealias VM = UploadDataAutonomousVM

    private static let horizontalSpacing: CGFloat = 30.0
    static let orderLeftMargin: CGFloat = UIDevice.getByScreen(normal: 70, narrow: 50)

    private let backgroundGradientView = GradientView()
    private let title = UILabel()
    private var backButton = ImageButton()
    let scrollView = UIScrollView()
    private let headerView = UploadDataAutonomousHeaderView()

    private let textFieldCun = TextFieldCun()
    private let textFieldHealthCard = TextFieldHealthCard()
    private let pickerFieldSymptomsDate = PickerSymptomsDate()

    private var actionButton = ButtonWithInsets()

    var didTapBack: Interaction?
    var didTapVerifyCode: Interaction?
    var didTapDiscoverMore: Interaction?

    var didChangeCunTextValue: CustomInteraction<String>?
    var didChangeHealthCardTextValue: CustomInteraction<String>?
    var didChangeSymptomsDateValue: CustomInteraction<String>?

    // MARK: - Setup

    func setup() {
        addSubview(backgroundGradientView)
        addSubview(scrollView)
        addSubview(title)
        addSubview(backButton)
        addSubview(actionButton)

        scrollView.addSubview(headerView)
        scrollView.addSubview(textFieldCun)
        scrollView.addSubview(textFieldHealthCard)
        scrollView.addSubview(pickerFieldSymptomsDate)

        backButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapBack?()
        }
        actionButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapVerifyCode?()
        }
        headerView.didTapDiscoverMore = { [weak self] in
            self?.didTapDiscoverMore?()
        }

        textFieldCun.didChangeTextValue = { [weak self] value in
            self?.didChangeCunTextValue?(value)
        }

        textFieldHealthCard.didChangeTextValue = { [weak self] value in
            self?.didChangeHealthCardTextValue?(value)
        }

        pickerFieldSymptomsDate.didChangePickerValue = { [weak self] value in
            self?.didChangeSymptomsDateValue?(value)
        }
    }

    // MARK: - Style

    func style() {
        Self.Style.background(self)
        Self.Style.backgroundGradient(backgroundGradientView)
        Self.Style.scrollView(scrollView)
        Self.Style.title(title)

        SharedStyle.navigationBackButton(backButton)
        SharedStyle.primaryButton(actionButton, title: L10n.UploadData.Verify.button)
    }

    // MARK: - Update

    func update(oldModel _: VM?) {
        guard let model = self.model else {
            return
        }

        textFieldCun.model = model.textFieldCunVM
        textFieldHealthCard.model = model.textFieldHealthCardVM
        pickerFieldSymptomsDate.model = model.pickerFieldSymptomsDateVM

        setNeedsLayout()
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

        headerView.pin
            .horizontally()
            .sizeToFit(.width)
            .top(30)

        textFieldCun.pin
            .horizontally()
            .below(of: headerView)
            .marginTop(25)
            .height(50)

        textFieldHealthCard.pin
            .horizontally()
            .below(of: textFieldCun)
            .marginTop(25)
            .height(50)

        pickerFieldSymptomsDate.pin
            .horizontally()
            .below(of: textFieldHealthCard)
            .marginTop(25)
            .height(50)

        actionButton.pin
            .horizontally(25)
            .sizeToFit(.width)
            .minHeight(55)
            .below(of: pickerFieldSymptomsDate)
            .marginTop(25)

        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: actionButton.frame.maxY)
    }
}

// MARK: - Style

private extension UploadDataAutonomousView {
    enum Style {
        static func background(_ view: UIView) {
            view.backgroundColor = Palette.grayWhite
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
