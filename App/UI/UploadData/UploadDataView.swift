// UploadDataView.swift
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

struct UploadDataVM: ViewModelWithLocalState {
  /// The code to be verified
  let code: OTP
  /// True if it's not possible to execute a new request.
  let isLoading: Bool
  /// The number of seconds until a new request can be performed.
  let errorSecondsLeft: Int
    
  let callCenterMode: Bool

  var headerVM: UploadDataHeaderVM {
    return UploadDataHeaderVM(callCenterMode: callCenterMode)
  }

  var codeVM: UploadDataCodeVM {
    return UploadDataCodeVM(order: 1, code: self.code)
  }

  var messageVM: UploadDataMessageVM {
    return UploadDataMessageVM(order: 2)
  }

  var verifyVM: UploadDataVerifyVM {
    return UploadDataVerifyVM(order: 3, isLoading: self.isLoading, errorSecondsLeft: self.errorSecondsLeft)
  }

  var hasError: Bool {
    return self.errorSecondsLeft > 0
  }

  func shouldAnimateLayout(oldModel: UploadDataVM?) -> Bool {
    guard let oldModel = oldModel else {
      return false
    }

    return self.hasError != oldModel.hasError
  }
}

extension UploadDataVM {
  init?(state: AppState?, localState: UploadDataLS) {
    guard let state = state else {
      return nil
    }

    self.code = state.ingestion.otp
    self.isLoading = localState.isLoading
    self.errorSecondsLeft = localState.errorSecondsLeft
    self.callCenterMode = localState.callCenterMode
  }
}

// MARK: - View

class UploadDataView: UIView, ViewControllerModellableView {
  typealias VM = UploadDataVM

  private static let horizontalSpacing: CGFloat = 30.0
  static let orderLeftMargin: CGFloat = UIDevice.getByScreen(normal: 70, narrow: 50)

  private let backgroundGradientView = GradientView()
  private let title = UILabel()
  private var backButton = ImageButton()
  let scrollView = UIScrollView()
  private let headerView = UploadDataHeaderView()
  private let codeCard = UploadDataCodeView()
  private let messageCard = UploadDataMessageView()
  let verifyCard = UploadDataVerifyView()
  private let codeSeparator = UIView()
  private let verifySeparator = UIView()

  var didTapBack: Interaction?
  var didTapVerifyCode: Interaction?
  var didTapDiscoverMore: Interaction?
  var didTapContact: Interaction?

  // MARK: - Setup

  func setup() {
    self.addSubview(self.backgroundGradientView)
    self.addSubview(self.scrollView)
    self.addSubview(self.title)
    self.addSubview(self.backButton)

    self.scrollView.addSubview(self.headerView)
    self.scrollView.addSubview(self.codeCard)
    self.scrollView.addSubview(self.messageCard)
    self.scrollView.addSubview(self.verifyCard)

    self.scrollView.addSubview(self.codeSeparator)
    self.scrollView.addSubview(self.verifySeparator)

    self.backButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapBack?()
    }

    self.verifyCard.didTapAction = { [weak self] in
      self?.didTapVerifyCode?()
    }

    self.headerView.didTapDiscoverMore = { [weak self] in
      self?.didTapDiscoverMore?()
    }
    self.headerView.didTapContact = { [weak self] in
      self?.didTapContact?()
    }

  }

  // MARK: - Style

  func style() {
    Self.Style.background(self)
    Self.Style.backgroundGradient(self.backgroundGradientView)
    Self.Style.separator(self.codeSeparator)
    Self.Style.separator(self.verifySeparator)
    Self.Style.scrollView(self.scrollView)

    SharedStyle.navigationBackButton(self.backButton)
  }

  // MARK: - Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }
    
    self.headerView.model = model.headerVM
    self.codeCard.model = model.codeVM
    self.messageCard.model = model.messageVM
    self.verifyCard.model = model.verifyVM

    Self.Style.title(self.title, content: model.callCenterMode ? L10n.Settings.Setting.loadDataAutonomous : L10n.Settings.Setting.LoadData.title)

    if model.shouldAnimateLayout(oldModel: oldModel) {
      self.setNeedsLayout()
      UIView.animate(withDuration: 0.3) {
        self.layoutIfNeeded()
      }
    }
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

    self.codeCard.pin
      .horizontally()
      .sizeToFit(.width)
      .below(of: self.headerView)
      .marginTop(25)

    self.messageCard.pin
      .horizontally()
      .sizeToFit(.width)
      .below(of: self.codeCard)
      .marginTop(22)

    self.verifyCard.pin
      .horizontally()
      .sizeToFit(.width)
      .below(of: self.messageCard)
      .marginTop(22)

    self.codeSeparator.pin
      .width(3)
      .height(10)
      .below(of: self.codeCard)
      .above(of: self.messageCard)
      .align(.center)
      .left(64)

    self.verifySeparator.pin
      .width(3)
      .height(10)
      .below(of: self.messageCard)
      .above(of: self.verifyCard)
      .align(.center)
      .left(64)

    self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: self.verifyCard.frame.maxY)
  }
}

// MARK: - Style

private extension UploadDataView {
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

    static func title(_ label: UILabel, content: String) {
    
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
