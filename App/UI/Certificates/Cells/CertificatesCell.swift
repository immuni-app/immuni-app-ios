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

  var name: String {
      return self.greenCertificate.name
  }
  var date: String {
      return self.greenCertificate.birth
  }
  var vaccineDose: String {
    if let detailVaccineCertificate = self.greenCertificate.detailVaccineCertificate {
        return "\(detailVaccineCertificate.doseNumber)/ \(detailVaccineCertificate.totalSeriesOfDoses)"
      }
    return ""
  }
  var certificateType: String {
    switch self.greenCertificate.certificateType {
      case .vaccine:
        return "\(L10n.Certificate.CertificatesView.Cell.Vaccine.label) \(vaccineDose)"
      case .test:
        return L10n.Certificate.CertificatesView.Cell.MolecularTest.label
      case .recovery:
        return L10n.Certificate.CertificatesView.Cell.Recovery.label
      case .exemption:
        return L10n.Certificate.CertificatesView.Cell.Exemption.label
    }
  }
  var hasSubtitle: Bool {
      return true
  }
}

class CertificateCell: UICollectionViewCell, ModellableView, ReusableView {
  typealias VM = CertificateCellVM

  static let containerInset: CGFloat = 25
  static let cellInset: CGFloat = 25
  static let chevronInset: CGFloat = 30
  static let chevronSize: CGFloat = 24
  static let titleToChevron: CGFloat = 15

  let container = UIView()
  let text = UILabel()
  let expiration = UILabel()
  let certificateType = UILabel()
  let date = UILabel()
  let chevron = UIImageView()
  let expirationIcon = UIImageView()
  var overlayButton = Button()
  var lineView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1.0))

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
    self.container.addSubview(self.expirationIcon)
    self.container.addSubview(self.overlayButton)
    self.container.addSubview(self.lineView)

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
  }

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.title(self.text, name: model.name, type: model.certificateType)
//    if self.model?.hasSubtitle ?? false {
    if !true {//TODO scadenza
        Self.Style.expiration(self.expiration, validity: L10n.Certificate.CertificatesView.Cell.Valid.label( "2/2/22"))
        lineView.layer.backgroundColor = Palette.primary.cgColor
        lineView.layer.borderWidth = 1.0
        lineView.layer.borderColor = Palette.primary.cgColor
      }
    else {
        Self.Style.expiration(self.expiration, validity: L10n.Certificate.CertificatesView.Cell.Expired.label)
        lineView.layer.backgroundColor = Palette.red.cgColor
        lineView.layer.borderWidth = 1.0
        lineView.layer.borderColor = Palette.red.cgColor

      }
      
      Self.Style.chevron(self.expirationIcon)
//    }
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
      
    if self.model?.hasSubtitle ?? false {

      self.text.pin
        .left(Self.cellInset)
        .right()
        .top(20)
        .marginRight(Self.titleToChevron)
        .sizeToFit(.width)
        .vCenter()
    }
    else {
        self.text.pin
          .left(Self.cellInset)
          .right()
          .marginRight(Self.titleToChevron)
          .sizeToFit(.width)
          .vCenter()
          .vertically()

      }
      
//    self.expirationIcon.pin
//      .left(20)
//      .size(Self.chevronSize)
//      .bottom(20)
      
    self.lineView.pin
        //.hCenter()
      .below(of: self.text)
      .marginTop(20)
      .width(5)
      .height(20)
      .left(Self.cellInset)
      //.bottom(20)
      
    self.expiration.pin
//      .left()
      .right()
      .marginTop(30)
      .after(of: self.lineView)
      //.bottom(20)
      .marginLeft(10)
      .marginRight(Self.titleToChevron)
      .sizeToFit(.width)
      .vCenter()
      


    self.overlayButton.pin
      .horizontally(10)
      .vertically(10)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let labelWidth = size.width - 2 * Self.containerInset - Self.cellInset - Self.chevronSize - Self.chevronInset
    let textSize = self.text.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
      if self.model?.hasSubtitle ?? false {
        let expirationSize = self.expiration.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.infinity))
        return CGSize(width: size.width, height: textSize.height + expirationSize.height + 70)

    }
    return CGSize(width: size.width, height: textSize.height + 70)
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
  }
}
