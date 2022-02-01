// GreenCertificateTestDetailView.swift
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

struct GreenCertificateTestDetailVM: ViewModelWithLocalState {
  let greenCertificate: GreenCertificate
}

struct ConfigurationState {
  static var state = ["": ["": ""]]
}

extension GreenCertificateTestDetailVM {
  init?(state: AppState?, localState: GreenCertificateTestDetailLS) {
    guard let state = state else {
      return nil
    }
    self.greenCertificate = localState.greenCertificate
    ConfigurationState.state = state.configuration.eudccExpiration
  }
}

// MARK: - View

class GreenCertificateTestDetailView: UIView, ViewControllerModellableView {
  typealias VM = GreenCertificateTestDetailVM

  private static let horizontalSpacing: CGFloat = 30.0
  static let orderRightMargin: CGFloat = UIDevice.getByScreen(normal: 70, narrow: 50)
  static let labelLeftMargin: CGFloat = 25

  private let backgroundGradientView = GradientView()
  private let title = UILabel()
  let scrollView = UIScrollView()
  private var closeButton = ImageButton()

  private var certificateTypeLabel = UILabel()
  private var validUntilLabel = UILabel()
  private var validUntilLabelEn = UILabel()
  private var validUntil = UILabel()

  private var diseaseTestLabel = UILabel()
  private var diseaseTestLabelEn = UILabel()
  private var diseaseTest = UILabel()
  private var typeOfTestLabel = UILabel()
  private var typeOfTestLabelEn = UILabel()
  private var typeOfTest = UILabel()
  private var testResultLabel = UILabel()
  private var testResultLabelEn = UILabel()
  private var testResult = UILabel()
  private var ratTestNameAndManufacturerLabel = UILabel()
  private var ratTestNameAndManufacturerLabelEn = UILabel()
  private var ratTestNameAndManufacturer = UILabel()
  private var dateTimeOfSampleCollectionLabel = UILabel()
  private var dateTimeOfSampleCollectionLabelEn = UILabel()
  private var dateTimeOfSampleCollection = UILabel()
  private var testingCentreLabel = UILabel()
  private var testingCentreLabelEn = UILabel()
  private var testingCentre = UILabel()
  private var countryOfTestLabel = UILabel()
  private var countryOfTestLabelEn = UILabel()
  private var countryOfTest = UILabel()
  private var certificateIssuerLabel = UILabel()
  private var certificateIssuerLabelEn = UILabel()
  private var certificateIssuer = UILabel()

  private var paragraph = UILabel()
  private var contactButton = TextButton()

  var didTapBack: Interaction?
  var didTapContact: CustomInteraction<String>?

  // MARK: - Setup

