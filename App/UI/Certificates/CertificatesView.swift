// CertificatesView.swift
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

// MARK: - View

class CertificatesView: UIView, ViewControllerModellableView {
    typealias VM = CertificatesVM

  private static let horizontalSpacing: CGFloat = 30.0

  private let backgroundGradientView = GradientView()
  private let title = UILabel()

  let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

  var didTapBack: Interaction?
  var didTapCell: CustomInteraction<GreenCertificate>?
  var userDidScroll: CustomInteraction<CGFloat>?
  private let headerView = CertificatesHeaderView()
  var didTapDiscoverMore: Interaction?
  var didTapGenerateGreenCertificate: Interaction?

  private let containerDgcsNotPresent = UIView()
  private let inactiveLabel = UILabel()
  private let inactiveImage = UIImageView()
  private var actionButton = ButtonWithInsets()


  // MARK: - Setup

  func setup() {
      
    self.addSubview(self.backgroundGradientView)
    self.addSubview(self.title)
    self.addSubview(self.containerDgcsNotPresent)
    self.addSubview(self.actionButton)
    self.addSubview(self.inactiveLabel)
    self.addSubview(self.inactiveImage)
      
    self.headerView.didTapDiscoverMore = { [weak self] in
      self?.didTapDiscoverMore?()
    }
    self.actionButton.on(.touchUpInside) { [weak self] _ in
        self?.didTapGenerateGreenCertificate?()
    }

    self.collection.register(CertificateCell.self)
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapCollection))
    self.collection.addGestureRecognizer(tapGesture)

    self.collection.delegate = self
    self.collection.dataSource = self
  }

  @objc func didTapCollection() {}

  // MARK: - Style

  func style() {
    Self.Style.backgroundGradient(self.backgroundGradientView)
    Self.Style.header(self.headerView)
    Self.Style.collection(self.collection)
    Self.Style.title(self.title)
    
    Self.Style.inactiveLabel(inactiveLabel, text: L10n.HomeView.GreenCertificate.notPresentQrLabel)
    Self.Style.imageContent(inactiveImage, image: Asset.Home.inactive.image)
    Self.Style.container(containerDgcsNotPresent)
    Self.Style.actionButton(actionButton, icon: Asset.Home.qrNew.image)
  }

  // MARK: - Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }
      
    if model.shouldReloadCollection(oldModel: oldModel) {
        if let greenCertificates = model.greenCertificates, greenCertificates.count > 0 {
            self.addSubview(self.collection)
            self.addSubview(self.headerView)
            self.containerDgcsNotPresent.removeFromSuperview()
            self.actionButton.removeFromSuperview()
            self.inactiveLabel.removeFromSuperview()
            self.inactiveImage.removeFromSuperview()
            self.collection.reloadData()
          }
          else{
              self.addSubview(self.containerDgcsNotPresent)
              self.addSubview(self.actionButton)
              self.addSubview(self.inactiveLabel)
              self.addSubview(self.inactiveImage)
              self.headerView.removeFromSuperview()
              self.collection.removeFromSuperview()
          }
        }
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.backgroundGradientView.pin.all()

    self.title.pin
      .top(self.safeAreaInsets.top + 20)
      .horizontally(30)
      .sizeToFit(.width)
    
    self.headerView.pin
      .horizontally()
      .marginTop(30)
      .sizeToFit(.width)
      .below(of: self.title)
          
    self.collection.pin
      .horizontally()
      .below(of: self.headerView)
      .bottom(self.safeAreaInsets.bottom)
        
    self.containerDgcsNotPresent.pin
      .below(of: title)
      .marginTop(30)
      .horizontally(25)
      .height(UIDevice.getByScreen(normal: 400, short: 380))
        
    self.inactiveImage.pin
      .below(of: title)
      .marginTop(100)
      .hCenter()
      .width(200)
      .height(200)
    
    self.inactiveLabel.pin
      .below(of: inactiveImage)
      .marginTop(-40)
      .horizontally(55)
      .sizeToFit(.width)
        
    self.actionButton.pin
      .horizontally(45)
      .sizeToFit(.width)
      .minHeight(25)
      .below(of: containerDgcsNotPresent)
      .marginTop(20)

    self.updateAfterLayout()
  }

  private func updateAfterLayout() {
    guard
      let collectionViewLayout = self.collection.collectionViewLayout as? UICollectionViewFlowLayout//,
     // collectionViewLayout.estimatedItemSize == .zero // avoid multiple adjust iteration
    else {
      return
    }
    collectionViewLayout.itemSize = UICollectionViewFlowLayout.automaticSize
    collectionViewLayout.estimatedItemSize = CGSize(width: self.collection.bounds.width, height: 50)
    collectionViewLayout.minimumLineSpacing = 0
  }
}

