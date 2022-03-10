// CertificatesCell.swift
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

import Extensions
import Foundation
import Models
import Tempura

struct CertificateCellVM: ViewModel {
    
  let greenCertificate: GreenCertificate
  let addedToHome: Bool
  let euDccDeadlines: [String: Int]

  var name: String {
      return self.greenCertificate.name
  }

  var vaccineDose: String {
    if let detailVaccineCertificate = self.greenCertificate.detailVaccineCertificate {
        return "\(detailVaccineCertificate.doseNumber)/ \(detailVaccineCertificate.totalSeriesOfDoses)"
      }
    return ""
  }
  var certificateTypeLabel: String {
    switch self.greenCertificate.certificateType {
      case .vaccine:
        return L10n.Certificate.CertificatesView.Cell.Vaccine.label(vaccineDose)
      case .test:
        if let typeOfTest = self.greenCertificate.detailTestCertificate?.typeOfTest {
            let testType = TestType(rawValue: typeOfTest)
            return testType?.getDescriptionPreview() ?? L10n.Certificate.CertificatesView.Cell.Test.label
        }
        else {
            return L10n.Certificate.CertificatesView.Cell.Test.label
        }
      case .recovery:
        return L10n.Certificate.CertificatesView.Cell.Recovery.label
      case .exemption:
        return L10n.Certificate.CertificatesView.Cell.Exemption.label
    }
  }
}

class CertificateCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = CertificateCellVM

  static let containerInset: CGFloat = 25
  static let cellInset: CGFloat = 25
  static let chevronInset: CGFloat = 30
  static let chevronSize: CGFloat = 24
  static let pinIconSize: CGFloat = 35
  static let pinIconTop: CGFloat = 10
  static let titleToChevron: CGFloat = 15
  static let textTop: CGFloat = 20
  static let expirationToChevron: CGFloat = 45
    
  let pinIcon = UIImageView()
  let container = UIView()
  let text = UILabel()
  let expiration = UILabel()
  let certificateType = UILabel()
  let date = UILabel()
  let chevron = UIImageView()
  var overlayButton = Button()
  var stateView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 24))

  var didTapCell: CustomInteraction<GreenCertificate>?

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.style()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
    self.style()
  }

  func setup() {
    self.contentView.addSubview(self.container)
    self.container.addSubview(self.text)
    self.container.addSubview(self.expiration)
    self.container.addSubview(self.chevron)
    self.container.addSubview(self.overlayButton)
    self.container.addSubview(self.stateView)

    self.text.isAccessibilityElement = false
    self.expiration.isAccessibilityElement = false
    self.overlayButton.isAccessibilityElement = true

    self.overlayButton.on(.touchUpInside) { [weak self] _ in
      guard let greenCertificate = self?.model?.greenCertificate else {
        return
      }
      self?.didTapCell?(greenCertificate)
    }
  }

  func style() {
    Self.Style.shadow(self.contentView)
    Self.Style.container(self.container)
    Self.Style.chevron(self.chevron)
    Self.Style.overlayButton(self.overlayButton)
    Self.Style.pinIcon(self.pinIcon)
  }
    
  func checkValidity(euDccDeadlines: [String: Int], certificate: GreenCertificate) {
    switch certificate.certificateType {
      case .vaccine:
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let dateFormatterView = DateFormatter()
        dateFormatterView.dateFormat = "dd-MM-yyyy"
        dateFormatterView.calendar = Calendar.current
        dateFormatterView.timeZone = TimeZone.current
        let today = Date()
        var validityDays: Int?
       
        if let detailVaccineCertificate = certificate.detailVaccineCertificate,
           detailVaccineCertificate.doseNumber < detailVaccineCertificate.totalSeriesOfDoses {
            validityDays = euDccDeadlines["vaccine_first_dose"]
        }
        else if let detailVaccineCertificate = certificate.detailVaccineCertificate,
           detailVaccineCertificate.doseNumber == detailVaccineCertificate.totalSeriesOfDoses,
           detailVaccineCertificate.totalSeriesOfDoses < "3"
        {
            validityDays = euDccDeadlines["vaccine_fully_completed"]
        }
        else {
            validityDays = euDccDeadlines["vaccine_booster"]
        }

        if let detailVaccineCertificate = certificate.detailVaccineCertificate,
           let validityDays = validityDays,
           let date = dateFormatter.date(from: detailVaccineCertificate.dateLastAdministration),
           let afterAddTime = Calendar.current.date(byAdding: .day, value: validityDays, to: date),
            today < afterAddTime {
            
            let dateToShow = dateFormatterView.string(from: afterAddTime)
            Self.Style.expiration(self.expiration, validity: L10n.Certificate.CertificatesView.Cell.Valid.label(dateToShow))
                stateView.layer.backgroundColor = Palette.primary.cgColor
                stateView.layer.borderWidth = 1.0
                stateView.layer.borderColor = Palette.primary.cgColor
                self.setRoundness(ToCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], for: stateView, withRadius: SharedStyle.cardCornerRadius)
        }
        else {
            Self.Style.expiration(self.expiration, validity: L10n.Certificate.CertificatesView.Cell.Expired.label)
            stateView.layer.backgroundColor = Palette.red.cgColor
            stateView.layer.borderWidth = 1.0
            stateView.layer.borderColor = Palette.red.cgColor
            self.setRoundness(ToCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], for: stateView, withRadius: SharedStyle.cardCornerRadius)
        }
        
      case .test:
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let dateFormatterView = DateFormatter()
        dateFormatterView.dateFormat = "dd-MM-yyyy"
        dateFormatterView.calendar = Calendar.current
        dateFormatterView.timeZone = TimeZone.current

        let today = Date().localDate()

        if let detailTestCertificate = certificate.detailTestCertificate,
           let testType = TestType(rawValue: detailTestCertificate.typeOfTest),
           let validityHours = euDccDeadlines[testType.getKeyValidity()],
           let date = dateFormatter.date(from: detailTestCertificate.dateTimeOfSampleCollection),
           let afterAddTime = Calendar.current.date(byAdding: .hour, value: validityHours, to: date),
            today < afterAddTime {
            
            Self.Style.expiration(self.expiration, validity: testType.getValidUntilValue())
                stateView.layer.backgroundColor = Palette.primary.cgColor
                stateView.layer.borderWidth = 1.0
                stateView.layer.borderColor = Palette.primary.cgColor
                self.setRoundness(ToCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], for: stateView, withRadius: SharedStyle.cardCornerRadius)
        }
        else {
            Self.Style.expiration(self.expiration, validity: L10n.Certificate.CertificatesView.Cell.Expired.label)
            stateView.layer.backgroundColor = Palette.red.cgColor
            stateView.layer.borderWidth = 1.0
            stateView.layer.borderColor = Palette.red.cgColor
            self.setRoundness(ToCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], for: stateView, withRadius: SharedStyle.cardCornerRadius)
        }

      case .recovery:
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let dateFormatterView = DateFormatter()
        dateFormatterView.dateFormat = "dd-MM-yyyy"
        dateFormatterView.calendar = Calendar.current
        dateFormatterView.timeZone = TimeZone.current

        let today = Date()
        var validityDays = euDccDeadlines["healing_certificate"]
        if let dgcType = certificate.dgcType, dgcType == "cbis" {
            validityDays = euDccDeadlines["cbis"]
        }

        if let detailRecoveryCertificate = certificate.detailRecoveryCertificate,
           let validityDays = validityDays,
           let date = dateFormatter.date(from: detailRecoveryCertificate.certificateValidFrom),
           let afterAddTime = Calendar.current.date(byAdding: .day, value: validityDays, to: date),
            today < afterAddTime {
            let dateToShow = dateFormatterView.string(from: afterAddTime)
            Self.Style.expiration(self.expiration, validity: L10n.Certificate.CertificatesView.Cell.Valid.label(dateToShow))
                stateView.layer.backgroundColor = Palette.primary.cgColor
                stateView.layer.borderWidth = 1.0
                stateView.layer.borderColor = Palette.primary.cgColor
                self.setRoundness(ToCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], for: stateView, withRadius: SharedStyle.cardCornerRadius)
        }
        else {
            Self.Style.expiration(self.expiration, validity: L10n.Certificate.CertificatesView.Cell.Expired.label)
            stateView.layer.backgroundColor = Palette.red.cgColor
            stateView.layer.borderWidth = 1.0
            stateView.layer.borderColor = Palette.red.cgColor
            self.setRoundness(ToCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], for: stateView, withRadius: SharedStyle.cardCornerRadius)
        }
        
      case .exemption:
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let dateFormatterView = DateFormatter()
        dateFormatterView.dateFormat = "dd-MM-yyyy"
        dateFormatterView.calendar = Calendar.current
        dateFormatterView.timeZone = TimeZone.current

        let today = Date()
        
        var maxDateValidity:Date? = nil
        if let certificateValidUntil = certificate.detailExemptionCertificate?.certificateValidUntil, let certificateValidUntilDate = dateFormatter.date(from: certificateValidUntil) {
            maxDateValidity = certificateValidUntilDate
        }
        else if let validityDays = euDccDeadlines["exemption"],
               let certificateValidFrom = certificate.detailExemptionCertificate?.certificateValidFrom,
               let date = dateFormatter.date(from: certificateValidFrom),
               let afterAddTime = Calendar.current.date(byAdding: .day, value: validityDays, to: date) {
                maxDateValidity = afterAddTime
        }

        if let maxDateValidity = maxDateValidity, today < maxDateValidity {
            let dateToShow = dateFormatterView.string(from: maxDateValidity)
            Self.Style.expiration(self.expiration, validity: L10n.Certificate.CertificatesView.Cell.Valid.label(dateToShow))
            stateView.layer.backgroundColor = Palette.primary.cgColor
            stateView.layer.borderWidth = 1.0
            stateView.layer.borderColor = Palette.primary.cgColor
            self.setRoundness(ToCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], for: stateView, withRadius: SharedStyle.cardCornerRadius)
            }
        else {
            Self.Style.expiration(self.expiration, validity: L10n.Certificate.CertificatesView.Cell.Expired.label)
            stateView.layer.backgroundColor = Palette.red.cgColor
            self.setRoundness(ToCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], for: stateView, withRadius: SharedStyle.cardCornerRadius)
            stateView.layer.borderWidth = 1.0
            stateView.layer.borderColor = Palette.red.cgColor
        }
     }
  }

  func setRoundness(ToCorners corners: UIRectCorner, for view: UIView, withRadius radius: CGFloat) {
    let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    view.layer.mask = mask
  }
  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }
    if model.addedToHome {
        self.container.addSubview(self.pinIcon)
    }
    else {
        self.pinIcon.removeFromSuperview()
    }
    self.checkValidity(euDccDeadlines: model.euDccDeadlines, certificate: model.greenCertificate)
    Self.Style.title(self.text, name: model.name, type: model.certificateTypeLabel)

    self.overlayButton.accessibilityLabel = model.greenCertificate.name

    self.setNeedsLayout()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.container.pin
      .horizontally(CertificateCell.containerInset)
      .vertically(7.5)

    self.chevron.pin
      .right(Self.chevronInset)
      .vCenter()
      .size(Self.chevronSize)
      
    self.pinIcon.pin
      .top(Self.pinIconTop)
      .right(Self.chevronInset)
      .aspectRatio(self.pinIcon.intrinsicContentSize.width / self.pinIcon.intrinsicContentSize.height)
      .width(Self.pinIconSize)
      
      self.text.pin
        .left(Self.cellInset)
        .right()
        .top(Self.textTop)
        .marginRight(Self.titleToChevron)
        .sizeToFit(.width)
      
    self.stateView.pin
      .below(of: self.text)
      .marginTop(Self.titleToChevron)
      .left(Self.cellInset)
      
    self.expiration.pin
      .right()
      .marginTop(Self.titleToChevron)
      .below(of: self.text)
      .after(of: self.stateView)
      .marginLeft(Self.pinIconTop)
      .marginRight(Self.expirationToChevron)
      .sizeToFit(.width)
      
    self.overlayButton.pin
      .horizontally(10)
      .vertically(10)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - 2 * Self.containerInset - Self.cellInset - Self.chevronSize - Self.chevronInset
    let textSize = self.text.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    let expirationSize = self.expiration.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
    return CGSize(width: size.width, height: textSize.height + expirationSize.height + 70)
  }
}

