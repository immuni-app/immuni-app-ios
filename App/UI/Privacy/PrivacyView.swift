// PrivacyView.swift
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
import PinLayout
import Tempura

final class PrivacyView: UIView, ViewControllerModellableView {
  private static let horizontalSpacing: CGFloat = 10.0
  private static let buttonToGradientSpacing: CGFloat = 50.0

  // MARK: Interactions

  var userDidTapClose: Interaction?
  var userDidTapActionButton: Interaction?
  var userDidTapAbove14Checkbox: Interaction?
  var userDidTapReadPrivacyNoticeCheckbox: Interaction?
  var userDidScroll: CustomInteraction<CGFloat>?
  var userDidTapURL: CustomInteraction<URL>?

  // MARK: Subviews

  lazy var contentCollection: UICollectionView = {
    let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    collection.delegate = self
    collection.dataSource = self

    collection.register(PrivacyItemCell.self)
    collection.register(PrivacyTitleCell.self)
    collection.register(PrivacyCheckboxCell.self)
    collection.register(PrivacySpacerCell.self)
    collection.register(PrivacyTOUCell.self)

    return collection
  }()

  private var closeButton = ImageButton()
  private var actionButton = ButtonWithInsets()

  private let backgroundGradientView = GradientView()
  let scrollableGradientView = GradientView()

  private let headerView = UIView()
  private let headerTitleView = UILabel()

  // MARK: Methods

  func setup() {
    self.addSubview(self.backgroundGradientView)
    self.addSubview(self.contentCollection)
    self.addSubview(self.scrollableGradientView)
    self.addSubview(self.headerView)
    self.addSubview(self.actionButton)
    self.addSubview(self.closeButton)

    self.headerView.addSubview(self.headerTitleView)

    self.closeButton.on(.touchUpInside) { [weak self] _ in
      self?.userDidTapClose?()
    }

    self.actionButton.on(.touchUpInside) { [weak self] _ in
      self?.userDidTapActionButton?()
    }
  }

  func style() {
    Self.Style.backgroundGradient(self.backgroundGradientView)
    Self.Style.scrollableGradient(self.scrollableGradientView)
    Self.Style.collectionView(self.contentCollection)
    Self.Style.background(self)
    Self.Style.closeButton(self.closeButton)
    Self.Style.header(self.headerView)

    self.headerView.alpha = 0.0
  }

  func update(oldModel: PrivacyVM?) {
    guard let model = self.model else {
      return
    }

    if model.shouldReloadCollection(oldVM: oldModel) {
      self.updateCollection(using: model)
    }

    if model.shouldUpdateHeader(oldVM: oldModel) {
      UIView.update(shouldAnimate: oldModel != nil) {
        self.headerView.alpha = model.isHeaderVisible.cgFloat
      }
    }

    Self.Style.actionButton(self.actionButton, title: model.buttonTitle)
    Self.Style.headerTitle(self.headerTitleView, content: model.headerTitle)

    // note: here e don't know whether the gradient should be shown, as we don't know the
    // collection's size
  }

