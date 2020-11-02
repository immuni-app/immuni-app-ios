// OnboardingRegionView.swift
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

import BonMot
import Extensions
import Foundation
import Katana
import Models
import PinLayout
import Tempura

final class OnboardingRegionView: UIView, ViewControllerModellableView {
  // MARK: Interactions

  var userDidTapClose: Interaction?
  var userDidScroll: CustomInteraction<CGFloat>?
  var userDidSelectRegion: CustomInteraction<Region?>?
  var userDidTapDiscoverMore: Interaction?

  // MARK: Subviews

  lazy var contentCollection: UICollectionView = {
    let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    collection.delegate = self
    collection.dataSource = self

    collection.register(OnboardingRadioCell.self)
    collection.register(OnboardingHeaderCell.self)
    collection.register(OnboardingSpacerCell.self)

    return collection
  }()

  private var closeButton = ImageButton()
  private let headerView = UIView()
  private let headerTitleView = UILabel()

  // MARK: Methods

  func setup() {
    self.addSubview(self.contentCollection)
    self.addSubview(self.headerView)
    self.addSubview(self.closeButton)

    self.headerView.addSubview(self.headerTitleView)

    self.closeButton.on(.touchUpInside) { [weak self] _ in
      self?.userDidTapClose?()
    }
  }

  func style() {
    Self.Style.collectionView(self.contentCollection)
    Self.Style.background(self)
    Self.Style.closeButton(self.closeButton)
    Self.Style.header(self.headerView)
    Self.Style.headerTitle(self.headerTitleView, content: L10n.Onboarding.Region.title)
  }

  func update(oldModel: OnboardingRegionVM?) {
    guard let model = self.model else {
      return
    }

    self.closeButton.alpha = model.shouldShowCloseButton.cgFloat

    if model.shouldReloadCollection(oldVM: oldModel) {
      self.updateCollection(using: model)
    }

    if model.shouldUpdateHeader(oldVM: oldModel) {
      UIView.update(shouldAnimate: oldModel != nil) {
        self.headerView.alpha = model.isHeaderVisible.cgFloat
      }
    }
  }

  /// Updates the collection in a way that doesn't cause glitches. Using a normal reloaddata, or even perform batch
  /// updates, lead to glitches when tapping on checkboxes, due to the dynamic sizing of the various cells.
  /// Here the method manages the cells individually, by skipping the collection mechanism. This is far from being ideal,
  /// but the result is flawless.
  ///
  /// - warning: the method assumes that 1)cells' order doesn't change and 2) only radio cells change
  private func updateCollection(using model: OnboardingRegionVM) {
    let radioCells = self.contentCollection.visibleCells.filter { item in
      item is OnboardingRadioCell
    }

    for cell in radioCells {
      guard
        let typedCell = cell as? OnboardingRadioCell,
        let idxPath = self.contentCollection.indexPath(for: cell)
      else {
        continue
      }

      typedCell.model = model.items[safe: idxPath.row]?.cellVM as? OnboardingRadioCellVM
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.contentCollection.pin.all()

    self.closeButton.pin
      .top(15 + self.safeAreaInsets.top)
      .right(28)
      .sizeToFit()

    self.headerTitleView.pin
      .left(OnboardingContainerAccessoryView.horizontalSpacing)
      .before(of: self.closeButton)
      .vCenter(to: self.closeButton.edge.vCenter)
      .sizeToFit(.width)

    self.headerView.pin
      .left()
      .top()
      .right()
      .height(self.headerTitleView.frame.maxY + 20)

    self.updateAfterLayout()
  }

  private func updateAfterLayout() {
    guard
      let collectionViewLayout = self.contentCollection.collectionViewLayout as? UICollectionViewFlowLayout,
      collectionViewLayout.estimatedItemSize == .zero // avoid multiple adjust iteration
    else {
      return
    }

    collectionViewLayout.estimatedItemSize = CGSize(
      width: self.contentCollection.frame.width,
      height: 100
    )
  }
}

// MARK: UICollectionViewDataSource

extension OnboardingRegionView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.model?.items.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard
      let model = self.model,
      let item = model.items[safe: indexPath.row]

    else {
      AppLogger.fatalError("This should never happen")
    }

    switch item {
    case .titleHeader:
      let cell = self.dequeue(OnboardingHeaderCell.self, for: indexPath, in: collectionView, using: item.cellVM)
      cell.didTapActionButton = { [weak self] in self?.userDidTapDiscoverMore?() }
      return cell

    case .spacer:
      return self.dequeue(OnboardingSpacerCell.self, for: indexPath, in: collectionView, using: item.cellVM)

    case .radio:
      return self.dequeue(OnboardingRadioCell.self, for: indexPath, in: collectionView, using: item.cellVM)
    }
  }

  private func dequeue<Cell: ModellableView & ReusableView>(
    _ type: Cell.Type,
    for indexPath: IndexPath,
    in collectionView: UICollectionView,
    using viewModel: ViewModel
  ) -> Cell {
    let cell = collectionView.dequeueReusableCell(Cell.self, for: indexPath)
    cell.model = viewModel as? Cell.VM
    return cell
  }
}

// MARK: UICollectionViewDelegate

extension OnboardingRegionView: UICollectionViewDelegateFlowLayout {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.userDidScroll?(scrollView.contentOffset.y)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: false)

    guard
      let model = model,
      let cell = model.items[safe: indexPath.row],
      case OnboardingRegionVM.CellType.radio(let regionRawValue, _, let isSelected) = cell,
      let region = Region.allCases.first(where: { $0.rawValue == regionRawValue })
    else {
      return
    }

    DispatchQueue.main.async {
      // async here is required to prevent glitches in the collectionview
      // when reloading
      self.userDidSelectRegion?(isSelected ? nil : region)
    }
  }
}

// MARK: Style

extension OnboardingRegionView {
  enum Style {
    static func collectionView(_ collection: UICollectionView) {
      collection.backgroundColor = Palette.white
      collection.showsVerticalScrollIndicator = false
      collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)

      guard let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout else {
        return
      }

      layout.minimumLineSpacing = 0
      layout.minimumInteritemSpacing = 0

      // remember that the colletion already accounts for the safe area insets
      collection.contentInset = UIEdgeInsets(
        top: 60,
        left: 0,
        bottom: 30,
        right: 0
      )
    }

    static func background(_ view: UIView) {
      view.backgroundColor = Palette.white
    }

    static func closeButton(_ btn: ImageButton) {
      SharedStyle.closeButton(btn)
    }

    static func header(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
      view.layer.cornerRadius = 15.0
      view.addShadow(.headerLightBlue)
    }

    static func headerTitle(_ label: UILabel, content: String) {
      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: TextStyles.h4.byAdding(
          .color(Palette.grayDark)
        )
      )
    }
  }
}