private extension CertificateCell {
  enum Style {
    static func container(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.clipsToBounds = true
    }

    static func shadow(_ view: UIView) {
      view.addShadow(.cardLightBlue)
    }

    static func chevron(_ view: UIImageView) {
        view.image = Asset.Common.nextOff.image
    }

    static func overlayButton(_ button: Button) {
      button.setBackgroundColor(Palette.white.withAlphaComponent(0.4), for: .highlighted)
      button.adjustsImageWhenHighlighted = false
      button.setOverlayOpacity(0, for: .highlighted)
      button.accessibilityTraits = .button
    }

    static func title(_ label: UILabel, name: String, type: String) {
      let text = "<b>\(name)</b>\n\(type)"
      let highlightStyle = TextStyles.pBold.byAdding(
        .color(Palette.grayDark),
        .alignment(.left)
      )
      let textStyle = TextStyles.p.byAdding(
        .color(Palette.grayDark),
        .alignment(.left),
        .xmlRules([
          .style("b", highlightStyle)
        ])
      )

      TempuraStyles.styleShrinkableLabel(
        label,
        content: text,
        style: textStyle
      )
    }
    static func expiration(_ label: UILabel, validity: String) {
      let highlightStyle = TextStyles.pBold.byAdding(
        .color(Palette.grayDark),
        .alignment(.left)
        )
      let textStyle = TextStyles.p.byAdding(
        .color(Palette.grayDark),
        .alignment(.left),
        .xmlRules([
          .style("b", highlightStyle)
         ])
        )

        TempuraStyles.styleShrinkableLabel(
          label,
          content: validity,
          style: textStyle
        )
      }
    static func pinIcon(_ imageView: UIImageView) {
        imageView.image = Asset.Home.pinSelected.image
    }
  }
}
extension Date {
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}

        return localDate
    }
}
