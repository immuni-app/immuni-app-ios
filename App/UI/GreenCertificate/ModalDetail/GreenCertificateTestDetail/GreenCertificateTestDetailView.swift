// GreenCertificateTestDetailView.swift
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

struct GreenCertificateTestDetailVM: ViewModelWithLocalState {
    
    let greenCertificate: GreenCertificate
}

extension GreenCertificateTestDetailVM {
    init?(state: AppState?, localState : GreenCertificateTestDetailLS) {
        guard let _ = state else {
            return nil
        }

        self.greenCertificate = localState.greenCertificate
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
    private var naaTestNameLabel = UILabel()
    private var naaTestNameLabelEn = UILabel()
    private var naaTestName = UILabel()
    private var dateTimeOfSampleCollectionLabel = UILabel()
    private var dateTimeOfSampleCollectionLabelEn = UILabel()
    private var dateTimeOfSampleCollection = UILabel()
    private var dateTimeOfTestResultLabel = UILabel()
    private var dateTimeOfTestResultLabelEn = UILabel()
    private var dateTimeOfTestResult = UILabel()
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
        addSubview(backgroundGradientView)
        addSubview(scrollView)
        addSubview(title)
        addSubview(closeButton)
        addSubview(contactButton)
        scrollView.addSubview(contactButton)
        
        addSubview(certificateTypeLabel)
        scrollView.addSubview(certificateTypeLabel)
        addSubview(validUntilLabel)
        scrollView.addSubview(validUntilLabel)
        addSubview(validUntilLabelEn)
        scrollView.addSubview(validUntilLabelEn)
        addSubview(validUntil)
        scrollView.addSubview(validUntil)

        addSubview(diseaseTestLabel)
        scrollView.addSubview(diseaseTestLabel)
        addSubview(diseaseTestLabelEn)
        scrollView.addSubview(diseaseTestLabelEn)
        addSubview(diseaseTest)
        scrollView.addSubview(diseaseTest)
        addSubview(typeOfTestLabelEn)
        scrollView.addSubview(typeOfTestLabelEn)
        addSubview(typeOfTestLabel)
        scrollView.addSubview(typeOfTestLabel)
        addSubview(typeOfTest)
        scrollView.addSubview(typeOfTest)
        addSubview(testResultLabel)
        scrollView.addSubview(testResultLabel)
        addSubview(testResultLabelEn)
        scrollView.addSubview(testResultLabelEn)
        addSubview(testResult)
        scrollView.addSubview(testResult)
        addSubview(dateTimeOfSampleCollectionLabel)
        scrollView.addSubview(dateTimeOfSampleCollectionLabel)
        addSubview(dateTimeOfSampleCollectionLabelEn)
        scrollView.addSubview(dateTimeOfSampleCollectionLabelEn)
        addSubview(dateTimeOfSampleCollection)
        scrollView.addSubview(dateTimeOfSampleCollection)
        addSubview(dateTimeOfTestResultLabel)
        scrollView.addSubview(dateTimeOfTestResultLabel)
        addSubview(dateTimeOfTestResultLabelEn)
        scrollView.addSubview(dateTimeOfTestResultLabelEn)
        addSubview(dateTimeOfTestResult)
        scrollView.addSubview(dateTimeOfTestResult)
        addSubview(testingCentreLabel)
        scrollView.addSubview(testingCentreLabel)
        addSubview(testingCentreLabelEn)
        scrollView.addSubview(testingCentreLabelEn)
        addSubview(testingCentre)
        scrollView.addSubview(testingCentre)
        addSubview(countryOfTestLabel)
        scrollView.addSubview(countryOfTestLabel)
        addSubview(countryOfTestLabelEn)
        scrollView.addSubview(countryOfTestLabelEn)
        addSubview(countryOfTest)
        scrollView.addSubview(countryOfTest)
        addSubview(certificateIssuerLabel)
        scrollView.addSubview(certificateIssuerLabel)
        addSubview(certificateIssuerLabelEn)
        scrollView.addSubview(certificateIssuerLabelEn)
        addSubview(certificateIssuer)
        scrollView.addSubview(certificateIssuer)
        
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
        
        Self.Style.subTitle(certificateTypeLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.certificateType)
        
        Self.Style.label(validUntilLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.validUntil)
        Self.Style.label(validUntilLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.validUntilEn)
        Self.Style.value(validUntil, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.validUntilValue)

        Self.Style.scrollView(scrollView)
        Self.Style.headerTitle(title, content: L10n.HomeView.GreenCertificate.Detail.title)
        
        Self.Style.label(diseaseTestLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.disease)
        Self.Style.label(typeOfTestLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.typeOfTest)
        Self.Style.label(testResultLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.testResult)
        Self.Style.label(ratTestNameAndManufacturerLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.ratTestNameAndManufacturer)
        Self.Style.label(naaTestNameLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.naaTestName)
        Self.Style.label(dateTimeOfSampleCollectionLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.dateTimeOfSampleCollection)
        Self.Style.label(dateTimeOfTestResultLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.dateTimeOfTestResult)
        Self.Style.label(testingCentreLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.testingCentre)
        Self.Style.label(countryOfTestLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.countryOfTest)
        Self.Style.label(certificateIssuerLabel, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.certificateIssuer)
        
        Self.Style.label(diseaseTestLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.diseaseEn)
        Self.Style.label(typeOfTestLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.typeOfTestEn)
        Self.Style.label(testResultLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.testResultEn)
        Self.Style.label(ratTestNameAndManufacturerLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.ratTestNameAndManufacturerEn)
        Self.Style.label(naaTestNameLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.naaTestNameEn)
        Self.Style.label(dateTimeOfSampleCollectionLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.dateTimeOfSampleCollectionEn)
        Self.Style.label(dateTimeOfTestResultLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.dateTimeOfTestResultEn)
        Self.Style.label(testingCentreLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.testingCentreEn)
        Self.Style.label(countryOfTestLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.countryOfTestEn)
        Self.Style.label(certificateIssuerLabelEn, text: L10n.HomeView.GreenCertificate.Detail.Label.Test.certificateIssuerEn)
    
        Self.Style.closeButton(self.closeButton)

    }

