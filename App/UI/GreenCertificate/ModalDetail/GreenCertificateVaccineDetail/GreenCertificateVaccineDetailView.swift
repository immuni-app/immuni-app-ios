// GreenCertificateVaccineDetailView.swift
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

struct GreenCertificateVaccineDetailVM: ViewModelWithLocalState {
  let greenCertificate: GreenCertificate
}

struct ConfigurationStateVaccine {
  static var state = ["": ["": ""]]
}

extension GreenCertificateVaccineDetailVM {
  init?(state: AppState?, localState: GreenCertificateVaccineDetailLS) {
    guard let _ = state else {
      return nil
    }

    self.greenCertificate = localState.greenCertificate
    ConfigurationStateVaccine.state = (state?.configuration.eudccExpiration)!
  }
}

// MARK: - View

class GreenCertificateVaccineDetailView: UIView, ViewControllerModellableView {
  typealias VM = GreenCertificateVaccineDetailVM

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

  private var diseaseVaccineLabel = UILabel()
  private var diseaseVaccineLabelEn = UILabel()
  private var diseaseVaccine = UILabel()
  private var vaccineTypeLabel = UILabel()
  private var vaccineTypeLabelEn = UILabel()
  private var vaccineType = UILabel()
  private var vaccineNameLabel = UILabel()
  private var vaccineNameLabelEn = UILabel()
  private var vaccineName = UILabel()
  private var vaccineProducerLabel = UILabel()
  private var vaccineProducerLabelEn = UILabel()
  private var vaccineProducer = UILabel()
  private var numberOfDosesVaccineLabel = UILabel()
  private var numberOfDosesVaccineLabelEn = UILabel()
  private var numberOfDosesVaccine = UILabel()
  private var dateLastAdministrationVaccineLabel = UILabel()
  private var dateLastAdministrationVaccineLabelEn = UILabel()
  private var dateLastAdministrationVaccine = UILabel()
  private var vaccinationCuntryLabel = UILabel()
  private var vaccinationCuntryLabelEn = UILabel()
  private var vaccinationCuntry = UILabel()
  private var certificateAuthorityVaccineLabel = UILabel()
  private var certificateAuthorityVaccineLabelEn = UILabel()
  private var certificateAuthorityVaccine = UILabel()

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

    addSubview(self.certificateTypeLabel)
    self.scrollView.addSubview(self.certificateTypeLabel)
    addSubview(self.validUntilLabel)
    self.scrollView.addSubview(self.validUntilLabel)
    addSubview(self.validUntilLabelEn)
    self.scrollView.addSubview(self.validUntilLabelEn)
    addSubview(self.validUntil)
    self.scrollView.addSubview(self.validUntil)

    addSubview(self.diseaseVaccineLabel)
    self.scrollView.addSubview(self.diseaseVaccineLabel)
    addSubview(self.diseaseVaccineLabelEn)
    self.scrollView.addSubview(self.diseaseVaccineLabelEn)

    addSubview(self.diseaseVaccine)
    self.scrollView.addSubview(self.diseaseVaccine)
    addSubview(self.vaccineTypeLabel)
    self.scrollView.addSubview(self.vaccineTypeLabel)
    addSubview(self.vaccineTypeLabelEn)
    self.scrollView.addSubview(self.vaccineTypeLabelEn)

    addSubview(self.vaccineType)
    self.scrollView.addSubview(self.vaccineType)

    addSubview(self.vaccineNameLabel)
    self.scrollView.addSubview(self.vaccineNameLabel)
    addSubview(self.vaccineNameLabelEn)
    self.scrollView.addSubview(self.vaccineNameLabelEn)

    addSubview(self.vaccineName)
    self.scrollView.addSubview(self.vaccineName)
    addSubview(self.vaccineProducerLabel)
    self.scrollView.addSubview(self.vaccineProducerLabel)
    addSubview(self.vaccineProducerLabelEn)
    self.scrollView.addSubview(self.vaccineProducerLabelEn)

