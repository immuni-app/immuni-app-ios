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
    
    private let titleAutonomous = UILabel()
    private let iconAutonomous = UIImageView()
    
    private let titleCallCenter = UILabel()
    private let iconCallCenter = UIImageView()

    private let choice = UILabel()
    private var backButton = ImageButton()
    let scrollView = UIScrollView()
    private let headerView = UploadDataAutonomousHeaderView()

    private let textFieldCun = TextFieldCun()
    private let textFieldHealthCard = TextFieldHealthCard()
    private let pickerFieldSymptomsDate = PickerSymptomsDate()
    private let asymptomaticLabel = UILabel()
    
    private let containerForm = UIView()
    private let containerCallCenter = UIView()

    private var actionButtonAutonomous = ButtonWithInsets()
    private var actionButtonCallCenter = ButtonWithInsets()

    var didTapBack: Interaction?
    var didTapVerifyCode: Interaction?
    var didTapHealthWorkerMode: Interaction?
    var didTapDiscoverMore: Interaction?

    var didChangeCunTextValue: CustomInteraction<String>?
    var didChangeHealthCardTextValue: CustomInteraction<String>?
    var didChangeSymptomsDateValue: CustomInteraction<String>?

    // MARK: - Setup

    func setup() {
        self.addSubview(self.containerForm)
        self.addSubview(self.containerCallCenter)

        self.containerForm.addSubview(self.iconAutonomous)
        self.containerForm.addSubview(self.titleAutonomous)
        self.containerForm.addSubview(self.textFieldCun)
        self.containerForm.addSubview(self.textFieldHealthCard)
        self.containerForm.addSubview(self.pickerFieldSymptomsDate)
        self.containerForm.addSubview(self.asymptomaticLabel)
        self.containerForm.addSubview(self.actionButtonAutonomous)
        
        self.containerCallCenter.addSubview(self.iconCallCenter)
        self.containerCallCenter.addSubview(self.titleCallCenter)
        self.containerCallCenter.addSubview(self.actionButtonCallCenter)


        addSubview(backgroundGradientView)
        addSubview(scrollView)
        addSubview(title)
        addSubview(backButton)
        scrollView.addSubview(headerView)

        scrollView.addSubview(containerForm)
        scrollView.addSubview(iconAutonomous)
        scrollView.addSubview(titleAutonomous)
        scrollView.addSubview(textFieldCun)
        scrollView.addSubview(textFieldHealthCard)
        scrollView.addSubview(pickerFieldSymptomsDate)
        scrollView.addSubview(asymptomaticLabel)
        scrollView.addSubview(actionButtonAutonomous)
        scrollView.addSubview(choice)
        scrollView.addSubview(containerCallCenter)
        scrollView.addSubview(iconCallCenter)
        scrollView.addSubview(titleCallCenter)
        scrollView.addSubview(actionButtonCallCenter)

        backButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapBack?()
        }
        actionButtonAutonomous.on(.touchUpInside) { [weak self] _ in
            self?.didTapVerifyCode?()
        }
        actionButtonCallCenter.on(.touchUpInside) { [weak self] _ in
            self?.didTapHealthWorkerMode?()
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
        Self.Style.asymptomaticLabel(asymptomaticLabel)
        Self.Style.titleAutonomous(titleAutonomous)
        Self.Style.iconAutonomous(iconAutonomous)
        Self.Style.titleCallCenter(titleCallCenter)
        Self.Style.iconCallCenter(iconCallCenter)
        Self.Style.choice(choice)
        Self.Style.container(self.containerForm)
        Self.Style.container(self.containerCallCenter)


        SharedStyle.navigationBackButton(backButton)
        SharedStyle.primaryButton(actionButtonAutonomous, title: L10n.UploadData.Verify.button)
        SharedStyle.primaryButton(actionButtonCallCenter, title: L10n.UploadData.Verify.button)
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
        
        containerForm.pin
          .below(of: headerView)
          .marginTop(25)
          .horizontally(25)
          .height(430)
        
        iconAutonomous.pin
            .size(28)
            .left(48)
            .marginTop(45)
            .below(of: headerView)
                
        titleAutonomous.pin
            .marginTop(50)
            .marginLeft(20)
            .after(of: iconAutonomous)
            .below(of: headerView)
            .horizontally()
            .sizeToFit(.width)

        textFieldCun.pin
            .horizontally(25)
            .below(of: titleAutonomous)
            .marginTop(25)
            .height(50)

        textFieldHealthCard.pin
            .horizontally(25)
            .below(of: textFieldCun)
            .marginTop(25)
            .height(50)

        pickerFieldSymptomsDate.pin
            .horizontally(25)
            .below(of: textFieldHealthCard)
            .marginTop(25)
            .height(50)
        
        asymptomaticLabel.pin
            .below(of: pickerFieldSymptomsDate)
            .marginTop(25)
            .left(48)
            .horizontally(Self.horizontalSpacing + backButton.intrinsicContentSize.width + 5)
            .sizeToFit(.width)

        actionButtonAutonomous.pin
            .horizontally(45)
            .sizeToFit(.width)
            .minHeight(55)
            .below(of: asymptomaticLabel)
            .marginTop(25)
        
        choice.pin
            .below(of: actionButtonAutonomous)
            .marginTop(45)
            .horizontally()
            .sizeToFit(.width)
        
        containerCallCenter.pin
          .below(of: choice)
          .marginTop(20)
          .horizontally(25)
          .height(180)
        
        iconCallCenter.pin
            .size(40)
            .left(48)
            .marginTop(50)
            .below(of: choice)
                
        titleCallCenter.pin
            .marginTop(50)
            .marginLeft(20)
            .after(of: iconAutonomous)
            .below(of: choice)
            .horizontally()
            .sizeToFit(.width)
        
        actionButtonCallCenter.pin
            .horizontally(45)
            .sizeToFit(.width)
            .minHeight(55)
            .below(of: titleCallCenter)
            .marginTop(25)
        

        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: containerCallCenter.frame.maxY)
    }
}

// MARK: - Style

private extension UploadDataAutonomousView {
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
            let content = L10n.Settings.Setting.loadDataAutonomous
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
        static func asymptomaticLabel(_ label: UILabel) {
            let content = L10n.Settings.Setting.LoadDataAutonomous.SymptomsDate.message
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