    // MARK: - Update

    func update(oldModel _: VM?) {
        guard let model = self.model else {
            return
        }
        
        if let detailTestCertificate = model.greenCertificate.detailTestCertificate {
            Self.Style.value(diseaseTest, text: detailTestCertificate.disease)
            if let testType = TestType(rawValue: detailTestCertificate.typeOfTest) {
                Self.Style.value(typeOfTest, text: testType.getDescription())
            }
            else {
                Self.Style.value(typeOfTest, text: "---")
            }
            if let testResultValue = TestResult(rawValue: detailTestCertificate.testResult) {
                Self.Style.value(testResult, text: testResultValue.getDescription())
            }
            else {
                Self.Style.value(testResult, text: "---")
            }
            if let ratTestNameAndManufacturerValue =  detailTestCertificate.ratTestNameAndManufacturer, ratTestNameAndManufacturerValue != "" {
                Self.Style.value(ratTestNameAndManufacturer, text: ratTestNameAndManufacturerValue)
                addSubview(ratTestNameAndManufacturerLabel)
                scrollView.addSubview(ratTestNameAndManufacturerLabel)
                addSubview(ratTestNameAndManufacturerLabelEn)
                scrollView.addSubview(ratTestNameAndManufacturerLabelEn)
                addSubview(ratTestNameAndManufacturer)
                scrollView.addSubview(ratTestNameAndManufacturer)
            }
            else if let naaTestNameValue =  detailTestCertificate.naaTestName, naaTestNameValue != ""  {
                Self.Style.value(naaTestName, text: naaTestNameValue)
                addSubview(naaTestNameLabel)
                scrollView.addSubview(naaTestNameLabel)
                addSubview(naaTestNameLabelEn)
                scrollView.addSubview(naaTestNameLabelEn)
                addSubview(naaTestName)
                scrollView.addSubview(naaTestName)
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let dateFormatterView = DateFormatter()
            dateFormatterView.dateFormat = "yyyy-MM-dd"
            
            let dateTimeOfSampleCollectionValue = dateFormatter.date(from: detailTestCertificate.dateTimeOfSampleCollection)
            let dateTimeOfTestResultValue = dateFormatter.date(from: detailTestCertificate.dateTimeOfTestResult)

            if let dateTimeOfSampleCollectionValue = dateTimeOfSampleCollectionValue {
                Self.Style.value(dateTimeOfSampleCollection, text: dateFormatterView.string(from: dateTimeOfSampleCollectionValue))
            }
            else{
                Self.Style.value(dateTimeOfSampleCollection, text: "---")
            }
            if let dateTimeOfTestResultValue = dateTimeOfTestResultValue {
                Self.Style.value(dateTimeOfTestResult, text: dateFormatterView.string(from: dateTimeOfTestResultValue))
            }
            else{
                Self.Style.value(dateTimeOfTestResult, text: "---")
            }
            
            Self.Style.value(testingCentre, text: detailTestCertificate.testingCentre)
            Self.Style.value(countryOfTest, text: detailTestCertificate.countryOfTest)
            Self.Style.value(certificateIssuer, text: detailTestCertificate.certificateIssuer)
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
        
        certificateTypeLabel.pin
          .minHeight(25)
          .below(of: title)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
      
        diseaseTestLabelEn.pin
          .minHeight(25)
          .below(of: certificateTypeLabel)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        diseaseTestLabel.pin
          .minHeight(25)
          .below(of: diseaseTestLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        diseaseTest.pin
          .minHeight(25)
          .below(of: diseaseTestLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        typeOfTestLabelEn.pin
          .minHeight(25)
          .below(of: diseaseTest)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        typeOfTestLabel.pin
          .minHeight(25)
          .below(of: typeOfTestLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        typeOfTest.pin
          .minHeight(25)
          .below(of: typeOfTestLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        validUntilLabelEn.pin
          .minHeight(25)
          .below(of: typeOfTest)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        validUntilLabel.pin
          .minHeight(25)
          .below(of: validUntilLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        validUntil.pin
          .minHeight(25)
          .below(of: validUntilLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        testResultLabelEn.pin
          .minHeight(25)
          .below(of: validUntil)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        testResultLabel.pin
          .minHeight(25)
          .below(of: testResultLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        testResult.pin
          .minHeight(25)
          .below(of: testResultLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        ratTestNameAndManufacturerLabelEn.pin
          .minHeight(25)
          .below(of: testResult)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        ratTestNameAndManufacturerLabel.pin
          .minHeight(25)
          .below(of: ratTestNameAndManufacturerLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)

        ratTestNameAndManufacturer.pin
          .minHeight(25)
          .below(of: ratTestNameAndManufacturerLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        naaTestNameLabelEn.pin
          .minHeight(25)
          .below(of: testResult)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        naaTestNameLabel.pin
          .minHeight(25)
          .below(of: naaTestNameLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        naaTestName.pin
          .minHeight(25)
          .below(of: naaTestNameLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        dateTimeOfSampleCollectionLabelEn.pin
          .minHeight(25)
          .below(of: testResult)
          .marginTop(140)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        dateTimeOfSampleCollectionLabel.pin
          .minHeight(25)
          .below(of: dateTimeOfSampleCollectionLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        dateTimeOfSampleCollection.pin
          .minHeight(25)
          .below(of: dateTimeOfSampleCollectionLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        dateTimeOfTestResultLabelEn.pin
          .minHeight(25)
          .below(of: dateTimeOfSampleCollection)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        dateTimeOfTestResultLabel.pin
          .minHeight(25)
          .below(of: dateTimeOfTestResultLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        dateTimeOfTestResult.pin
          .minHeight(25)
          .below(of: dateTimeOfTestResultLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        testingCentreLabelEn.pin
          .minHeight(25)
          .below(of: dateTimeOfTestResult)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        testingCentreLabel.pin
          .minHeight(25)
          .below(of: testingCentreLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        testingCentre.pin
          .minHeight(25)
          .below(of: testingCentreLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        countryOfTestLabelEn.pin
          .minHeight(25)
          .below(of: testingCentre)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        countryOfTestLabel.pin
          .minHeight(25)
          .below(of: countryOfTestLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        countryOfTest.pin
          .minHeight(25)
          .below(of: countryOfTestLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        certificateIssuerLabelEn.pin
          .minHeight(25)
          .below(of: countryOfTest)
          .marginTop(30)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        certificateIssuerLabel.pin
          .minHeight(25)
          .below(of: certificateIssuerLabelEn)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        certificateIssuer.pin
          .minHeight(25)
          .below(of: certificateIssuerLabel)
          .marginTop(5)
          .sizeToFit(.width)
          .horizontally(25)
          .marginLeft(10)
        
        
        paragraph.pin
          .minHeight(25)
          .below(of: certificateIssuer)
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