    addSubview(self.vaccineProducer)
    self.scrollView.addSubview(self.vaccineProducer)
    addSubview(self.numberOfDosesVaccineLabel)
    self.scrollView.addSubview(self.numberOfDosesVaccineLabel)
    addSubview(self.numberOfDosesVaccineLabelEn)
    self.scrollView.addSubview(self.numberOfDosesVaccineLabelEn)

    addSubview(self.numberOfDosesVaccine)
    self.scrollView.addSubview(self.numberOfDosesVaccine)
    addSubview(self.dateLastAdministrationVaccineLabel)
    self.scrollView.addSubview(self.dateLastAdministrationVaccineLabel)
    addSubview(self.dateLastAdministrationVaccineLabelEn)
    self.scrollView.addSubview(self.dateLastAdministrationVaccineLabelEn)

    addSubview(self.dateLastAdministrationVaccine)
    self.scrollView.addSubview(self.dateLastAdministrationVaccine)
    addSubview(self.vaccinationCuntryLabel)
    self.scrollView.addSubview(self.vaccinationCuntryLabel)
    addSubview(self.vaccinationCuntryLabelEn)
    self.scrollView.addSubview(self.vaccinationCuntryLabelEn)

    addSubview(self.vaccinationCuntry)
    self.scrollView.addSubview(self.vaccinationCuntry)
    addSubview(self.certificateAuthorityVaccineLabel)
    self.scrollView.addSubview(self.certificateAuthorityVaccineLabel)
    addSubview(self.certificateAuthorityVaccineLabelEn)
    self.scrollView.addSubview(self.certificateAuthorityVaccineLabelEn)

    addSubview(self.certificateAuthorityVaccine)
    self.scrollView.addSubview(self.certificateAuthorityVaccine)

    self.scrollView.addSubview(self.paragraph)
    addSubview(self.contactButton)
    self.scrollView.addSubview(self.contactButton)

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

    Self.Style.scrollView(self.scrollView)
    Self.Style.headerTitle(self.title, content: L10n.HomeView.GreenCertificate.Detail.title)

    Self.Style.subTitle(self.certificateTypeLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.certificateType)

    Self.Style.label(self.validUntilLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.validUntilEn)
    Self.Style.label(self.validUntilLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.validUntil)
    Self.Style.label(self.diseaseVaccineLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.disease)

    Self.Style.label(self.vaccineTypeLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineType)
    Self.Style.label(self.vaccineNameLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineName)
    Self.Style.label(self.vaccineProducerLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineProducer)
    Self.Style.label(self.numberOfDosesVaccineLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.numberOfDoses)
    Self.Style.label(
      self.dateLastAdministrationVaccineLabel,
      text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.dateLastAdministration
    )
    Self.Style.label(self.vaccinationCuntryLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccinationCuntry)
    Self.Style.label(
      self.certificateAuthorityVaccineLabel,
      text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.certificateAuthority
    )

    Self.Style.label(self.diseaseVaccineLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.diseaseEn)
    Self.Style.label(self.vaccineTypeLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineTypeEn)
    Self.Style.label(self.vaccineNameLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineNameEn)
    Self.Style.label(self.vaccineProducerLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineProducerEn)
    Self.Style.label(
      self.numberOfDosesVaccineLabelEn,
      text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.numberOfDosesEn
    )
    Self.Style.label(
      self.dateLastAdministrationVaccineLabelEn,
      text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.dateLastAdministrationEn
    )
    Self.Style.label(
      self.vaccinationCuntryLabelEn,
      text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccinationCuntryEn
    )
    Self.Style.label(
      self.certificateAuthorityVaccineLabelEn,
      text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.certificateAuthorityEn
    )

