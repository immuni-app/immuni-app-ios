// GreenCertificateRecoveryDetailView.swift
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

struct GreenCertificateRecoveryDetailVM: ViewModelWithLocalState {
    
    let greenCertificate: GreenCertificate
}

struct ConfigurationStateRecovery {
  static var state = ["": ["": ""]]
}

extension GreenCertificateRecoveryDetailVM {
    init?(state: AppState?, localState : GreenCertificateRecoveryDetailLS) {
        guard let state = state else {
            return nil
        }
        self.greenCertificate = localState.greenCertificate
        ConfigurationStateRecovery.state = state.configuration.eudccExpiration
    }
}
// MARK: - View

class GreenCertificateRecoveryDetailView: UIView, ViewControllerModellableView {
    typealias VM = GreenCertificateRecoveryDetailVM

    private static let horizontalSpacing: CGFloat = 30.0
    static let orderRightMargin: CGFloat = UIDevice.getByScreen(normal: 70, narrow: 50)
    static let labelLeftMargin: CGFloat = 25

    private let backgroundGradientView = GradientView()
    private let title = UILabel()
    let scrollView = UIScrollView()
    private var closeButton = ImageButton()
    
    private var certificateTypeLabel = UILabel()

    private var diseaseRecoveryLabel = UILabel()
    private var diseaseRecoveryLabelEn = UILabel()
    private var diseaseRecovery = UILabel()
    private var dateFirstTestResultLabel = UILabel()
    private var dateFirstTestResultLabelEn = UILabel()
    private var dateFirstTestResult = UILabel()
    private var countryOfTestRecoveryLabel = UILabel()
    private var countryOfTestRecoveryLabelEn = UILabel()
    private var countryOfTestRecovery = UILabel()
    private var certificateIssuerRecoveryLabel = UILabel()
    private var certificateIssuerRecoveryLabelEn = UILabel()
    private var certificateIssuerRecovery = UILabel()
    private var certificateValidFromLabel = UILabel()
    private var certificateValidFromLabelEn = UILabel()
    private var certificateValidFrom = UILabel()
    private var certificateValidUntilLabel = UILabel()
    private var certificateValidUntilLabelEn = UILabel()
    private var certificateValidUntil = UILabel()
    
    private var healingCertificateLabelEn = UILabel()
    private var healingCertificateLabel = UILabel()
    
    private var healingCertificate = UILabel()
    
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
        
        addSubview(certificateTypeLabel)
        scrollView.addSubview(certificateTypeLabel)
        
        addSubview(diseaseRecoveryLabel)
        scrollView.addSubview(diseaseRecoveryLabel)
        addSubview(diseaseRecoveryLabelEn)
        scrollView.addSubview(diseaseRecoveryLabelEn)
        addSubview(diseaseRecovery)
        scrollView.addSubview(diseaseRecovery)
        addSubview(dateFirstTestResultLabel)
        scrollView.addSubview(dateFirstTestResultLabel)
        addSubview(dateFirstTestResultLabelEn)
        scrollView.addSubview(dateFirstTestResultLabelEn)
        addSubview(dateFirstTestResult)
        scrollView.addSubview(dateFirstTestResult)
        addSubview(countryOfTestRecoveryLabel)
        scrollView.addSubview(countryOfTestRecoveryLabel)
        addSubview(countryOfTestRecoveryLabelEn)
        scrollView.addSubview(countryOfTestRecoveryLabelEn)
        addSubview(countryOfTestRecovery)
        scrollView.addSubview(countryOfTestRecovery)
        addSubview(certificateIssuerRecoveryLabel)
        scrollView.addSubview(certificateIssuerRecoveryLabel)
        addSubview(certificateIssuerRecoveryLabelEn)
        scrollView.addSubview(certificateIssuerRecoveryLabelEn)
        addSubview(certificateIssuerRecovery)
        scrollView.addSubview(certificateIssuerRecovery)
        addSubview(certificateValidFromLabel)
        scrollView.addSubview(certificateValidFromLabel)
        addSubview(certificateValidFromLabelEn)
        scrollView.addSubview(certificateValidFromLabelEn)
        addSubview(certificateValidFrom)
        scrollView.addSubview(certificateValidFrom)
        addSubview(certificateValidUntilLabel)
        scrollView.addSubview(certificateValidUntilLabel)
        addSubview(certificateValidUntilLabelEn)
        scrollView.addSubview(certificateValidUntilLabelEn)
        
        addSubview(certificateValidUntil)
        scrollView.addSubview(certificateValidUntil)
        
        addSubview(healingCertificateLabelEn)
        scrollView.addSubview(healingCertificateLabelEn)
        addSubview(healingCertificateLabel)
        scrollView.addSubview(healingCertificateLabel)
        addSubview(healingCertificate)
        scrollView.addSubview(healingCertificate)
        
        addSubview(contactButton)
        scrollView.addSubview(contactButton)
        
        scrollView.addSubview(paragraph)

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
        Self.Style.subTitle(certificateTypeLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Recovery.certificateType)
        
        Self.Style.label(diseaseRecoveryLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Recovery.disease)
        Self.Style.label(dateFirstTestResultLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Recovery.dateFirstTestResult)
        Self.Style.label(countryOfTestRecoveryLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Recovery.countryOfTest)
        Self.Style.label(certificateIssuerRecoveryLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Recovery.certificateIssuer)
        Self.Style.label(certificateValidFromLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Recovery.certificateValidFrom)
        Self.Style.label(certificateValidUntilLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Recovery.certificateValidUntil)
        
