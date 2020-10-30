// PermissionTutorialView.swift
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

final class PermissionTutorialView: UIView, ViewControllerModellableView {
  private static let buttonToGradientSpacing: CGFloat = 50.0
  private static let horizontalSpacing: CGFloat = 30.0

  // MARK: Interactions

  var userDidTapClose: Interaction?
  var userDidTapActionButton: Interaction?
  var userDidScroll: CustomInteraction<CGFloat>?
  var willStartScrollAnimation: Interaction?
  var didEndScrollAnimation: Interaction?

  // MARK: Subviews

  lazy var contentCollection: UICollectionView = {
    let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    collection.delegate = self
    collection.dataSource = self

    collection.register(ContentCollectionTitleCell.self)
    collection.register(ContentCollectionTextCell.self)
    collection.register(ContentCollectionAnimationCell.self)
    collection.register(ContentCollectionImageCell.self)
    collection.register(ContentCollectionTextAndImageCell.self)
    collection.register(ContentCollectionSpacer.self)
    collection.register(ContentCollectionButtonCell.self)

    return collection
  }()

  private var closeButton = ImageButton()
  private var actionButton = ButtonWithInsets()
  private let gradientView = GradientView()

  private let headerView = UIView()
  private let headerTitleView = UILabel()

  // MARK: Methods

  func setup() {
    self.addSubview(self.contentCollection)
    self.addSubview(self.headerView)
    self.addSubview(self.gradientView)
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
    Self.Style.collectionView(self.contentCollection)
    Self.Style.background(self)
    Self.Style.closeButton(self.closeButton)
    Self.Style.gradient(self.gradientView)
    Self.Style.header(self.headerView)
  }

  func update(oldModel: PermissionTutorialVM?) {
    guard let model = self.model else {
      return
    }

    if model.shouldReloadCollection(oldVM: oldModel) {
      self.contentCollection.reloadData()
    }

    if model.shouldUpdateAnimations(oldVM: oldModel) {
      self.reloadVisibleAnimationCells(model: model)
    }

    SharedStyle.primaryButton(self.actionButton, title: model.content.mainActionTitle ?? "")
    self.actionButton.isHidden = !model.content.isActionButtonVisible

    Self.Style.headerTitle(self.headerTitleView, content: model.content.title)

    if model.shouldUpdateHeader(oldVM: oldModel) {
      UIView.update(shouldAnimate: oldModel != nil) {
        self.headerView.alpha = model.isHeaderVisible.cgFloat
      }
    }

    // note: here we don't know whether the gradient should be shown, as we don't know the
    // collection's size
  }

  private func reloadVisibleAnimationCells(model: PermissionTutorialVM) {
    for path in self.contentCollection.indexPathsForVisibleItems {
      if
        let cell = self.contentCollection.cellForItem(at: path) as? ContentCollectionAnimationCell,
        let cellModel = model.cellVM(for: model.content.items[path.item]) as? ContentCollectionAnimationCellVM
      {
        cell.model = cellModel
      }
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.contentCollection.pin.all()

    self.closeButton.pin
      .top(30)
      .right(28)
      .sizeToFit()

    self.actionButton.pin
      .width(min(self.bounds.width - Self.horizontalSpacing * 2, 315))
      .hCenter()
      .height(55)
      .bottom(UIDevice.getByScreen(normal: 30 + self.safeAreaInsets.bottom, narrow: 20))

    self.gradientView.pin
      .bottom()
      .left()
      .right()
      .top(to: self.actionButton.edge.top)
      .marginTop(-Self.buttonToGradientSpacing)

    self.headerTitleView.pin
      .left()
      .before(of: self.closeButton)
      .vCenter(to: self.closeButton.edge.vCenter)
      .marginHorizontal(Self.horizontalSpacing)
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
      let model = self.model,
      let collectionViewLayout = self.contentCollection.collectionViewLayout as? UICollectionViewFlowLayout,
      collectionViewLayout.estimatedItemSize == .zero // avoid multiple adjust iteration
    else {
      return
    }

    collectionViewLayout.estimatedItemSize = CGSize(
      width: self.contentCollection.frame.width,
      height: 150
    )

    if model.content.isActionButtonVisible {
      let actionButtonSpaceFromBottom = self.frame.height - self.actionButton.frame.origin.y
      self.contentCollection.contentInset = UIEdgeInsets(
        top: 80,
        left: 0,
        bottom: actionButtonSpaceFromBottom + Self.buttonToGradientSpacing,
        right: 0
      )
    } else {
      self.contentCollection.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)
    }

    if self.contentCollectionCanScroll && model.content.isActionButtonVisible {
      self.gradientView.alpha = 1.0
    } else {
      self.gradientView.alpha = 0.0
    }
  }
}

// MARK: Helpers

extension PermissionTutorialView {
  var contentCollectionCanScroll: Bool {
    return self.contentCollection.contentSize.height > self.contentCollection.frame.height
  }
}

// MARK: UICollectionViewDataSource

extension PermissionTutorialView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.model?.content.items.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard
      let model = self.model,
      let item = model.content.items[safe: indexPath.row]
    else {
      AppLogger.fatalError("This should never happen")
    }

    switch item {
    case .title:
      return self.dequeue(ContentCollectionTitleCell.self, for: indexPath, in: collectionView, using: model.cellVM(for: item))

    case .textualContent:
      return self.dequeue(ContentCollectionTextCell.self, for: indexPath, in: collectionView, using: model.cellVM(for: item))

    case .animationContent:
      return self.dequeue(
        ContentCollectionAnimationCell.self,
        for: indexPath,
        in: collectionView,
        using: model.cellVM(for: item)
      )

    case .imageContent:
      return self.dequeue(ContentCollectionImageCell.self, for: indexPath, in: collectionView, using: model.cellVM(for: item))

    case .textAndImage:
      return self.dequeue(
        ContentCollectionTextAndImageCell.self,
        for: indexPath,
        in: collectionView,
        using: model.cellVM(for: item)
      )

    case .spacer:
      return self.dequeue(ContentCollectionSpacer.self, for: indexPath, in: collectionView, using: model.cellVM(for: item))

    case .scrollableButton:
      let cell = self.dequeue(
        ContentCollectionButtonCell.self,
        for: indexPath,
        in: collectionView,
        using: model.cellVM(for: item)
      )
      cell.userDidTapButton = { [weak self] in
        self?.userDidTapActionButton?()
      }

      return cell
    }
  }

  private func dequeue<Cell: ModellableView & ReusableView & UICollectionViewCell>(
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

extension PermissionTutorialView: UICollectionViewDelegateFlowLayout {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.userDidScroll?(scrollView.contentOffset.y)
  }

  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.willStartScrollAnimation?()
  }

  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard !decelerate else {
      return
    }

    self.didEndScrollAnimation?()
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.didEndScrollAnimation?()
  }
}

// MARK: Style

private extension PermissionTutorialView {
  enum Style {
    static func collectionView(_ collection: UICollectionView) {
      collection.backgroundColor = Palette.grayWhite
      collection.showsVerticalScrollIndicator = false
      let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout
      layout?.minimumLineSpacing = 0
    }

    static func background(_ view: UIView) {
      view.backgroundColor = Palette.grayWhite
    }

    static func closeButton(_ btn: ImageButton) {
      SharedStyle.closeButton(btn)
    }

    static func gradient(_ gradientView: GradientView) {
      gradientView.isUserInteractionEnabled = false
      gradientView.gradient = Palette.gradientScrollOverlay
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
