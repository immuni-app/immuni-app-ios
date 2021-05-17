// HomeView.swift
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
import Tempura

// MARK: - View

class HomeView: UIView, ViewControllerModellableView {
  typealias VM = HomeVM
  static let cellHorizontalInset: CGFloat = 30

  let collection = UICollectionView(frame: .zero, collectionViewLayout: CollectionWithStickyCellsLayout())

  var didTapActivateService: Interaction?
  var didTapInfo: CustomInteraction<HomeVM.InfoKind>?
  var didTapDoToday: CustomInteraction<HomeVM.DoTodayKind>?
  var didTapHeaderCardInfo: Interaction?
  var didTapDeactivateService: Interaction?
  var didTapActiveServiceDiscoverMore: Interaction?

  // MARK: - Setup

  func setup() {
    self.addSubview(self.collection)

    self.collection.register(HomeHeaderCardCell.self)
    self.collection.register(HomeServiceActiveCell.self)
    self.collection.register(HomeInfoHeaderCell.self)
    self.collection.register(HomeDoTodayHeaderCell.self)
    self.collection.register(HomeInfoCell.self)
    self.collection.register(HomeDeactivateServiceCell.self)
    self.collection.register(HomeDoTodayCell.self)

    self.collection.delegate = self
    self.collection.dataSource = self
  }

  // MARK: - Style

  func style() {
    Self.Style.background(self)
    Self.Style.collection(self.collection)
  }

  // MARK: - Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    if model.shouldReloadCollection(oldModel: oldModel) {
      guard let oldModel = oldModel else {
        self.collection.reloadData()
        return
      }
      self.updateCollection(with: model, oldModel: oldModel)
    }
  }

  func updateCollection(with model: HomeVM, oldModel: HomeVM) {
    let toAdd = model.cellTypes.filter { !oldModel.cellTypes.contains($0) }
    let toRemove = oldModel.cellTypes.filter { !model.cellTypes.contains($0) }

    let removeIndices = toRemove
      .map { oldModel.cellTypes.firstIndex(of: $0) }
      .map { IndexPath(item: $0 ?? 0, section: 0) }

    let addIndices = toAdd
      .map { model.cellTypes.firstIndex(of: $0) }
      .map { IndexPath(item: $0 ?? 0, section: 0) }

    self.collection.performBatchUpdates({
      self.collection.deleteItems(at: removeIndices)
      self.collection.insertItems(at: addIndices)
    }, completion: { _ in
      self.collection.reloadData()
    })
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.collection.pin
      .horizontally()
      .top()
      .bottom()

    self.afterLayout()
  }

  private func afterLayout() {
    self.collection.contentInset.top = -self.universalSafeAreaInsets.top
    self.collection.contentInset.bottom = 20
    guard let collectionViewLayout = self.collection.collectionViewLayout as? UICollectionViewFlowLayout else {
      return
    }
    collectionViewLayout.itemSize = UICollectionViewFlowLayout.automaticSize
    collectionViewLayout.estimatedItemSize = CGSize(width: self.collection.bounds.width, height: 50)
    collectionViewLayout.minimumLineSpacing = 0
  }
}

// MARK: - Style

private extension HomeView {
  enum Style {
    static func background(_ view: UIView) {
      view.backgroundColor = Palette.grayWhite
    }

    static func collection(_ collectionView: UICollectionView) {
      collectionView.backgroundColor = Palette.grayWhite
      collectionView.showsVerticalScrollIndicator = false
      collectionView.alwaysBounceVertical = true
    }
  }
}

// MARK: - UICollectionViewDataSource

extension HomeView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.model?.cellTypes.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard
      let model = self.model,
      let cellType = model.cellType(for: indexPath),
      let cellModel = model.cellModel(for: indexPath)
    else {
      return UICollectionViewCell()
    }

    switch cellType {
    case .header:
      let cell = collectionView.dequeueReusableCell(HomeHeaderCardCell.self, for: indexPath)
      cell.model = cellModel as? HomeHeaderCardCellVM
      cell.didTapInfo = { [weak self] in
        self?.didTapHeaderCardInfo?()
      }
      return cell

    case .serviceActiveCard:
      let cell = collectionView.dequeueReusableCell(HomeServiceActiveCell.self, for: indexPath)
      cell.model = cellModel as? HomeServiceActiveCellVM
      cell.didTapAction = { [weak self] in self?.didTapActivateService?() }
      return cell

    case .infoHeader:
      let cell = collectionView.dequeueReusableCell(HomeInfoHeaderCell.self, for: indexPath)
      cell.model = cellModel as? HomeInfoHeaderCellVM
      return cell

    case .info:
      let cell = collectionView.dequeueReusableCell(HomeInfoCell.self, for: indexPath)
      cell.model = cellModel as? HomeInfoCellVM
      cell.didTapAction = { [weak self] in
        guard let infoKind = cell.model?.kind else {
          return
        }
        self?.didTapInfo?(infoKind)
      }
      return cell

    case .deactivateButton:
      let cell = collectionView.dequeueReusableCell(HomeDeactivateServiceCell.self, for: indexPath)
      cell.model = cellModel as? HomeDeactivateServiceCellVM
      cell.didTapButton = { [weak self] in
        self?.didTapDeactivateService?()
      }
      return cell
        
    case .doTodayHeader:
      let cell = collectionView.dequeueReusableCell(HomeDoTodayHeaderCell.self, for: indexPath)
      cell.model = cellModel as? HomeDoTodayHeaderCellVM
      return cell
        
    case .doToday:
        let cell = collectionView.dequeueReusableCell(HomeDoTodayCell.self, for: indexPath)
        cell.model = cellModel as? HomeDoTodayCellVM
        cell.didTapAction = { [weak self] in
          guard let todoKind = cell.model?.kind else {
            return
          }
          self?.didTapDoToday?(todoKind)
        }
        return cell
    }
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: false)
    guard let cellType = self.model?.cellType(for: indexPath) else {
      return
    }

    switch cellType {
    case .header:
      self.didTapHeaderCardInfo?()
    case .serviceActiveCard(true):
      self.didTapActiveServiceDiscoverMore?()
    case .serviceActiveCard(false):
      self.didTapActivateService?()
    case .infoHeader:
      return
    case .info:
      guard let cellModel = self.model?.cellModel(for: indexPath) as? HomeInfoCellVM else {
        return
      }
      self.didTapInfo?(cellModel.kind)
    case .deactivateButton:
      guard
        let cellModel = self.model?.cellModel(for: indexPath) as? HomeDeactivateServiceCellVM,
        cellModel.isEnabled
      else {
        return
      }
      self.didTapDeactivateService?()
        
    case .doTodayHeader:
        return
    case .doToday:
      guard let cellModel = self.model?.cellModel(for: indexPath) as? HomeDoTodayCellVM else {
        return
      }
      self.didTapDoToday?(cellModel.kind)
    }
  }
}
