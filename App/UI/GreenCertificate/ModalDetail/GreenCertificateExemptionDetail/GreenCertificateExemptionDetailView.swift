// GreenCertificateExemptionDetailView.swift
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

struct GreenCertificateExemptionDetailVM: ViewModelWithLocalState {
    let greenCertificate: GreenCertificate
}

struct ConfigurationStateExemption {
    static var state = ["": ["": ""]]
}

extension GreenCertificateExemptionDetailVM {
    init?(state: AppState?, localState: GreenCertificateExemptionDetailLS) {
        guard let _ = state else {
            return nil
        }
        
        self.greenCertificate = localState.greenCertificate
        ConfigurationStateExemption.state = (state?.configuration.eudccExpiration)!
    }
}

// MARK: - View

class GreenCertificateExemptionDetailView: UIView, ViewControllerModellableView {
    typealias VM = GreenCertificateExemptionDetailVM
    
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
    
    private var diseaseExemptionLabel = UILabel()
    private var diseaseExemptionLabelEn = UILabel()
    private var diseaseExemption = UILabel()
    
    private var fiscalCodeDoctorLabel = UILabel()
    private var fiscalCodeDoctorLabelEn = UILabel()
    private var fiscalCodeDoctor = UILabel()
    private var certificateValidUntilLabel = UILabel()
    private var certificateValidUntilLabelEn = UILabel()
    private var certificateValidUntil = UILabel()
    private var vaccinationCountryLabel = UILabel()
    private var vaccinationCountryLabelEn = UILabel()
    private var vaccinationCountry = UILabel()
    private var cuLabel = UILabel()
    private var cuLabelEn = UILabel()
    private var cu = UILabel()
    private var certificateAuthorityLabel = UILabel()
    private var certificateAuthorityLabelEn = UILabel()
    private var certificateAuthority = UILabel()
    private var tgLabel = UILabel()
    private var tgLabelEn = UILabel()
    private var tg = UILabel()
    private var certificateValidFromLabel = UILabel()
    private var certificateValidFromLabelEn = UILabel()
    private var certificateValidFrom = UILabel()
    
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
        
        addSubview(self.diseaseExemptionLabel)
        self.scrollView.addSubview(self.diseaseExemptionLabel)
        addSubview(self.diseaseExemptionLabelEn)
        self.scrollView.addSubview(self.diseaseExemptionLabelEn)
        addSubview(self.diseaseExemption)
        self.scrollView.addSubview(self.diseaseExemption)
               
        addSubview(self.fiscalCodeDoctorLabel)
        self.scrollView.addSubview(self.fiscalCodeDoctorLabel)
        addSubview(self.fiscalCodeDoctorLabelEn)
        self.scrollView.addSubview(self.fiscalCodeDoctorLabelEn)
        addSubview(self.fiscalCodeDoctor)
        self.scrollView.addSubview(self.fiscalCodeDoctor)

        addSubview(self.certificateValidUntilLabel)
        self.scrollView.addSubview(self.certificateValidUntilLabel)
        addSubview(self.certificateValidUntilLabelEn)
        self.scrollView.addSubview(self.certificateValidUntilLabelEn)
        addSubview(self.certificateValidUntil)
        self.scrollView.addSubview(self.certificateValidUntil)
       
        addSubview(self.vaccinationCountryLabel)
        self.scrollView.addSubview(self.vaccinationCountryLabel)
        addSubview(self.vaccinationCountryLabelEn)
        self.scrollView.addSubview(self.vaccinationCountryLabelEn)
        addSubview(self.vaccinationCountry)
        self.scrollView.addSubview(self.vaccinationCountry)
        
        addSubview(self.cuLabel)
        self.scrollView.addSubview(self.cuLabel)
        addSubview(self.cuLabelEn)
        self.scrollView.addSubview(self.cuLabelEn)
        addSubview(self.cu)
        self.scrollView.addSubview(self.cu)
       
        addSubview(self.certificateAuthorityLabel)
        self.scrollView.addSubview(self.certificateAuthorityLabel)
        addSubview(self.certificateAuthorityLabelEn)
        self.scrollView.addSubview(self.certificateAuthorityLabelEn)
        addSubview(self.certificateAuthority)
        self.scrollView.addSubview(self.certificateAuthority)
       
        addSubview(self.tgLabel)
        self.scrollView.addSubview(self.tgLabel)
        addSubview(self.tgLabelEn)
        self.scrollView.addSubview(self.tgLabelEn)
        addSubview(self.tg)
        self.scrollView.addSubview(self.tg)
      
        addSubview(self.certificateValidFromLabel)
        self.scrollView.addSubview(self.certificateValidFromLabel)
        addSubview(self.certificateValidFromLabelEn)
        self.scrollView.addSubview(self.certificateValidFromLabelEn)
        addSubview(self.certificateValidFrom)
        self.scrollView.addSubview(self.certificateValidFrom)
        
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
        
        Self.Style.subTitle(self.certificateTypeLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Exemption.certificateType)
        
        Self.Style.label(self.validUntilLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.validUntilEn)
        Self.Style.label(self.validUntilLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.validUntil)
        
        Self.Style.label(self.diseaseExemptionLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.disease)
        
        Self.Style.label(self.fiscalCodeDoctorLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineType)
        Self.Style.label(self.certificateValidUntilLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineName)
        Self.Style.label(self.vaccinationCountryLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineProducer)
        Self.Style.label(self.cuLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.numberOfDoses)
        Self.Style.label(
            self.certificateAuthorityLabel,
            text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.dateLastAdministration
        )
        Self.Style.label(self.tgLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccinationCuntry)
        Self.Style.label(
            self.certificateValidFromLabel,
            text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.certificateAuthority
        )
        
