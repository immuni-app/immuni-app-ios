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
    
    private var diseaseExemptionLabel = UILabel()
    private var diseaseExemptionLabelEn = UILabel()
    private var diseaseExemption = UILabel()
    
    private var fiscalCodeDoctorLabel = UILabel()
    private var fiscalCodeDoctorLabelEn = UILabel()
    private var fiscalCodeDoctor = UILabel()
    private var certificateValidUntilLabel = UILabel()
    private var certificateValidUntilLabelEn = UILabel()
    private var certificateValidUntil = UILabel()
  
    private var cuevLabel = UILabel()
    private var cuevLabelEn = UILabel()
    private var cuev = UILabel()
    private var certificateIssuerLabel = UILabel()
    private var certificateIssuerLabelEn = UILabel()
    private var certificateIssuer = UILabel()
    private var certificateValidFromLabel = UILabel()
    private var certificateValidFromLabelEn = UILabel()
    private var certificateValidFrom = UILabel()
    
    private var paragraph = UILabel()
    private let flagImage = UIImageView()

    
    var didTapBack: Interaction?
    
    // MARK: - Setup
    
    func setup() {
        addSubview(self.backgroundGradientView)
        addSubview(self.scrollView)
        addSubview(self.title)
        addSubview(self.closeButton)
        
        
        addSubview(self.flagImage)
        self.scrollView.addSubview(self.flagImage)
        
        addSubview(self.certificateTypeLabel)
        self.scrollView.addSubview(self.certificateTypeLabel)
        
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
        
        addSubview(self.cuevLabel)
        self.scrollView.addSubview(self.cuevLabel)
        addSubview(self.cuevLabelEn)
        self.scrollView.addSubview(self.cuevLabelEn)
        addSubview(self.cuev)
        self.scrollView.addSubview(self.cuev)
       
        addSubview(self.certificateIssuerLabel)
        self.scrollView.addSubview(self.certificateIssuerLabel)
        addSubview(self.certificateIssuerLabelEn)
        self.scrollView.addSubview(self.certificateIssuerLabelEn)
        addSubview(self.certificateIssuer)
        self.scrollView.addSubview(self.certificateIssuer)
      
        addSubview(self.certificateValidFromLabel)
        self.scrollView.addSubview(self.certificateValidFromLabel)
        addSubview(self.certificateValidFromLabelEn)
        self.scrollView.addSubview(self.certificateValidFromLabelEn)
        addSubview(self.certificateValidFrom)
        self.scrollView.addSubview(self.certificateValidFrom)
        
        self.scrollView.addSubview(self.paragraph)
        
        self.closeButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapBack?()
        }

    }
    
    // MARK: - Style
    
    func style() {
        Self.Style.background(self)
        Self.Style.backgroundGradient(self.backgroundGradientView)
        
        Self.Style.scrollView(self.scrollView)
        Self.Style.headerTitle(self.title, content:  L10n.HomeView.GreenCertificate.Detail.Label.Exemption.title)
        
        Self.Style.subTitle(self.certificateTypeLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Exemption.certificateType)
        
        Self.Style.label(self.diseaseExemptionLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Exemption.disease)
        Self.Style.label(self.fiscalCodeDoctorLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Exemption.fiscalCodeDoctor)
        Self.Style.label(self.certificateValidUntilLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Exemption.validUntil)
        Self.Style.label(self.cuevLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Exemption.cuev)
        Self.Style.label(
            self.certificateIssuerLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Exemption.certificateIssuer
        )
        Self.Style.label(
            self.certificateValidFromLabel,
            text: L10n.HomeView.GreenCertificate.Detail.Label.Exemption.validFrom
        )

        Self.Style.label(self.diseaseExemptionLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Exemption.diseaseEn)
        Self.Style.label(self.fiscalCodeDoctorLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Exemption.fiscalCodeDoctorEn)
        Self.Style.label(self.certificateValidUntilLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Exemption.validUntilEn)
        Self.Style.label(
            self.cuevLabelEn,
            text: L10n.HomeView.GreenCertificate.Detail.Label.Exemption.cuevEn
        )
        Self.Style.label(
            self.certificateIssuerLabelEn,
            text: L10n.HomeView.GreenCertificate.Detail.Label.Exemption.certificateIssuerEn
        )
        Self.Style.label(
            self.certificateValidFromLabelEn,
            text: L10n.HomeView.GreenCertificate.Detail.Label.Exemption.validFromEn
        )
        Self.Style.imageContent(flagImage, image: Asset.Home.itaFlag.image)

        Self.Style.closeButton(self.closeButton)
    }
    
    // MARK: - Update
    
    func update(oldModel _: VM?) {
        guard let model = self.model else {
            return
        }
        
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
                self.cuev,
                text: detailExemptionCertificate.cuev.isEmpty ? "---" : detailExemptionCertificate
                    .cuev
            )
            Self.Style.value(
                self.certificateIssuer,
                text: detailExemptionCertificate.certificateAuthority.isEmpty ? "---" : detailExemptionCertificate
                    .certificateAuthority
            )
            Self.Style.value(
                self.certificateValidFrom,
                text: detailExemptionCertificate.certificateValidFrom.isEmpty ? "---" : detailExemptionCertificate
                    .certificateValidFrom
            )
        }
        Self.Style.label(self.paragraph, text: L10n.HomeView.GreenCertificate.ExemptionDetail.paragraph)

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
            .sizeToFit(.width)

        self.flagImage.pin
          .below(of: title)
          .marginTop(-20)
          .vCenter()
          .size(120)
          .horizontally(30)

        
        self.certificateTypeLabel.pin
            .minHeight(25)
            .below(of: self.flagImage)
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
        
        self.certificateValidFromLabelEn.pin
            .minHeight(25)
            .below(of: self.fiscalCodeDoctor)
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
        
        self.certificateValidUntilLabelEn.pin
            .minHeight(25)
            .below(of: self.certificateValidFrom)
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
        
        self.cuevLabelEn.pin
            .minHeight(25)
            .below(of: self.certificateValidUntil)
            .marginTop(30)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.cuevLabel.pin
            .minHeight(25)
            .below(of: self.cuevLabelEn)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.cuev.pin
            .minHeight(25)
            .below(of: self.cuevLabel)
            .marginTop(5)
            .sizeToFit(.width)
            .horizontally(25)
            .marginLeft(10)
        
        self.certificateIssuerLabelEn.pin
            .minHeight(25)
            .below(of: self.cuev)
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
        
        self.scrollView.pin
            .horizontally()
            .below(of: self.title)
            .marginTop(5)
            .bottom(self.safeAreaInsets.bottom)
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: self.paragraph.frame.maxY)
    }
}

// MARK: - Style

private extension GreenCertificateExemptionDetailView {
    enum Style {
        static func closeButton(_ btn: ImageButton) {
            SharedStyle.closeButton(btn)
        }
        static func imageContent(_ imageView: UIImageView, image: UIImage) {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
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
                )
            )
        }
        
        static func label(_ label: UILabel, text: String) {
            let textStyle = TextStyles.p.byAdding(
                .color(Palette.grayNormal),
                .alignment(.left),
                .xmlRules([
                    .style("i", TextStyles.i),
                    .style("b", TextStyles.pBold)

                ])
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
        
        static func subTitle(_ label: UILabel, text: String) {
            let textStyle = TextStyles.h3.byAdding(
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