  /// Updates the collection in a way that doesn't cause glitches. Using a normal reloaddata, or even perform batch
  /// updates, lead to glitches when tapping on checkboxes, due to the dynamic sizing of the various cells.
  /// Here the method manages the cells individually, by skipping the collection mechanism. This is far from being ideal,
  /// but the result is flawless.
  ///
  /// - warning: the method assumes that 1) the only cells that change are the checkboxes one and
  /// 2) that cells' order doesn't change
  private func updateCollection(using model: PrivacyVM) {
    let checkboxCells = self.contentCollection.visibleCells.filter { item in
      item is PrivacyCheckboxCell
    }

    for cell in checkboxCells {
      guard
        let typedCell = cell as? PrivacyCheckboxCell,
        let idxPath = self.contentCollection.indexPath(for: cell)
      else {
        continue
      }

      typedCell.model = model.items[safe: idxPath.row]?.cellVM as? PrivacyCheckboxCellVM
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.contentCollection.pin.all()

    self.backgroundGradientView.pin.all()

    self.closeButton.pin
      .top(30 + self.safeAreaInsets.top)
      .right(28)
      .sizeToFit()

    self.headerTitleView.pin
      .left(Self.horizontalSpacing)
      .before(of: self.closeButton)
      .vCenter(to: self.closeButton.edge.vCenter)
      .marginHorizontal(Self.horizontalSpacing)
      .sizeToFit(.width)

    self.headerView.pin
      .left()
      .top()
      .right()
      .height(self.headerTitleView.frame.maxY + 20)

    self.actionButton.pin
      .width(min(self.bounds.width - Self.horizontalSpacing * 2, 315))
      .hCenter()
      .height(55)
      .bottom(UIDevice.getByScreen(normal: 30 + self.safeAreaInsets.bottom, narrow: 20))

    self.scrollableGradientView.pin
      .bottom()
      .left()
      .right()
      .top(to: self.actionButton.edge.top)
      .marginTop(-Self.buttonToGradientSpacing)

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

    let actionButtonSpaceFromBottom = self.frame.height - self.actionButton.frame.origin.y

    self.contentCollection.contentInset = UIEdgeInsets(
      top: 60,
      left: 0,
      bottom: actionButtonSpaceFromBottom + Self.buttonToGradientSpacing,
      right: 0
    )
  }

  // Helper
  /// Get the first errored cell in the view. Used for accessibility.
  func getFirstErroredCell() -> UIView? {
    guard let model = self.model else {
      return nil
    }

    for (index, item) in model.items.enumerated() {
      guard case .checkbox(_, _, let isErrored, _) = item, isErrored else {
        continue
      }

      return self.contentCollection.cellForItem(at: IndexPath(item: index, section: 0))
    }
    return nil
  }
}

// MARK: UICollectionViewDataSource

extension PrivacyView: UICollectionViewDataSource {
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
    case .privacyItem:
      return self.dequeue(PrivacyItemCell.self, for: indexPath, in: collectionView, using: item.cellVM)

    case .title:
      return self.dequeue(PrivacyTitleCell.self, for: indexPath, in: collectionView, using: item.cellVM)

    case .checkbox(let type, _, _, _):
      let cell = self.dequeue(PrivacyCheckboxCell.self, for: indexPath, in: collectionView, using: item.cellVM)
      cell.userDidTapCell = { [weak self] in self?.handleCheckboxTap(with: type) }
      cell.userDidTapURL = { [weak self] url in self?.userDidTapURL?(url) }
      return cell

    case .spacer:
      return self.dequeue(PrivacySpacerCell.self, for: indexPath, in: collectionView, using: item.cellVM)

    case .tou:
      let cell = self.dequeue(PrivacyTOUCell.self, for: indexPath, in: collectionView, using: item.cellVM)
      cell.userDidTapURL = { [weak self] url in self?.userDidTapURL?(url) }
      return cell
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

  private func handleCheckboxTap(with type: PrivacyCheckboxCellVM.CellType) {
    switch type {
    case .above14:
      self.userDidTapAbove14Checkbox?()

    case .privacyNoticeRead:
      self.userDidTapReadPrivacyNoticeCheckbox?()
    }
  }
}

// MARK: UICollectionViewDelegate

extension PrivacyView: UICollectionViewDelegateFlowLayout {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.userDidScroll?(scrollView.contentOffset.y)
  }
}

// MARK: Style

private extension PrivacyView {
  enum Style {
    static func collectionView(_ collection: UICollectionView) {
      collection.backgroundColor = .clear
      collection.showsVerticalScrollIndicator = false

      guard let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout else {
        return
      }

      layout.minimumLineSpacing = 0
      layout.minimumInteritemSpacing = 0
    }

    static func background(_ view: UIView) {
      view.backgroundColor = Palette.grayWhite
    }

    static func closeButton(_ btn: ImageButton) {
      SharedStyle.closeButton(btn)
    }

    static func backgroundGradient(_ gradientView: GradientView) {
      gradientView.isUserInteractionEnabled = false
      gradientView.gradient = Palette.gradientBackgroundBlueOnBottom
    }

    static func scrollableGradient(_ gradientView: GradientView) {
      gradientView.isUserInteractionEnabled = false

      gradientView.gradient = Gradient(
        colors: [
          UIColor(displayP3Red: 1.00, green: 1.00, blue: 1.00, alpha: 0.00),
          UIColor(displayP3Red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
        ],
        startPoint: CGPoint(x: 0.50, y: 0.00),
        endPoint: CGPoint(x: 0.50, y: 1.00),
        locations: [0.00, 0.5, 1.00],
        type: .linear
      )
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

    static func actionButton(_ button: ButtonWithInsets, title: String) {
      SharedStyle.primaryButton(button, title: title)
    }
  }
}