        Self.Style.label(self.diseaseExemptionLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.diseaseEn)
        Self.Style.label(self.fiscalCodeDoctorLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineTypeEn)
        Self.Style.label(self.certificateValidUntilLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineNameEn)
        Self.Style.label(self.vaccinationCountryLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccineProducerEn)
        Self.Style.label(
            self.cuLabelEn,
            text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.numberOfDosesEn
        )
        Self.Style.label(
            self.certificateAuthorityLabelEn,
            text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.dateLastAdministrationEn
        )
        Self.Style.label(
            self.tgLabelEn,
            text: L10n.HomeView.GreenCertificate.Detail.Label.Vaccine.vaccinationCuntryEn
        )
        Self.Style.label(
            self.certificateValidFromLabelEn,
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
        let validUntilCompleteVaccine = ConfigurationStateExemption.state[lan]!["vaccine_fully_completed"]
        let validUntilnotCompleteVaccine = ConfigurationStateExemption.state[lan]!["vaccine_first_dose"]
        
        if let detailExemptionCertificate = model.greenCertificate.detailExemptionCertificate {
            Self.Style.value(self.diseaseExemption, text: detailExemptionCertificate.disease)
            
            Self.Style.value(
                self.fiscalCodeDoctor,
                text: detailExemptionCertificate.fiscalCodeDoctor.isEmpty ? "---" : detailExemptionCertificate
                    .fiscalCodeDoctor
            )
            Self.Style.value(
                self.certificateValidUntil,
                text: detailExemptionCertificate.certificateValidUntil.isEmpty ? "---" : detailExemptionCertificate
                    .certificateValidUntil
            )
            Self.Style.value(
                self.vaccinationCountry,
                text: detailExemptionCertificate.vaccinationCuntry.isEmpty ? "---" : detailExemptionCertificate
                    .vaccinationCuntry
            )
            Self.Style.value(
                self.cu,
                text: detailExemptionCertificate.cu.isEmpty ? "---" : detailExemptionCertificate
                    .cu
            )
            Self.Style.value(
                self.certificateAuthority,
                text: detailExemptionCertificate.certificateAuthority.isEmpty ? "---" : detailExemptionCertificate
                    .certificateAuthority
            )
            Self.Style.value(
                self.tg,
                text: detailExemptionCertificate.tg.isEmpty ? "---" : detailExemptionCertificate
                    .tg
            )
            Self.Style.value(
                self.certificateValidFrom,
                text: detailExemptionCertificate.certificateValidFrom.isEmpty ? "---" : detailExemptionCertificate
                    .certificateValidFrom
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
        
        self.diseaseExemptionLabelEn.pin
            .minHeight(25)
            .below(of: self.certificateTypeLabel)
            .marginTop(30)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.diseaseExemptionLabel.pin
            .minHeight(25)
            .below(of: self.diseaseExemptionLabelEn)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.diseaseExemption.pin
            .minHeight(25)
            .below(of: self.diseaseExemptionLabel)
            .marginTop(5)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.fiscalCodeDoctorLabelEn.pin
            .minHeight(25)
            .below(of: self.diseaseExemption)
            .marginTop(30)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.fiscalCodeDoctorLabel.pin
            .minHeight(25)
            .below(of: self.fiscalCodeDoctorLabelEn)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.fiscalCodeDoctor.pin
            .minHeight(25)
            .below(of: self.fiscalCodeDoctorLabel)
            .marginTop(5)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.certificateValidUntilLabelEn.pin
            .minHeight(25)
            .below(of: self.fiscalCodeDoctor)
            .marginTop(30)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.certificateValidUntilLabel.pin
            .minHeight(25)
            .below(of: self.certificateValidUntilLabelEn)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.certificateValidUntil.pin
            .minHeight(25)
            .below(of: self.certificateValidUntilLabel)
            .marginTop(5)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.vaccinationCountryLabelEn.pin
            .minHeight(25)
            .below(of: self.certificateValidUntil)
            .marginTop(30)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.vaccinationCountryLabel.pin
            .minHeight(25)
            .below(of: self.vaccinationCountryLabelEn)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.vaccinationCountry.pin
            .minHeight(25)
            .below(of: self.vaccinationCountryLabel)
            .marginTop(5)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.cuLabelEn.pin
            .minHeight(25)
            .below(of: self.vaccinationCountry)
            .marginTop(30)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.cuLabel.pin
            .minHeight(25)
            .below(of: self.cuLabelEn)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.cu.pin
            .minHeight(25)
            .below(of: self.cuLabel)
            .marginTop(5)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.certificateAuthorityLabelEn.pin
            .minHeight(25)
            .below(of: self.cu)
            .marginTop(30)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.certificateAuthorityLabel.pin
            .minHeight(25)
            .below(of: self.certificateAuthorityLabelEn)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.certificateAuthority.pin
            .minHeight(25)
            .below(of: self.certificateAuthorityLabel)
            .marginTop(5)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.tgLabelEn.pin
            .minHeight(25)
            .below(of: self.certificateAuthority)
            .marginTop(30)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.tgLabel.pin
            .minHeight(25)
            .below(of: self.tgLabelEn)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.tg.pin
            .minHeight(25)
            .below(of: self.tgLabel)
            .marginTop(5)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.certificateValidFromLabelEn.pin
            .minHeight(25)
            .below(of: self.tg)
            .marginTop(30)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.certificateValidFromLabel.pin
            .minHeight(25)
            .below(of: self.certificateValidFromLabelEn)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.certificateValidFrom.pin
            .minHeight(25)
            .below(of: self.certificateValidFromLabel)
            .marginTop(5)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.paragraph.pin
            .minHeight(25)
            .below(of: self.certificateValidFrom)
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

private extension GreenCertificateExemptionDetailView {
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