        Self.Style.label(diseaseRecoveryLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Recovery.diseaseEn)
        Self.Style.label(dateFirstTestResultLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Recovery.dateFirstTestResultEn)
        Self.Style.label(countryOfTestRecoveryLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Recovery.countryOfTestEn)
        Self.Style.label(certificateIssuerRecoveryLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Recovery.certificateIssuerEn)
        Self.Style.label(certificateValidFromLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Recovery.certificateValidFromEn)
        Self.Style.label(certificateValidUntilLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Recovery.certificateValidUntilEn)
        
        Self.Style.label(self.healingCertificateLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.validUntil)
        Self.Style.label(self.healingCertificateLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.validUntilEn)
    
        Self.Style.closeButton(self.closeButton)

    }

    // MARK: - Update

    func update(oldModel _: VM?) {
        guard let model = self.model else {
            return
        }
        
        if let detailRecoveryCertificate = model.greenCertificate.detailRecoveryCertificate {
            Self.Style.value(diseaseRecovery, text: detailRecoveryCertificate.disease)
            
            Self.Style.value(dateFirstTestResult, text: detailRecoveryCertificate.dateFirstTestResult.isEmpty ? "---" : detailRecoveryCertificate.dateFirstTestResult)
            
            Self.Style.value(countryOfTestRecovery, text: detailRecoveryCertificate.countryOfTest.isEmpty ? "---" : detailRecoveryCertificate.countryOfTest)
            
            Self.Style.value(certificateIssuerRecovery, text: detailRecoveryCertificate.certificateIssuer.isEmpty ? "---" : detailRecoveryCertificate.certificateIssuer)
            
            Self.Style.value(certificateValidFrom, text:
                                detailRecoveryCertificate.certificateValidFrom.isEmpty ? "---" : detailRecoveryCertificate.certificateValidFrom)
            
            Self.Style.value(certificateValidUntil, text: detailRecoveryCertificate.certificateValidUntil.isEmpty ? "---" : detailRecoveryCertificate.certificateValidUntil)

            Self.Style.value(healingCertificate, text: self.gedValidUntilValue(dgcType: model.greenCertificate.dgcType))

        }
        
        Self.Style.label(paragraph, text: L10n.HomeView.GreenCertificate.Detail.paragraph)
        Self.Style.contactButton(self.contactButton, content: L10n.HomeView.GreenCertificate.Detail.url)


    }
    func gedValidUntilValue(dgcType: String?) -> String {
      let lan = Locale.current.languageCode ?? "en"
    
      switch dgcType {
        case "cbis":
          let validUntilValueCbis:String? = ConfigurationStateRecovery.state[lan]?["cbis"]
          return validUntilValueCbis?.description ?? L10n.HomeView.GreenCertificate.Detail.Label.Recovery.cbis
        default:
          let validUntilValueRecovery:String? = ConfigurationStateRecovery.state[lan]?["healing_certificate"]
          return validUntilValueRecovery?.description ?? L10n.HomeView.GreenCertificate.Detail.Label.Recovery.healingCertificate
        }
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
        
        certificateTypeLabel.pin
          .minHeight(25)
          .below(of: title)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        diseaseRecoveryLabelEn.pin
          .minHeight(25)
          .below(of: certificateTypeLabel)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        diseaseRecoveryLabel.pin
          .minHeight(25)
          .below(of: diseaseRecoveryLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        diseaseRecovery.pin
          .minHeight(25)
          .below(of: diseaseRecoveryLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        dateFirstTestResultLabelEn.pin
          .minHeight(25)
          .below(of: diseaseRecovery)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        dateFirstTestResultLabel.pin
          .minHeight(25)
          .below(of: dateFirstTestResultLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        dateFirstTestResult.pin
          .minHeight(25)
          .below(of: dateFirstTestResultLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        healingCertificateLabelEn.pin
          .minHeight(25)
          .below(of: dateFirstTestResult)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        healingCertificateLabel.pin
          .minHeight(25)
          .below(of: healingCertificateLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        healingCertificate.pin
          .minHeight(25)
          .below(of: healingCertificateLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        countryOfTestRecoveryLabelEn.pin
          .minHeight(25)
          .below(of: healingCertificate)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        countryOfTestRecoveryLabel.pin
          .minHeight(25)
          .below(of: countryOfTestRecoveryLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        countryOfTestRecovery.pin
          .minHeight(25)
          .below(of: countryOfTestRecoveryLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        certificateIssuerRecoveryLabelEn.pin
          .minHeight(25)
          .below(of: countryOfTestRecovery)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        certificateIssuerRecoveryLabel.pin
          .minHeight(25)
          .below(of: certificateIssuerRecoveryLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        certificateIssuerRecovery.pin
          .minHeight(25)
          .below(of: certificateIssuerRecoveryLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        certificateValidFromLabelEn.pin
          .minHeight(25)
          .below(of: certificateIssuerRecovery)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        certificateValidFromLabel.pin
          .minHeight(25)
          .below(of: certificateValidFromLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        certificateValidFrom.pin
          .minHeight(25)
          .below(of: certificateValidFromLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        certificateValidUntilLabelEn.pin
          .minHeight(25)
          .below(of: certificateValidFrom)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        certificateValidUntilLabel.pin
          .minHeight(25)
          .below(of: certificateValidUntilLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        certificateValidUntil.pin
          .minHeight(25)
          .below(of: certificateValidUntilLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
    
        paragraph.pin
          .minHeight(25)
          .below(of: certificateValidUntil)
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
            .bottom(self.safeAreaInsets.bottom)

        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: contactButton.frame.maxY)
    }
}

// MARK: - Style

private extension GreenCertificateRecoveryDetailView {
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
