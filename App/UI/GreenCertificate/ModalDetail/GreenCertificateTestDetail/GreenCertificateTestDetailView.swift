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
    
    //Test fields
    private var diseaseTestLabel = UILabel()
    private var diseaseTest = UILabel()
    private var typeOfTestLabel = UILabel()
    private var typeOfTest = UILabel()
    private var testResultLabel = UILabel()
    private var testResult = UILabel()
    private var ratTestNameAndManufacturerLabel = UILabel()
    private var ratTestNameAndManufacturer = UILabel()
    private var naaTestNameLabel = UILabel()
    private var naaTestName = UILabel()
    private var dateTimeOfSampleCollectionLabel = UILabel()
    private var dateTimeOfSampleCollection = UILabel()
    private var dateTimeOfTestResultLabel = UILabel()
    private var dateTimeOfTestResult = UILabel()
    private var testingCentreLabel = UILabel()
    private var testingCentre = UILabel()
    private var countryOfTestLabel = UILabel()
    private var countryOfTest = UILabel()
    private var certificateIssuerLabel = UILabel()
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

        addSubview(diseaseTestLabel)
        scrollView.addSubview(diseaseTestLabel)
        addSubview(diseaseTest)
        scrollView.addSubview(diseaseTest)
        addSubview(typeOfTestLabel)
        scrollView.addSubview(typeOfTestLabel)
        addSubview(typeOfTest)
        scrollView.addSubview(typeOfTest)
        addSubview(testResultLabel)
        scrollView.addSubview(testResultLabel)
        addSubview(testResult)
        scrollView.addSubview(testResult)
        addSubview(dateTimeOfSampleCollectionLabel)
        scrollView.addSubview(dateTimeOfSampleCollectionLabel)
        addSubview(dateTimeOfSampleCollection)
        scrollView.addSubview(dateTimeOfSampleCollection)
        addSubview(dateTimeOfTestResultLabel)
        scrollView.addSubview(dateTimeOfTestResultLabel)
        addSubview(dateTimeOfTestResult)
        scrollView.addSubview(dateTimeOfTestResult)
        addSubview(testingCentreLabel)
        scrollView.addSubview(testingCentreLabel)
        addSubview(testingCentre)
        scrollView.addSubview(testingCentre)
        addSubview(countryOfTestLabel)
        scrollView.addSubview(countryOfTestLabel)
        addSubview(countryOfTest)
        scrollView.addSubview(countryOfTest)
        addSubview(certificateIssuerLabel)
        scrollView.addSubview(certificateIssuerLabel)
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

        Self.Style.scrollView(scrollView)
        Self.Style.headerTitle(title, content: L10n.HomeView.GreenCertificate.Detail.title)
        
        //Test fields
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
                addSubview(ratTestNameAndManufacturer)
                scrollView.addSubview(ratTestNameAndManufacturer)
            }
            if let naaTestNameValue =  detailTestCertificate.naaTestName, naaTestNameValue != ""  {
                Self.Style.value(naaTestName, text: naaTestNameValue)
                addSubview(naaTestNameLabel)
                scrollView.addSubview(naaTestNameLabel)
                addSubview(naaTestName)
                scrollView.addSubview(naaTestName)
            }
            Self.Style.value(dateTimeOfSampleCollection, text: String(detailTestCertificate.dateTimeOfSampleCollection.split(separator: "T")[0] ?? "---"))
            Self.Style.value(dateTimeOfTestResult, text: String(detailTestCertificate.dateTimeOfTestResult.split(separator: "T")[0] ?? "---"))
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
      
        diseaseTestLabel.pin
          .minHeight(25)
          .below(of: title)
          .marginTop(30)
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
        
        typeOfTestLabel.pin
          .minHeight(25)
          .below(of: diseaseTest)
          .marginTop(30)
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
        
        testResultLabel.pin
          .minHeight(25)
          .below(of: typeOfTest)
          .marginTop(30)
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
        
        ratTestNameAndManufacturerLabel.pin
          .minHeight(25)
          .below(of: testResult)
          .marginTop(30)
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
        
        naaTestNameLabel.pin
          .minHeight(25)
          .below(of: testResult)
          .marginTop(30)
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
        
        dateTimeOfSampleCollectionLabel.pin
          .minHeight(25)
          .below(of: testResult)
          .marginTop(110)
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
        
        dateTimeOfTestResultLabel.pin
          .minHeight(25)
          .below(of: dateTimeOfSampleCollection)
          .marginTop(30)
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
        
        testingCentreLabel.pin
          .minHeight(25)
          .below(of: dateTimeOfTestResult)
          .marginTop(30)
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
        
        countryOfTestLabel.pin
          .minHeight(25)
          .below(of: testingCentre)
          .marginTop(30)
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
        
        certificateIssuerLabel.pin
          .minHeight(25)
          .below(of: countryOfTest)
          .marginTop(30)
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


