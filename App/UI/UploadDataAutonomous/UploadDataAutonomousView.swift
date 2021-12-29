// UploadDataAutonomousView.swift
// Copyright (C) 2021 Presidenza del Consiglio dei Ministri.
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
  var pickerFieldSymptomsDateVM = PickerSymptomsDateVM(isEnabled: true)
  var asymptomaticCheckBoxVM = AsymptomaticCheckBoxVM(isSelected: false, isEnabled: true)

  /// True if it's not possible to execute a new request.
  let isLoading: Bool
}

extension UploadDataAutonomousVM {
  init?(state _: AppState?, localState: UploadDataAutonomousLS) {
    self.isLoading = localState.isLoading
    self.asymptomaticCheckBoxVM.isSelected = localState.asymptomaticCheckBoxIsChecked
    self.pickerFieldSymptomsDateVM.isEnabled = localState.symptomsDateIsEnabled
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
  private let asymptomaticCheckBox = AsymptomaticCheckBox()

  private let containerForm = UIView()
  private let containerCallCenter = UIView()

  private var actionButtonAutonomous = ButtonWithInsets()
  private var actionButtonCallCenter = ButtonWithInsets()

  var didTapBack: Interaction?
  var didTapVerifyCode: CustomInteraction<Bool?>?
  var didTapHealthWorkerMode: Interaction?
  var didTapDiscoverMore: Interaction?

  var didChangeCunTextValue: CustomInteraction<String>?
  var didChangeHealthCardTextValue: CustomInteraction<String>?
  var didChangeSymptomsDateValue: CustomInteraction<String>?
  var didChangeCheckBoxValue: CustomInteraction<Bool?>?

  // MARK: - Setup

  func setup() {
    addSubview(self.containerForm)
    addSubview(self.containerCallCenter)

    self.containerForm.addSubview(self.iconAutonomous)
    self.containerForm.addSubview(self.titleAutonomous)
    self.containerForm.addSubview(self.textFieldCun)
    self.containerForm.addSubview(self.textFieldHealthCard)
    self.containerForm.addSubview(self.pickerFieldSymptomsDate)
    self.containerForm.addSubview(self.asymptomaticCheckBox)
    self.containerForm.addSubview(self.actionButtonAutonomous)

    self.containerCallCenter.addSubview(self.iconCallCenter)
    self.containerCallCenter.addSubview(self.titleCallCenter)
    self.containerCallCenter.addSubview(self.actionButtonCallCenter)

    addSubview(self.backgroundGradientView)
    addSubview(self.scrollView)
    addSubview(self.title)
    addSubview(self.backButton)
    self.scrollView.addSubview(self.headerView)

    self.scrollView.addSubview(self.containerForm)
    self.scrollView.addSubview(self.iconAutonomous)
    self.scrollView.addSubview(self.titleAutonomous)
    self.scrollView.addSubview(self.textFieldCun)
    self.scrollView.addSubview(self.textFieldHealthCard)
    self.scrollView.addSubview(self.pickerFieldSymptomsDate)
    self.scrollView.addSubview(self.asymptomaticCheckBox)
    self.scrollView.addSubview(self.actionButtonAutonomous)
    self.scrollView.addSubview(self.choice)
    self.scrollView.addSubview(self.containerCallCenter)
    self.scrollView.addSubview(self.iconCallCenter)
    self.scrollView.addSubview(self.titleCallCenter)
    self.scrollView.addSubview(self.actionButtonCallCenter)

    self.backButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapBack?()
    }
    self.actionButtonAutonomous.on(.touchUpInside) { [weak self] _ in
      self?.didTapVerifyCode?(self?.pickerFieldSymptomsDate.model?.isEnabled)
    }
    self.actionButtonCallCenter.on(.touchUpInside) { [weak self] _ in
      self?.didTapHealthWorkerMode?()
    }
    self.headerView.didTapDiscoverMore = { [weak self] in
      self?.didTapDiscoverMore?()
    }

    self.textFieldCun.didChangeTextValue = { [weak self] value in
      self?.didChangeCunTextValue?(value.uppercased())
    }

    self.textFieldHealthCard.didChangeTextValue = { [weak self] value in
      self?.didChangeHealthCardTextValue?(value)
    }

    self.pickerFieldSymptomsDate.didChangePickerValue = { [weak self] value in
      self?.didChangeSymptomsDateValue?(value)
    }

    self.asymptomaticCheckBox.didTapCheckBox = { [weak self] value in
      guard let value = value else { return }
      self?.didChangeCheckBoxValue?(value)
    }
  }