  func setup() {
    addSubview(self.backgroundGradientView)
    addSubview(self.scrollView)
    addSubview(self.title)
    addSubview(self.closeButton)
    addSubview(self.contactButton)
    self.scrollView.addSubview(self.contactButton)

    addSubview(self.certificateTypeLabel)
    self.scrollView.addSubview(self.certificateTypeLabel)
    addSubview(self.validUntilLabel)
    self.scrollView.addSubview(self.validUntilLabel)
    addSubview(self.validUntilLabelEn)
    self.scrollView.addSubview(self.validUntilLabelEn)
    addSubview(self.validUntil)
    self.scrollView.addSubview(self.validUntil)

    addSubview(self.diseaseTestLabel)
    self.scrollView.addSubview(self.diseaseTestLabel)
    addSubview(self.diseaseTestLabelEn)
    self.scrollView.addSubview(self.diseaseTestLabelEn)
    addSubview(self.diseaseTest)
    self.scrollView.addSubview(self.diseaseTest)
    addSubview(self.typeOfTestLabelEn)
    self.scrollView.addSubview(self.typeOfTestLabelEn)
    addSubview(self.typeOfTestLabel)
    self.scrollView.addSubview(self.typeOfTestLabel)
    addSubview(self.typeOfTest)
    self.scrollView.addSubview(self.typeOfTest)
    addSubview(self.testResultLabel)
    self.scrollView.addSubview(self.testResultLabel)
    addSubview(self.testResultLabelEn)
    self.scrollView.addSubview(self.testResultLabelEn)
    addSubview(self.testResult)
    self.scrollView.addSubview(self.testResult)
    addSubview(self.dateTimeOfSampleCollectionLabel)
    self.scrollView.addSubview(self.dateTimeOfSampleCollectionLabel)
    addSubview(self.dateTimeOfSampleCollectionLabelEn)
    self.scrollView.addSubview(self.dateTimeOfSampleCollectionLabelEn)
    addSubview(self.dateTimeOfSampleCollection)
    self.scrollView.addSubview(self.dateTimeOfSampleCollection)
    addSubview(self.testingCentreLabel)
    self.scrollView.addSubview(self.testingCentreLabel)
    addSubview(self.testingCentreLabelEn)
    self.scrollView.addSubview(self.testingCentreLabelEn)
    addSubview(self.testingCentre)
    self.scrollView.addSubview(self.testingCentre)
    addSubview(self.countryOfTestLabel)
    self.scrollView.addSubview(self.countryOfTestLabel)
    addSubview(self.countryOfTestLabelEn)
    self.scrollView.addSubview(self.countryOfTestLabelEn)
    addSubview(self.countryOfTest)
    self.scrollView.addSubview(self.countryOfTest)
    addSubview(self.certificateIssuerLabel)
    self.scrollView.addSubview(self.certificateIssuerLabel)
    addSubview(self.certificateIssuerLabelEn)
    self.scrollView.addSubview(self.certificateIssuerLabelEn)
    addSubview(self.certificateIssuer)
    self.scrollView.addSubview(self.certificateIssuer)

    self.scrollView.addSubview(self.paragraph)

    self.closeButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapBack?()
    }
    self.contactButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapContact?(L10n.HomeView.GreenCertificate.Detail.url)
    }
  }

  // MARK: - Style

  func style() {
    Self.Style.background(self)
    Self.Style.backgroundGradient(self.backgroundGradientView)

    Self.Style.subTitle(self.certificateTypeLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.certificateType)

    Self.Style.label(self.validUntilLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.validUntil)
    Self.Style.label(self.validUntilLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.validUntilEn)

    Self.Style.scrollView(self.scrollView)
    Self.Style.headerTitle(self.title, content: L10n.HomeView.GreenCertificate.Detail.title)

    Self.Style.label(self.diseaseTestLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.disease)
    Self.Style.label(self.typeOfTestLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.typeOfTest)
    Self.Style.label(self.testResultLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.testResult)
    Self.Style.label(
      self.ratTestNameAndManufacturerLabel,
      text: L10n.HomeView.GreenCertificate.Detail.Label.Test.ratTestNameAndManufacturer
    )
    Self.Style.label(
      self.dateTimeOfSampleCollectionLabel,
      text: L10n.HomeView.GreenCertificate.Detail.Label.Test.dateTimeOfSampleCollection
    )
    Self.Style.label(self.testingCentreLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.testingCentre)
    Self.Style.label(self.countryOfTestLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.countryOfTest)
    Self.Style.label(self.certificateIssuerLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.certificateIssuer)

    Self.Style.label(self.diseaseTestLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.diseaseEn)
    Self.Style.label(self.typeOfTestLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.typeOfTestEn)
    Self.Style.label(self.testResultLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.testResultEn)
    Self.Style.label(
      self.ratTestNameAndManufacturerLabelEn,
      text: L10n.HomeView.GreenCertificate.Detail.Label.Test.ratTestNameAndManufacturerEn
    )

    Self.Style.label(
      self.dateTimeOfSampleCollectionLabelEn,
      text: L10n.HomeView.GreenCertificate.Detail.Label.Test.dateTimeOfSampleCollectionEn
    )
    Self.Style.label(self.testingCentreLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.testingCentreEn)
    Self.Style.label(self.countryOfTestLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.countryOfTestEn)
    Self.Style.label(
      self.certificateIssuerLabelEn,
      text: L10n.HomeView.GreenCertificate.Detail.Label.Test.certificateIssuerEn
    )

    Self.Style.closeButton(self.closeButton)
  }

  // MARK: - Update

  func update(oldModel _: VM?) {
    guard let model = self.model else {
      return
    }

    if let detailTestCertificate = model.greenCertificate.detailTestCertificate {
      Self.Style.value(self.diseaseTest, text: detailTestCertificate.disease)
      if let testType = TestType(rawValue: detailTestCertificate.typeOfTest) {
        Self.Style.value(self.typeOfTest, text: testType.getDescription())
        Self.Style.value(self.validUntil, text: testType.gedValidUntilValue())
      } else {
        Self.Style.value(self.typeOfTest, text: "---")
      }
      if let testResultValue = TestResult(rawValue: detailTestCertificate.testResult) {
        Self.Style.value(self.testResult, text: testResultValue.getDescription())
      } else {
        Self.Style.value(self.testResult, text: "---")
      }
      if let ratTestNameAndManufacturerValue = detailTestCertificate.ratTestNameAndManufacturer,
         !ratTestNameAndManufacturerValue.isEmpty
      {
        addSubview(self.ratTestNameAndManufacturerLabel)
        self.scrollView.addSubview(self.ratTestNameAndManufacturerLabel)
        addSubview(self.ratTestNameAndManufacturerLabelEn)
        self.scrollView.addSubview(self.ratTestNameAndManufacturerLabelEn)
        addSubview(self.ratTestNameAndManufacturer)
        self.scrollView.addSubview(self.ratTestNameAndManufacturer)
        Self.Style.value(self.ratTestNameAndManufacturer, text: ratTestNameAndManufacturerValue)
      } else {
        self.ratTestNameAndManufacturerLabelEn.removeFromSuperview()
        self.ratTestNameAndManufacturerLabel.removeFromSuperview()
        self.ratTestNameAndManufacturer.removeFromSuperview()
      }

      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      let dateFormatterUtc = DateFormatter()
      dateFormatterUtc.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ+00:00"

      let dateFormatterView = DateFormatter()
      dateFormatterView.dateFormat = "yyyy-MM-dd HH:mm:ss"

      if let dateTimeOfSampleCollectionValue = dateFormatter.date(from: detailTestCertificate.dateTimeOfSampleCollection) {
        Self.Style.value(
          self.dateTimeOfSampleCollection,
          text: dateFormatterView.string(from: dateTimeOfSampleCollectionValue)
        )
      } else if let dateTimeOfSampleCollectionValue = dateFormatterUtc
        .date(from: detailTestCertificate.dateTimeOfSampleCollection)
      {
        Self.Style.value(
          self.dateTimeOfSampleCollection,
          text: dateFormatterView.string(from: dateTimeOfSampleCollectionValue)
        )
      } else {
        Self.Style.value(self.dateTimeOfSampleCollection, text: "---")
      }

      Self.Style.value(
        self.testingCentre,
        text: detailTestCertificate.testingCentre.isEmpty ? "---" : detailTestCertificate.testingCentre
      )
      Self.Style.value(
        self.countryOfTest,
        text: detailTestCertificate.countryOfTest.isEmpty ? "---" : detailTestCertificate.countryOfTest
      )
      Self.Style.value(
        self.certificateIssuer,
        text: detailTestCertificate.certificateIssuer.isEmpty ? "---" : detailTestCertificate.certificateIssuer
      )
    }

    Self.Style.label(self.paragraph, text: L10n.HomeView.GreenCertificate.Detail.paragraph)
    Self.Style.contactButton(self.contactButton, content: L10n.HomeView.GreenCertificate.Detail.url)
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()
    var isMolecular = false
    if let detailTestCertificate = self.model?.greenCertificate.detailTestCertificate,
       let ratTestNameAndManufacturerValue = detailTestCertificate.ratTestNameAndManufacturer,
       ratTestNameAndManufacturerValue != ""
    {
      isMolecular = true
    }

    self.backgroundGradientView.pin.all()

    self.closeButton.pin
      .top(30)
      .right(28)
      .sizeToFit()

    self.title.pin
      .top(60)
      .horizontally(30)
      .sizeToFit()

    self.certificateTypeLabel.pin
      .minHeight(25)
      .below(of: self.title)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.diseaseTestLabelEn.pin
      .minHeight(25)
      .below(of: self.certificateTypeLabel)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.diseaseTestLabel.pin
      .minHeight(25)
      .below(of: self.diseaseTestLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.diseaseTest.pin
      .minHeight(25)
      .below(of: self.diseaseTestLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.typeOfTestLabelEn.pin
      .minHeight(25)
      .below(of: self.diseaseTest)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.typeOfTestLabel.pin
      .minHeight(25)
      .below(of: self.typeOfTestLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.typeOfTest.pin
      .minHeight(25)
      .below(of: self.typeOfTestLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.validUntilLabelEn.pin
      .minHeight(25)
      .below(of: self.typeOfTest)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.validUntilLabel.pin
      .minHeight(25)
      .below(of: self.validUntilLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.validUntil.pin
      .minHeight(25)
      .below(of: self.validUntilLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.ratTestNameAndManufacturerLabelEn.pin
      .minHeight(25)
      .below(of: self.validUntil)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.ratTestNameAndManufacturerLabel.pin
      .minHeight(25)
      .below(of: self.ratTestNameAndManufacturerLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.ratTestNameAndManufacturer.pin
      .minHeight(25)
      .below(of: self.ratTestNameAndManufacturerLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.dateTimeOfSampleCollectionLabelEn.pin
      .minHeight(25)
      .below(of: isMolecular ? self.ratTestNameAndManufacturer : self.validUntil)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.dateTimeOfSampleCollectionLabel.pin
      .minHeight(25)
      .below(of: self.dateTimeOfSampleCollectionLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.dateTimeOfSampleCollection.pin
      .minHeight(25)
      .below(of: self.dateTimeOfSampleCollectionLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.testResultLabelEn.pin
      .minHeight(25)
      .below(of: self.dateTimeOfSampleCollection)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.testResultLabel.pin
      .minHeight(25)
      .below(of: self.testResultLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.testResult.pin
      .minHeight(25)
      .below(of: self.testResultLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.testingCentreLabelEn.pin
      .minHeight(25)
      .below(of: self.testResult)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.testingCentreLabel.pin
      .minHeight(25)
      .below(of: self.testingCentreLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.testingCentre.pin
      .minHeight(25)
      .below(of: self.testingCentreLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.countryOfTestLabelEn.pin
      .minHeight(25)
      .below(of: self.testingCentre)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.countryOfTestLabel.pin
      .minHeight(25)
      .below(of: self.countryOfTestLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.countryOfTest.pin
      .minHeight(25)
      .below(of: self.countryOfTestLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.certificateIssuerLabelEn.pin
      .minHeight(25)
      .below(of: self.countryOfTest)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.certificateIssuerLabel.pin
      .minHeight(25)
      .below(of: self.certificateIssuerLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.certificateIssuer.pin
      .minHeight(25)
      .below(of: self.certificateIssuerLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.paragraph.pin
      .minHeight(25)
      .below(of: self.certificateIssuer)
      .marginTop(15)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.contactButton.pin
      .minHeight(25)
      .below(of: self.paragraph)
      .marginTop(15)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.scrollView.pin
      .horizontally()
      .below(of: self.title)
      .marginTop(5)
      .bottom(self.safeAreaInsets.bottom)

    self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: self.contactButton.frame.maxY)
  }
}

// MARK: - Style

private extension GreenCertificateTestDetailView {
  enum Style {
    static func closeButton(_ btn: ImageButton) {
      SharedStyle.closeButton(btn)
    }

    static func background(_ view: UIView) {
      view.backgroundColor = Palette.grayWhite
    }

    static func backgroundGradient(_ gradientView: GradientView) {
      gradientView.isUserInteractionEnabled = false
      gradientView.gradient = Palette.gradientScrollOverlay
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
        )
      )
    }

    static func headerTitle(_ label: UILabel, content: String) {
      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: TextStyles.h1.byAdding(
          .color(Palette.grayDark)
        )
      )
    }

    static func label(_ label: UILabel, text: String) {
      let textStyle = TextStyles.p.byAdding(
        .color(Palette.grayNormal),
        .alignment(.left),
        .xmlRules([
          .style("i", TextStyles.i)
        ])
      )
      TempuraStyles.styleStandardLabel(
        label,
        content: text,
        style: textStyle
      )
    }

    static func contactButton(_ button: TextButton, content: String) {
      let textStyle = TextStyles.pLink.byAdding(
        .color(Palette.primary),
        .underline(.single, Palette.primary)
      )

      button.contentHorizontalAlignment = .left
      button.attributedTitle = content.styled(with: textStyle)
    }

    static func subTitle(_ label: UILabel, text: String) {
      let textStyle = TextStyles.h3.byAdding(
        .color(Palette.grayDark),
        .alignment(.center)
      )
      TempuraStyles.styleStandardLabel(
        label,
        content: text,
        style: textStyle
      )
    }

    static func value(_ label: UILabel, text: String) {
      let textStyle = TextStyles.pSemibold.byAdding(
        .color(Palette.grayDark),
        .alignment(.left)
      )
      TempuraStyles.styleStandardLabel(
        label,
        content: text,
        style: textStyle
      )
    }
  }
}

public enum TestType: String {
  case molecularTest = "LP6464-4"
  case quickTest = "LP217198-3"

  func getDescription() -> String {
    switch self {
    case .molecularTest:
      return L10n.HomeView.GreenCertificate.Detail.TestType.molecular
    case .quickTest:
      return L10n.HomeView.GreenCertificate.Detail.TestType.quick
    }
  }

  func gedValidUntilValue() -> String {
    let lan = Locale.current.languageCode ?? "en"
    let validUntilValueMolecularTest:String? = ConfigurationState.state[lan]?["molecular_test"]
    let validUntilValueQuickTest:String? = ConfigurationState.state[lan]?["rapid_test"]

    switch self {
    case .molecularTest:
        return validUntilValueMolecularTest?.description ?? L10n.HomeView.GreenCertificate.Detail.Label.Test.molecularTest
    case .quickTest:
      return validUntilValueQuickTest?.description ?? L10n.HomeView.GreenCertificate.Detail.Label.Test.rapidTest
    }
  }
}

public enum TestResult: String {
  case negative = "260415000"
  case positive = "260373001"

  func getDescription() -> String {
    switch self {
    case .positive:
      return L10n.HomeView.GreenCertificate.Detail.TestResult.positive
    case .negative:
      return L10n.HomeView.GreenCertificate.Detail.TestResult.negative
    }
  }
}
