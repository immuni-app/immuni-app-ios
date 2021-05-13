// RetriveGreenCertificateView.swift
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

struct RetriveGreenCertificateVM: ViewModelWithLocalState {
    var textFieldCunOtpVM: TextFieldCunOtpVM { TextFieldCunOtpVM() }
    var textFieldHealthCardVM: TextFieldHealthCardVM { TextFieldHealthCardVM() }
    var pickerFieldVM: PickerHealthCardDateVM = PickerHealthCardDateVM(isEnabled: true)

    /// True if it's not possible to execute a new request.
    let isLoading: Bool
}

extension RetriveGreenCertificateVM {
    init?(state _: AppState?, localState: RetriveGreenCertificateLS) {
        isLoading = localState.isLoading
    }
}

// MARK: - View

class RetriveGreenCertificateView: UIView, ViewControllerModellableView {
    typealias VM = RetriveGreenCertificateVM

    private static let horizontalSpacing: CGFloat = 30.0
    static let orderLeftMargin: CGFloat = UIDevice.getByScreen(normal: 70, narrow: 50)

    private let backgroundGradientView = GradientView()
    private let title = UILabel()
    
    private var backButton = ImageButton()
    let scrollView = UIScrollView()
    private let headerView = RetriveGreenCardHeaderView()

    private let textFieldCunOtp = TextFieldCunOtp()
    private let textFieldHealthCard = TextFieldHealthCard()
    private let pickerField = PickerHealthCardDate()

    private let container = UIView()

    private var actionButton = ButtonWithInsets()

    var didTapBack: Interaction?
    var didTapActionButton: Interaction?
    var didTapHealthWorkerMode: Interaction?
    var didTapDiscoverMore: Interaction?

    var didChangeCunTextValue: CustomInteraction<String>?
    var didChangeHealthCardTextValue: CustomInteraction<String>?
    var didChangeSymptomsDateValue: CustomInteraction<String>?
    var didChangeCheckBoxValue: CustomInteraction<Bool?>?

    // MARK: - Setup

    func setup() {
        addSubview(container)

        container.addSubview(textFieldCunOtp)
        container.addSubview(textFieldHealthCard)
        container.addSubview(pickerField)
        container.addSubview(actionButton)

        addSubview(backgroundGradientView)
        addSubview(scrollView)
        addSubview(title)
        addSubview(backButton)
        scrollView.addSubview(headerView)

        scrollView.addSubview(container)
        scrollView.addSubview(textFieldCunOtp)
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

        textFieldCunOtp.didChangeTextValue = { [weak self] value in
            self?.didChangeCunTextValue?(value.uppercased())
           }

        textFieldHealthCard.didChangeTextValue = { [weak self] value in
            self?.didChangeHealthCardTextValue?(value)
           }

        pickerField.didChangePickerValue = { [weak self] value in
            self?.didChangeSymptomsDateValue?(value)
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
        SharedStyle.primaryButton(actionButton, title: L10n.UploadData.Verify.button)
    }

    // MARK: - Update

    func update(oldModel _: VM?) {
        guard let model = self.model else {
            return
        }

        textFieldCunOtp.model = model.textFieldCunOtpVM
        textFieldHealthCard.model = model.textFieldHealthCardVM
        pickerField.model = model.pickerFieldVM

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

        textFieldCunOtp.pin
            .horizontally(25)
            .below(of: headerView)
            .marginTop(25)
            .height(50)

        textFieldHealthCard.pin
            .horizontally(25)
            .below(of: textFieldCunOtp)
            .marginTop(25)
            .height(50)

        pickerField.pin
            .horizontally(25)
            .below(of: textFieldHealthCard)
            .marginTop(25)
            .height(50)

        actionButton.pin
            .horizontally(45)
            .sizeToFit(.width)
            .minHeight(55)
            .below(of: pickerField)
            .marginTop(25)
        
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: container.frame.maxY)
    }
}

// MARK: - Style

private extension RetriveGreenCertificateView {
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
            let content = "Recupera Digital Green Certificate"
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
        static func iconAutonomous(_ view: UIImageView) {
            view.image = Asset.Settings.UploadData.smartPhone.image
            view.contentMode = .scaleAspectFit
        }
        static func iconCallCenter(_ view: UIImageView) {
            view.image = Asset.Settings.UploadData.callCenter.image
            view.contentMode = .scaleAspectFit
        }
        
        static func titleAutonomous(_ label: UILabel) {
            let content = L10n.Settings.Setting.LoadDataAutonomousFormCard.title
            
            let textStyle = TextStyles.pBold.byAdding(
                .color(Palette.purple),
                .alignment(.left)
            )

            TempuraStyles.styleStandardLabel(
                label,
                content: content,
                style: textStyle
            )
        }
        static func titleCallCenter(_ label: UILabel) {
            let content = L10n.Settings.Setting.LoadDataAutonomousCallCenter.title
            let textStyle = TextStyles.pBold.byAdding(
                .color(Palette.purple),
                .alignment(.left)
            )

            TempuraStyles.styleStandardLabel(
                label,
                content: content,
                style: textStyle
            )
        }

        static func choice(_ label: UILabel) {
            let content = L10n.Settings.Setting.LoadDataAutonomous.choice

            let textStyle = TextStyles.p.byAdding(
                .color(Palette.grayNormal),
                .alignment(.center)
            )

            TempuraStyles.styleStandardLabel(
                label,
                content: content,
                style: textStyle
            )

        }
    }
}