  // MARK: - Style

  func style() {
    Self.Style.background(self)
    Self.Style.backgroundGradient(self.backgroundGradientView)
    Self.Style.scrollView(self.scrollView)
    Self.Style.title(self.title)
    Self.Style.titleAutonomous(self.titleAutonomous)
    Self.Style.iconAutonomous(self.iconAutonomous)
    Self.Style.titleCallCenter(self.titleCallCenter)
    Self.Style.iconCallCenter(self.iconCallCenter)
    Self.Style.choice(self.choice)
    Self.Style.container(self.containerForm)
    Self.Style.container(self.containerCallCenter)

    SharedStyle.navigationBackButton(self.backButton)
    SharedStyle.primaryButton(self.actionButtonAutonomous, title: L10n.UploadData.Verify.button)
    SharedStyle.primaryButton(self.actionButtonCallCenter, title: L10n.UploadData.Verify.button)
  }

  // MARK: - Update

  func update(oldModel _: VM?) {
    guard let model = self.model else {
      return
    }

    self.textFieldCun.model = model.textFieldCunVM
    self.textFieldHealthCard.model = model.textFieldHealthCardVM
    self.pickerFieldSymptomsDate.model = model.pickerFieldSymptomsDateVM
    self.asymptomaticCheckBox.model = model.asymptomaticCheckBoxVM

    setNeedsLayout()
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.backgroundGradientView.pin.all()

    self.backButton.pin
      .left(Self.horizontalSpacing)
      .top(self.safeAreaInsets.top + 20)
      .sizeToFit()

    self.title.pin
      .vCenter(to: self.backButton.edge.vCenter)
      .horizontally(Self.horizontalSpacing + self.backButton.intrinsicContentSize.width + 5)
      .sizeToFit(.width)

    self.scrollView.pin
      .horizontally()
      .below(of: self.title)
      .marginTop(5)
      .bottom(self.safeAreaInsets.bottom)

    self.headerView.pin
      .horizontally()
      .sizeToFit(.width)
      .top(30)

    self.containerForm.pin
      .below(of: self.headerView)
      .marginTop(25)
      .horizontally(25)
      .height(500)

    self.iconAutonomous.pin
      .size(28)
      .left(48)
      .marginTop(45)
      .below(of: self.headerView)

    self.titleAutonomous.pin
      .marginTop(50)
      .marginLeft(20)
      .after(of: self.iconAutonomous)
      .below(of: self.headerView)
      .horizontally()
      .sizeToFit(.width)

    self.textFieldCun.pin
      .horizontally(25)
      .below(of: self.titleAutonomous)
      .marginTop(25)
      .height(75)

    self.textFieldHealthCard.pin
      .horizontally(25)
      .below(of: self.textFieldCun)
      .marginTop(25)
      .height(75)

    self.pickerFieldSymptomsDate.pin
      .horizontally(25)
      .below(of: self.textFieldHealthCard)
      .marginTop(25)
      .height(75)

    self.asymptomaticCheckBox.pin
      .below(of: self.pickerFieldSymptomsDate)
      .marginTop(25)
      .horizontally(40)
      .sizeToFit(.width)

    self.actionButtonAutonomous.pin
      .horizontally(45)
      .sizeToFit(.width)
      .minHeight(55)
      .below(of: self.asymptomaticCheckBox)
      .marginTop(25)

    self.choice.pin
      .below(of: self.actionButtonAutonomous)
      .marginTop(25)
      .horizontally()
      .sizeToFit(.width)

    self.containerCallCenter.pin
      .below(of: self.choice)
      .marginTop(20)
      .horizontally(25)
      .height(0)

    self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: self.containerCallCenter.frame.maxY)
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

    static func choice(_ label: UILabel) {
      let content = ""

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
