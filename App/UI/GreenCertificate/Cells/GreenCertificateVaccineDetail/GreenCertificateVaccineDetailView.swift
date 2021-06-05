// GreenCertificateVaccineDetailView.swift
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

struct GreenCertificateVaccineDetailVM: ViewModelWithLocalState {
    
    let greenCertificate: GreenCertificate
}

extension GreenCertificateVaccineDetailVM {
    init?(state: AppState?, localState : GreenCertificateVaccineDetailLS) {
        guard let _ = state else {
            return nil
        }

        self.greenCertificate = localState.greenCertificate
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
    
    // Vaccine fields
    private var diseaseVaccineLabel = UILabel()
    private var diseaseVaccine = UILabel()
    private var vaccineTypeLabel = UILabel()
    private var vaccineType = UILabel()
    private var vaccineNameLabel = UILabel()
    private var vaccineName = UILabel()
    private var vaccineProducerLabel = UILabel()
    private var vaccineProducer = UILabel()
    private var numberOfDosesVaccineLabel = UILabel()
    private var numberOfDosesVaccine = UILabel()
    private var dateLastAdministrationVaccineLabel = UILabel()
    private var dateLastAdministrationVaccine = UILabel()
    private var vaccinationCuntryLabel = UILabel()
    private var vaccinationCuntry = UILabel()
    private var certificateAuthorityVaccineLabel = UILabel()
    private var certificateAuthorityVaccine = UILabel()
    
    private var paragraph = UILabel()
    private var contactButton = TextButton()

    
    var didTapBack: Interaction?
    var didTapContact: CustomInteraction<String>?
    
    // MARK: - Setup

    func setup() {
        addSubview(backgroundGradientView)
        addSubview(scrollView)
        addSubview(title)
        addSubview(closeButton)
        
        addSubview(diseaseVaccineLabel)
        scrollView.addSubview(diseaseVaccineLabel)
        addSubview(diseaseVaccine)
        scrollView.addSubview(diseaseVaccine)
        addSubview(vaccineTypeLabel)
        scrollView.addSubview(vaccineTypeLabel)
        addSubview(vaccineType)
        scrollView.addSubview(vaccineType)
        addSubview(vaccineNameLabel)
        scrollView.addSubview(vaccineNameLabel)
        addSubview(vaccineName)
        scrollView.addSubview(vaccineName)
        addSubview(vaccineProducerLabel)
        scrollView.addSubview(vaccineProducerLabel)
        addSubview(vaccineProducer)
        scrollView.addSubview(vaccineProducer)
        addSubview(numberOfDosesVaccineLabel)
        scrollView.addSubview(numberOfDosesVaccineLabel)
        addSubview(numberOfDosesVaccine)
        scrollView.addSubview(numberOfDosesVaccine)
        addSubview(dateLastAdministrationVaccineLabel)
        scrollView.addSubview(dateLastAdministrationVaccineLabel)
        addSubview(dateLastAdministrationVaccine)
        scrollView.addSubview(dateLastAdministrationVaccine)
        addSubview(vaccinationCuntryLabel)
        scrollView.addSubview(vaccinationCuntryLabel)
        addSubview(vaccinationCuntry)
        scrollView.addSubview(vaccinationCuntry)
        addSubview(certificateAuthorityVaccineLabel)
        scrollView.addSubview(certificateAuthorityVaccineLabel)
        addSubview(certificateAuthorityVaccine)
        scrollView.addSubview(certificateAuthorityVaccine)
        
        scrollView.addSubview(paragraph)
        addSubview(contactButton)
        scrollView.addSubview(contactButton)
        

        closeButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapBack?()
        }
        contactButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapContact?(L10n.HomeView.GreenCertificate.Detail.url)
        }

    }

    // MARK: - Style

    func style() {
        Self.Style.background(self)
        Self.Style.backgroundGradient(backgroundGradientView)

        Self.Style.scrollView(scrollView)
        Self.Style.headerTitle(title, content: L10n.HomeView.GreenCertificate.Detail.title)
    
        //Vaccine fields
        Self.Style.label(diseaseVaccineLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.disease)
        Self.Style.label(vaccineTypeLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineType)
        Self.Style.label(vaccineNameLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineName)
        Self.Style.label(vaccineProducerLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineProducer)
        Self.Style.label(numberOfDosesVaccineLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.numberOfDoses)
        Self.Style.label(dateLastAdministrationVaccineLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.dateLastAdministration)
        Self.Style.label(vaccinationCuntryLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccinationCuntry)
        Self.Style.label(certificateAuthorityVaccineLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.certificateAuthority)

        
        Self.Style.closeButton(self.closeButton)

    }

    // MARK: - Update

    func update(oldModel _: VM?) {
        guard let model = self.model else {
            return
        }
        
        if let detailVaccineCertificate = model.greenCertificate.detailVaccineCertificate {
            Self.Style.value(diseaseVaccine, text: detailVaccineCertificate.disease)
            Self.Style.value(vaccineType, text: detailVaccineCertificate.vaccineType)
            Self.Style.value(vaccineName, text: detailVaccineCertificate.vaccineName)
            Self.Style.value(vaccineProducer, text: detailVaccineCertificate.vaccineProducer)
            Self.Style.value(numberOfDosesVaccine, text: detailVaccineCertificate.numberOfDoses)
            Self.Style.value(dateLastAdministrationVaccine, text: detailVaccineCertificate.dateLastAdministration)
            Self.Style.value(vaccinationCuntry, text: detailVaccineCertificate.vaccinationCuntry)
            Self.Style.value(certificateAuthorityVaccine, text: detailVaccineCertificate.certificateAuthority)
        }
        Self.Style.label(paragraph, text: L10n.HomeView.GreenCertificate.Detail.paragraph)
        Self.Style.contactButton(self.contactButton, content: L10n.HomeView.GreenCertificate.Detail.url)


    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundGradientView.pin.all()
        
        closeButton.pin
          .top(30)
          .right(28)
          .sizeToFit()
        
        title.pin
          .top(60)
          .horizontally(30)
          .sizeToFit()
     
        diseaseVaccineLabel.pin
          .minHeight(25)
          .below(of: title)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        diseaseVaccine.pin
          .minHeight(25)
          .below(of: diseaseVaccineLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        vaccineTypeLabel.pin
          .minHeight(25)
          .below(of: diseaseVaccine)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        vaccineType.pin
          .minHeight(25)
          .below(of: vaccineTypeLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        vaccineNameLabel.pin
          .minHeight(25)
          .below(of: vaccineType)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        vaccineName.pin
          .minHeight(25)
          .below(of: vaccineNameLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        vaccineProducerLabel.pin
          .minHeight(25)
          .below(of: vaccineName)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        vaccineProducer.pin
          .minHeight(25)
          .below(of: vaccineProducerLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        numberOfDosesVaccineLabel.pin
          .minHeight(25)
          .below(of: vaccineProducer)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        numberOfDosesVaccine.pin
          .minHeight(25)
          .below(of: numberOfDosesVaccineLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        dateLastAdministrationVaccineLabel.pin
          .minHeight(25)
          .below(of: numberOfDosesVaccine)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        dateLastAdministrationVaccine.pin
          .minHeight(25)
          .below(of: dateLastAdministrationVaccineLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        vaccinationCuntryLabel.pin
          .minHeight(25)
          .below(of: dateLastAdministrationVaccine)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        vaccinationCuntry.pin
          .minHeight(25)
          .below(of: vaccinationCuntryLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        certificateAuthorityVaccineLabel.pin
          .minHeight(25)
          .below(of: vaccinationCuntry)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        certificateAuthorityVaccine.pin
          .minHeight(25)
          .below(of: certificateAuthorityVaccineLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
     
        paragraph.pin
          .minHeight(25)
          .below(of: certificateAuthorityVaccine)
          .marginTop(15)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        contactButton.pin
          .minHeight(25)
          .below(of: paragraph)
          .marginTop(15)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        scrollView.pin
            .horizontally()
            .below(of: title)
            .marginTop(5)
            .bottom(universalSafeAreaInsets.bottom)

        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: contactButton.frame.maxY)
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
                .alignment(.left)
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
    }
}