    Self.Style.closeButton(self.closeButton)
  }

  // MARK: - Update

  func update(oldModel _: VM?) {
    guard let model = self.model else {
      return
    }
    let lan = Locale.current.languageCode ?? "en"
    let validUntilCompleteVaccine = ConfigurationStateVaccine.state[lan]!["vaccine_fully_completed"]
    let validUntilnotCompleteVaccine = ConfigurationStateVaccine.state[lan]!["vaccine_first_dose"]
    let validUntilBoosterVaccine = ConfigurationStateVaccine.state[lan]!["vaccine_booster"]

    if let detailVaccineCertificate = model.greenCertificate.detailVaccineCertificate {
      Self.Style.value(self.diseaseVaccine, text: detailVaccineCertificate.disease)

      if let vaccineTypeValue = VaccineType(rawValue: detailVaccineCertificate.vaccineType) {
        Self.Style.value(self.vaccineType, text: vaccineTypeValue.getDescription())
      } else {
        Self.Style.value(self.vaccineType, text: "---")
      }
      if let vaccineNameValue = VaccineName(rawValue: detailVaccineCertificate.vaccineName) {
        Self.Style.value(self.vaccineName, text: vaccineNameValue.getDescription())
      } else {
        Self.Style.value(
          self.vaccineName,
          text: detailVaccineCertificate.vaccineName != "" ? detailVaccineCertificate.vaccineName : "---"
        )
      }
      if let vaccineProducerValue = VaccineProducer(rawValue: detailVaccineCertificate.vaccineProducer) {
        Self.Style.value(self.vaccineProducer, text: vaccineProducerValue.getDescription())
      } else {
        Self.Style.value(self.vaccineProducer, text: "---")
      }

      if detailVaccineCertificate.doseNumber < detailVaccineCertificate.totalSeriesOfDoses
      {
          Self.Style.value(
            self.validUntil,
            text: validUntilnotCompleteVaccine?.description ?? L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineFirstDose
          )
      }
      else if detailVaccineCertificate.doseNumber == detailVaccineCertificate.totalSeriesOfDoses,
               detailVaccineCertificate.totalSeriesOfDoses < "3"
      {
            Self.Style.value(
                self.validUntil,
                text: validUntilCompleteVaccine?
                    .description ?? L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineFullyCompleted
                   )
                 }
      else {
          Self.Style.value(
            self.validUntil,
            text: validUntilBoosterVaccine?
              .description ?? L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineBooster
          )
      }
      Self.Style.value(
        self.numberOfDosesVaccine,
        text: "\(detailVaccineCertificate.doseNumber.isEmpty ? "-" : detailVaccineCertificate.doseNumber) \(L10n.HomeView.GreenCertificate.Detail.of) \(detailVaccineCertificate.totalSeriesOfDoses.isEmpty ? "-" : detailVaccineCertificate.totalSeriesOfDoses)"
      )

      Self.Style.value(
        self.dateLastAdministrationVaccine,
        text: detailVaccineCertificate.dateLastAdministration.isEmpty ? "---" : detailVaccineCertificate
          .dateLastAdministration
      )

      Self.Style.value(
        self.vaccinationCuntry,
        text: detailVaccineCertificate.vaccinationCuntry.isEmpty ? "---" : detailVaccineCertificate.vaccinationCuntry
      )

      Self.Style.value(
        self.certificateAuthorityVaccine,
        text:
        detailVaccineCertificate.certificateAuthority.isEmpty ? "---" : detailVaccineCertificate
          .certificateAuthority
      )
    }
    Self.Style.label(self.paragraph, text: L10n.HomeView.GreenCertificate.Detail.paragraph)
    Self.Style.contactButton(self.contactButton, content: L10n.HomeView.GreenCertificate.Detail.url)
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

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

    self.diseaseVaccineLabelEn.pin
      .minHeight(25)
      .below(of: self.certificateTypeLabel)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.diseaseVaccineLabel.pin
      .minHeight(25)
      .below(of: self.diseaseVaccineLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.diseaseVaccine.pin
      .minHeight(25)
      .below(of: self.diseaseVaccineLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.vaccineTypeLabelEn.pin
      .minHeight(25)
      .below(of: self.diseaseVaccine)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.vaccineTypeLabel.pin
      .minHeight(25)
      .below(of: self.vaccineTypeLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.vaccineType.pin
      .minHeight(25)
      .below(of: self.vaccineTypeLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.validUntilLabelEn.pin
      .minHeight(25)
      .below(of: self.vaccineType)
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

    self.vaccineNameLabelEn.pin
      .minHeight(25)
      .below(of: self.validUntil)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.vaccineNameLabel.pin
      .minHeight(25)
      .below(of: self.vaccineNameLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.vaccineName.pin
      .minHeight(25)
      .below(of: self.vaccineNameLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.vaccineProducerLabelEn.pin
      .minHeight(25)
      .below(of: self.vaccineName)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.vaccineProducerLabel.pin
      .minHeight(25)
      .below(of: self.vaccineProducerLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.vaccineProducer.pin
      .minHeight(25)
      .below(of: self.vaccineProducerLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.numberOfDosesVaccineLabelEn.pin
      .minHeight(25)
      .below(of: self.vaccineProducer)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.numberOfDosesVaccineLabel.pin
      .minHeight(25)
      .below(of: self.numberOfDosesVaccineLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.numberOfDosesVaccine.pin
      .minHeight(25)
      .below(of: self.numberOfDosesVaccineLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.dateLastAdministrationVaccineLabelEn.pin
      .minHeight(25)
      .below(of: self.numberOfDosesVaccine)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.dateLastAdministrationVaccineLabel.pin
      .minHeight(25)
      .below(of: self.dateLastAdministrationVaccineLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.dateLastAdministrationVaccine.pin
      .minHeight(25)
      .below(of: self.dateLastAdministrationVaccineLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.vaccinationCuntryLabelEn.pin
      .minHeight(25)
      .below(of: self.dateLastAdministrationVaccine)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.vaccinationCuntryLabel.pin
      .minHeight(25)
      .below(of: self.vaccinationCuntryLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.vaccinationCuntry.pin
      .minHeight(25)
      .below(of: self.vaccinationCuntryLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.certificateAuthorityVaccineLabelEn.pin
      .minHeight(25)
      .below(of: self.vaccinationCuntry)
      .marginTop(30)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.certificateAuthorityVaccineLabel.pin
      .minHeight(25)
      .below(of: self.certificateAuthorityVaccineLabelEn)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.certificateAuthorityVaccine.pin
      .minHeight(25)
      .below(of: self.certificateAuthorityVaccineLabel)
      .marginTop(5)
      .sizeToFit(.width)
      .horizontally(25)
      .marginLeft(10)

    self.paragraph.pin
      .minHeight(25)
      .below(of: self.certificateAuthorityVaccine)
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

private extension GreenCertificateVaccineDetailView {
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
        ),
        numberOfLines: 2
      )
    }

    static func headerTitle(_ label: UILabel, content: String) {
      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: TextStyles.h1.byAdding(
          .color(Palette.grayDark)
        ),
        numberOfLines: 2
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
  }
}

public enum VaccineType: String {
  private static let COVID19 = "covid-19 vaccines"
  private static let MRNA = "SARS-CoV-2 mRNA vaccine"
  private static let ANTIGEN = "SARS-CoV-2 antigen vaccine"

  case mRNA = "1119349007"
  case antigen = "1119305005"
  case covid19 = "J07BX03"

  func getDescription() -> String {
    switch self {
    case .covid19:
      return Self.COVID19
    case .mRNA:
      return Self.MRNA
    case .antigen:
      return Self.ANTIGEN
    }
  }
}

public enum VaccineProducer: String {
  case org100001699 = "ORG-100001699"
  case org100030215 = "ORG-100030215"
  case org100001417 = "ORG-100001417"
  case org100031184 = "ORG-100031184"
  case org100006270 = "ORG-100006270"
  case org100013793 = "ORG-100013793"
  case org100020693 = "ORG-100020693"
  case org100010771 = "ORG-100010771"
  case org100024420 = "ORG-100024420"
  case org100032020 = "ORG-100032020"
  case gamaleyaResearchInstitute = "Gamaleya-Research-Institute"
  case vectorInstitute = "Vector-Institute"
  case sinovacBiotech = "Sinovac-Biotech"
  case bharatBiotech = "Bharat-Biotech"

  func getDescription() -> String {
    switch self {
    case .org100001699:
      return "AstraZeneca AB"
    case .org100030215:
      return "Biontech Manufacturing GmbH"
    case .org100001417:
      return "Janssen-Cilag International"
    case .org100031184:
      return "Moderna Biotech Spain S.L."
    case .org100006270:
      return "Curevac AG"
    case .org100013793:
      return "CanSino Biologics"
    case .org100020693:
      return "China Sinopharm International Corp. - Beijing location"
    case .org100010771:
      return "Sinopharm Weiqida Europe Pharmaceutical s.r.o. - Prague location"
    case .org100024420:
      return "Sinopharm Zhijun (Shenzhen) Pharmaceutical Co. Ltd. - Shenzhen location"
    case .org100032020:
      return "Novavax CZ AS"
    case .gamaleyaResearchInstitute:
      return "Gamaleya Research Institute"
    case .vectorInstitute:
      return "Vector Institute"
    case .sinovacBiotech:
      return "Sinovac Biotech"
    case .bharatBiotech:
      return "Bharat Biotech"
    }
  }
}

public enum VaccineName: String {
  case org100001699 = "ORG-100001699"
  case org100030215 = "ORG-100030215"
  case org100001417 = "ORG-100001417"
  case org100031184 = "ORG-100031184"
  case org100006270 = "ORG-100006270"
  case org100013793 = "ORG-100013793"
  case org100020693 = "ORG-100020693"
  case org100010771 = "ORG-100010771"
  case org100024420 = "ORG-100024420"
  case org100032020 = "ORG-100032020"
  case gamaleyaResearchInstitute = "Gamaleya-Research-Institute"
  case vectorInstitute = "Vector-Institute"
  case sinovacBiotech = "Sinovac-Biotech"
  case bharatBiotech = "Bharat-Biotech"

  case eu1201528 = "EU/1/20/1528"
  case eu1201507 = "EU/1/20/1507"
  case eu1211529 = "EU/1/21/1529"
  case eu1201525 = "EU/1/20/1525"
  case cvnCoV
  case sputnikV = "Sputnik-V"
  case convidecia
  case epiVacCorona
  case bbibpCorV = "BBIBP-CorV"
  case inactivatedSARSCoV2VeroCell = "Inactivated-SARS-CoV-2-Vero-Cell"
  case coronaVac
  case covaxin

  func getDescription() -> String {
    switch self {
    case .org100001699:
      return "AstraZeneca AB"
    case .org100030215:
      return "Biontech Manufacturing GmbH"
    case .org100001417:
      return "Janssen-Cilag International"
    case .org100031184:
      return "Moderna Biotech Spain S.L."
    case .org100006270:
      return "Curevac AG"
    case .org100013793:
      return "CanSino Biologics"
    case .org100020693:
      return "China Sinopharm International Corp. - Beijing location"
    case .org100010771:
      return "Sinopharm Weiqida Europe Pharmaceutical s.r.o. - Prague location"
    case .org100024420:
      return "Sinopharm Zhijun (Shenzhen) Pharmaceutical Co. Ltd. - Shenzhen location"
    case .org100032020:
      return "Novavax CZ AS"
    case .gamaleyaResearchInstitute:
      return "Gamaleya Research Institute"
    case .vectorInstitute:
      return "Vector Institute"
    case .sinovacBiotech:
      return "Sinovac Biotech"
    case .bharatBiotech:
      return "Bharat Biotech"
    case .eu1201528:
      return "Comirnaty"
    case .eu1201507:
      return "COVID-19 Vaccine Moderna"
    case .eu1211529:
      return "Vaxzevria"
    case .eu1201525:
      return "COVID-19 Vaccine Janssen"
    case .cvnCoV:
      return "CVnCoV"
    case .sputnikV:
      return "Sputnik-V"
    case .convidecia:
      return "Convidecia"
    case .epiVacCorona:
      return "EpiVacCorona"
    case .bbibpCorV:
      return "BBIBP-CorV"
    case .inactivatedSARSCoV2VeroCell:
      return "Inactivated SARS-CoV-2 (Vero Cell)"
    case .coronaVac:
      return "CoronaVac"
    case .covaxin:
      return "Covaxin (also known as BBV152 A, B, C)"
    }
  }
}
