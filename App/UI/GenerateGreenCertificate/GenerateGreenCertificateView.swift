// GenerateGreenCertificateView.swift
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
import DropDown

struct GenerateGreenCertificateVM: ViewModelWithLocalState {
    var textFieldCodeVM: TextFieldCodeVM = TextFieldCodeVM(codeType: nil)
    var textFieldHealthCardVM: TextFieldHealthCardVM { TextFieldHealthCardVM() }
    var pickerFieldVM: PickerHealthCardDateVM { PickerHealthCardDateVM() }
    var textFieldCodeTypeVM: TextFieldCodeTypeVM { TextFieldCodeTypeVM() }

    /// True if it's not possible to execute a new request.
    let isLoading: Bool
}

extension GenerateGreenCertificateVM {
    init?(state _: AppState?, localState: GenerateGreenCertificateLS) {
        isLoading = localState.isLoading
        self.textFieldCodeVM.codeType = localState.codeType
    }
}

// MARK: - View

class GenerateGreenCertificateView: UIView, ViewControllerModellableView {
    typealias VM = GenerateGreenCertificateVM

    private static let horizontalSpacing: CGFloat = 30.0
    static let orderLeftMargin: CGFloat = UIDevice.getByScreen(normal: 70, narrow: 50)

    private let backgroundGradientView = GradientView()
    private let title = UILabel()
    private let dropdown = DropDown()

    private var backButton = ImageButton()
    let scrollView = UIScrollView()
    private let headerView = GenerateGreenCardHeaderView()

    private let textFieldCode = TextFieldCode()
    private let textFieldHealthCard = TextFieldHealthCard()
    private let pickerField = PickerHealthCardDate()
    private let textFieldCodeType = TextFieldCodeType()

    private let container = UIView()

    private var actionButton = ButtonWithInsets()

    var didTapBack: Interaction?
    var didTapActionButton: Interaction?
    var didTapDiscoverMore: Interaction?

    var didChangeCodeValue: CustomInteraction<String>?
    var didChangeHealthCardValue: CustomInteraction<String>?
    var didChangeHealthCardDateValue: CustomInteraction<String>?
    var didChangeCodeType: CustomInteraction<CodeType>?

    // MARK: - Setup

    func setup() {
        addSubview(container)

        container.addSubview(textFieldCodeType)
        container.addSubview(textFieldCode)
        container.addSubview(textFieldHealthCard)
        container.addSubview(pickerField)
        container.addSubview(actionButton)

        addSubview(backgroundGradientView)
        addSubview(scrollView)
        addSubview(title)
        addSubview(backButton)
        scrollView.addSubview(headerView)

        scrollView.addSubview(container)
        scrollView.addSubview(textFieldCodeType)
        scrollView.addSubview(textFieldCode)
        scrollView.addSubview(textFieldHealthCard)
        scrollView.addSubview(pickerField)
        scrollView.addSubview(actionButton)

        backButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapBack?()
           }
        actionButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapActionButton?()
           }
      
        headerView.didTapDiscoverMore = { [weak self] in
            self?.didTapDiscoverMore?()
           }

        textFieldCode.didChangeTextValue = { [weak self] value in
            self?.didChangeCodeValue?(value)
           }

        textFieldHealthCard.didChangeTextValue = { [weak self] value in
            self?.didChangeHealthCardValue?(value)
           }

        pickerField.didChangePickerValue = { [weak self] value in
            self?.didChangeHealthCardDateValue?(value)
           }
        textFieldCodeType.didChangeCodeType = { [weak self] value in
            self?.didChangeCodeType?(value)
           }
           
       }
    // MARK: - Style

    func style() {
        Self.Style.background(self)
        Self.Style.backgroundGradient(backgroundGradientView)
        Self.Style.scrollView(scrollView)
        Self.Style.title(title)
        
        Self.Style.container(container)

        SharedStyle.navigationBackButton(backButton)
        SharedStyle.primaryButton(actionButton, title: L10n.confirm)
    }

    // MARK: - Update

    func update(oldModel _: VM?) {
        guard let model = self.model else {
            return
        }

        textFieldCode.model = model.textFieldCodeVM
        textFieldHealthCard.model = model.textFieldHealthCardVM
        pickerField.model = model.pickerFieldVM
        textFieldCodeType.model = model.textFieldCodeTypeVM

        setNeedsLayout()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundGradientView.pin.all()

        backButton.pin
            .left(Self.horizontalSpacing)
            .top(self.safeAreaInsets.top + 20)
            .sizeToFit()

        title.pin
            .vCenter(to: backButton.edge.vCenter)
            .horizontally(Self.horizontalSpacing + backButton.intrinsicContentSize.width + 5)
            .sizeToFit(.width)

        scrollView.pin
            .horizontally()
            .below(of: title)
            .marginTop(5)
            .bottom(self.safeAreaInsets.bottom)

        headerView.pin
            .horizontally()
            .sizeToFit(.width)
            .top(30)

        textFieldCodeType.pin
            .horizontally(25)
            .below(of: headerView)
            .marginTop(25)
            .height(75)
        
        textFieldCode.pin
            .horizontally(25)
            .below(of: textFieldCodeType)
            .marginTop(25)
            .height(75)

        textFieldHealthCard.pin
            .horizontally(25)
            .below(of: textFieldCode)
            .marginTop(25)
            .height(75)

        pickerField.pin
            .horizontally(25)
            .below(of: textFieldHealthCard)
            .marginTop(25)
            .height(75)

        actionButton.pin
            .horizontally(45)
            .sizeToFit(.width)
            .minHeight(55)
            .below(of: pickerField)
            .marginTop(25)
        
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: actionButton.frame.maxY+150)
    }
}

// MARK: - Style

private extension GenerateGreenCertificateView {
    enum Style {
        
        static func container(_ view: UIView) {
          view.backgroundColor = Palette.white
          view.layer.cornerRadius = SharedStyle.cardCornerRadius
          view.addShadow(.cardLightBlue)
        }
        
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
            let content = L10n.HomeView.GenerateGreenCertificate.title
            TempuraStyles.styleShrinkableLabel(
                label,
                content: content,
                style: TextStyles.navbarSmallTitle.byAdding(
                    .color(Palette.grayDark),
                    .alignment(.center)
                ),
                numberOfLines: 2
            )
        }
    }
}