// MARK: - Style

private extension CertificatesView {
  enum Style {

  static func container(_ view: UIView) {
    view.backgroundColor = Palette.white
    view.layer.cornerRadius = SharedStyle.cardCornerRadius
        view.addShadow(.cardLightBlue)
    }
  static func imageContent(_ imageView: UIImageView, image: UIImage) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
    }
  static func inactiveLabel(_ label: UILabel, text: String) {
    TempuraStyles.styleStandardLabel(
        label,
        content: text,
        style: TextStyles.p.byAdding(
            .color(Palette.grayNormal),
            .alignment(.center)
            )
        )
      }
    static func backgroundGradient(_ gradientView: GradientView) {
      gradientView.isUserInteractionEnabled = false
      gradientView.gradient = Palette.gradientBackgroundBlueOnBottom
    }

    static func separator(_ view: UIImageView) {
      view.image = Asset.Common.separator.image
    }

    static func header(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
      view.layer.cornerRadius = 15.0
      view.addShadow(.headerLightBlue)
    }

    static func collection(_ collectionView: UICollectionView) {
      collectionView.backgroundColor = .clear
      collectionView.contentInset = UIEdgeInsets(top: 18, left: 0, bottom: 70, right: 0)
      collectionView.showsVerticalScrollIndicator = false
    }

    static func title(_ label: UILabel) {
        let content = L10n.Certificate.CertificatesView.title
        TempuraStyles.styleShrinkableLabel(
        label,
        content: content,
        style: TextStyles.navbarSmallTitle.byAdding(
          .color(Palette.grayDark),
          .alignment(.left)
        ),
        numberOfLines: 1
      )
    }
  static func actionButton(
    _ button: ButtonWithInsets,
    icon: UIImage? = nil,
    tintColor: UIColor = Palette.white,
    backgroundColor: UIColor = Palette.primary,
    cornerRadius: CGFloat = 25,
    shadow: UIView.Shadow = .cardPrimary
    ) {
        
    let text = L10n.HomeView.GreenCertificate.generateButton
    let textStyle = TextStyles.pSemibold.byAdding([
          .color(tintColor),
          .alignment(.center)
        ])

    button.setBackgroundColor(backgroundColor, for: .normal)
    button.setAttributedTitle(text.styled(with: textStyle), for: .normal)
    button.setImage(icon, for: .normal)
    button.tintColor = tintColor
    button.insets = UIDevice.getByScreen(normal: .init(deltaX: 25, deltaY: 5), narrow: .init(deltaX: 15, deltaY: 5))

    button.layer.cornerRadius = cornerRadius
    button.titleLabel?.numberOfLines = 2
    button.addShadow(shadow)
    button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 60)
      }
  }
}

// MARK: - UICollectionViewDataSource

extension CertificatesView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return self.model?.greenCertificates?.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard
      let model = self.model,
      let cellModel = model.cellModel(for: indexPath)
    else {
      return UICollectionViewCell()
    }

    let cell = collectionView.dequeueReusableCell(CertificateCell.self, for: indexPath)
    cell.model = cellModel as? CertificateCellVM
    cell.didTapCell = { [weak self] certificate in
      self?.didTapCell?(certificate)
    }
    return cell
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.userDidScroll?(scrollView.contentOffset.y)
  }
}
