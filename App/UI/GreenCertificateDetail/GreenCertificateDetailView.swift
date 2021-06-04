// GreenCertificateDetailView.swift
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

struct GreenCertificateDetailVM: ViewModelWithLocalState {
    
    let greenCertificate: GreenCertificate
}

extension GreenCertificateDetailVM {
    init?(state: AppState?, localState : GreenCertificateDetailLS) {
        guard let _ = state else {
            return nil
        }

        self.greenCertificate = localState.greenCertificate
    }
}
// MARK: - View

class GreenCertificateDetailView: UIView, ViewControllerModellableView {
    typealias VM = GreenCertificateDetailVM

    private static let horizontalSpacing: CGFloat = 30.0
    static let orderRightMargin: CGFloat = UIDevice.getByScreen(normal: 70, narrow: 50)
    static let labelLeftMargin: CGFloat = 25

    private let backgroundGradientView = GradientView()
    private let title = UILabel()
    let scrollView = UIScrollView()
    private var closeButton = ImageButton()
    
    private var diseaseLabel = UILabel()
    private var disease = UILabel()
    
    private var vaccineTypeLabel = UILabel()
    private var vaccineType = UILabel()
    
    private var vaccineNameLabel = UILabel()
    private var vaccineName = UILabel()
    
    private var vaccineProducerLabel = UILabel()
    private var vaccineProducer = UILabel()
    
    private var numberOfDosesLabel = UILabel()
    private var numberOfDoses = UILabel()
    
    private var dateLastAdministrationLabel = UILabel()
    private var dateLastAdministration = UILabel()
    
    private var vaccinationCuntryLabel = UILabel()
    private var vaccinationCuntry = UILabel()
    
    private var certificateAuthorityLabel = UILabel()
    private var certificateAuthority = UILabel()
    
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
        
        addSubview(diseaseLabel)
        addSubview(disease)
        addSubview(vaccineTypeLabel)
        addSubview(vaccineType)
        addSubview(vaccineNameLabel)
        addSubview(vaccineName)
        addSubview(vaccineProducerLabel)
        addSubview(vaccineProducer)
        addSubview(numberOfDosesLabel)
        addSubview(numberOfDoses)
        addSubview(dateLastAdministrationLabel)
        addSubview(dateLastAdministration)
        addSubview(vaccinationCuntryLabel)
        addSubview(vaccinationCuntry)
        addSubview(certificateAuthorityLabel)
        addSubview(certificateAuthority)
        addSubview(paragraph)
        addSubview(contactButton)
        scrollView.addSubview(contactButton)
        scrollView.addSubview(diseaseLabel)
        scrollView.addSubview(disease)
        scrollView.addSubview(vaccineTypeLabel)
        scrollView.addSubview(vaccineType)
        scrollView.addSubview(vaccineNameLabel)
        scrollView.addSubview(vaccineName)
        scrollView.addSubview(vaccineProducerLabel)
        scrollView.addSubview(vaccineProducer)
        scrollView.addSubview(numberOfDosesLabel)
        scrollView.addSubview(numberOfDoses)
        scrollView.addSubview(dateLastAdministrationLabel)
        scrollView.addSubview(dateLastAdministration)
        scrollView.addSubview(vaccinationCuntryLabel)
        scrollView.addSubview(vaccinationCuntry)
        scrollView.addSubview(certificateAuthorityLabel)
        scrollView.addSubview(certificateAuthority)
        scrollView.addSubview(paragraph)

        closeButton.on(.touchUpInside) { [weak self] _ in
            self?.didTapBack?()
        }
        contactButton.on(.touchUpInside) { [weak self] _ in
//            guard let url = self?.model?.greenCertificate else { return }
//            self?.didTapContact?(url)
        }

    }

    // MARK: - Style

    func style() {
        Self.Style.background(self)
        Self.Style.backgroundGradient(backgroundGradientView)

        Self.Style.scrollView(scrollView)
        Self.Style.headerTitle(title, content: "EU Digital Covid\nCertificate")
        Self.Style.label(diseaseLabel, text: "Malattia o agente beraglio")
        Self.Style.label(vaccineTypeLabel, text: "Tipo di vaccino")
        Self.Style.label(vaccineNameLabel, text: "Denominazione del vaccino")
        Self.Style.label(vaccineProducerLabel, text: "Produttore o titolare dell'AIC del vaccino")
        Self.Style.label(numberOfDosesLabel, text: "Numero della dose effettuata/numero\ntotale dosi previste")
        Self.Style.label(dateLastAdministrationLabel, text: "Data dell'ultima somministrazione")
        Self.Style.label(vaccinationCuntryLabel, text: "Nazionein cui è stata eseguita la vaccinazione")
        Self.Style.label(certificateAuthorityLabel, text: "Ente che ha rilasciato il certificato")
        Self.Style.closeButton(self.closeButton)

    }

    // MARK: - Update

    func update(oldModel _: VM?) {
        guard let model = self.model else {
            return
        }
//        Self.Style.value(disease, text: model.greenCertificate.detailGreenCertificate.disease)
//        Self.Style.value(vaccineType, text: model.greenCertificate.detailGreenCertificate.vaccineType)
//        Self.Style.value(vaccineName, text: model.greenCertificate.detailGreenCertificate.vaccineName)
//        Self.Style.value(vaccineProducer, text: model.greenCertificate.detailGreenCertificate.vaccineProducer)
//        Self.Style.value(numberOfDoses, text: model.greenCertificate.detailGreenCertificate.numberOfDoses)
//        Self.Style.value(dateLastAdministration, text: model.greenCertificate.detailGreenCertificate.dateLastAdministration)
//        Self.Style.value(vaccinationCuntry, text: model.greenCertificate.detailGreenCertificate.vaccinationCuntry)
//        Self.Style.value(certificateAuthority, text: model.greenCertificate.detailGreenCertificate.certificateAuthority)
//        Self.Style.label(paragraph, text: model.greenCertificate.detailGreenCertificate.paragraph)
//        Self.Style.contactButton(self.contactButton, content: model.greenCertificate.detailGreenCertificate.url)


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
        
        diseaseLabel.pin
          .minHeight(25)
          .below(of: title)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        disease.pin
          .minHeight(25)
          .below(of: diseaseLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        vaccineTypeLabel.pin
          .minHeight(25)
          .below(of: disease)
          .marginTop(15)
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
          .marginTop(15)
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
          .marginTop(15)
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
        
        numberOfDosesLabel.pin
          .minHeight(25)
          .below(of: vaccineProducer)
          .marginTop(15)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        numberOfDoses.pin
          .minHeight(25)
          .below(of: numberOfDosesLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        dateLastAdministrationLabel.pin
          .minHeight(25)
          .below(of: numberOfDoses)
          .marginTop(15)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        dateLastAdministration.pin
          .minHeight(25)
          .below(of: dateLastAdministrationLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        vaccinationCuntryLabel.pin
          .minHeight(25)
          .below(of: dateLastAdministration)
          .marginTop(15)
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
        
        certificateAuthorityLabel.pin
          .minHeight(25)
          .below(of: vaccinationCuntry)
          .marginTop(15)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        certificateAuthority.pin
          .minHeight(25)
          .below(of: certificateAuthorityLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        paragraph.pin
          .minHeight(25)
          .below(of: certificateAuthority)
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

private extension GreenCertificateDetailView {
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
