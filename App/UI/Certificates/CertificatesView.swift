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
  private let noResultView = FaqNoResultView()

  let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

  var didChangeSearchStatus: CustomInteraction<Bool>?
  var didChangeSearchedValue: CustomInteraction<String>?
  var didTapBack: Interaction?
  var didTapCell: CustomInteraction<GreenCertificate>?
  var userDidScroll: CustomInteraction<CGFloat>?
  private let headerView = CertificatesHeaderView()
  var didTapDiscoverMore: Interaction?


  // MARK: - Setup

  func setup() {
    self.addSubview(self.backgroundGradientView)
    self.addSubview(self.noResultView)
    self.addSubview(self.collection)
    self.addSubview(self.headerView)
    self.addSubview(self.title)
      
    self.headerView.didTapDiscoverMore = { [weak self] in
      self?.didTapDiscoverMore?()
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
  }

  // MARK: - Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    if model.shouldReloadCollection(oldModel: oldModel) {
      self.collection.reloadData()
      self.noResultView.alpha = model.shouldShowNoResult.cgFloat
    }

//    if model.shouldUpdateHeader(oldModel: oldModel) {
//      UIView.update(shouldAnimate: oldModel != nil) {
//        self.headerView.alpha = model.isHeaderVisible.cgFloat
//      }
//    }

//    if model.shouldUpdateSearchStatus(oldModel: oldModel) {
//      self.searchBar.model = model.searchBarVM
//
//      let contentOffset = self.collection.contentOffset
//      self.setNeedsLayout()
//      UIView.update(shouldAnimate: oldModel != nil) {
//        self.title.alpha = model.shouldShowTitle.cgFloat
//        self.layoutIfNeeded()
//        self.collection.setContentOffset(contentOffset, animated: false)
//      }
//    }

//    if model.shouldUpdateLayout(oldModel: oldModel) {
//      self.setNeedsLayout()
//      UIView.update(shouldAnimate: oldModel != nil) {
//        self.layoutIfNeeded()
//      }
//    }
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

    self.noResultView.pin
      .sizeToFit()
      .below(of: self.title)
      .bottom(self.safeAreaInsets.bottom)
      .align(.center)
      .hCenter()

    self.updateAfterLayout()
  }

  private func updateAfterLayout() {
    guard
      let collectionViewLayout = self.collection.collectionViewLayout as? UICollectionViewFlowLayout,
      collectionViewLayout.estimatedItemSize == .zero // avoid multiple adjust iteration
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

//  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//    self.searchBar.resignFirstResponder()
//  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.userDidScroll?(scrollView.contentOffset.y)
  }
}
