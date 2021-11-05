// CustomerSupportView.swift
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
import Tempura

// MARK: - View

class CustomerSupportView: UIView, ViewControllerModellableView {
  typealias VM = CustomerSupportVM

  private static let buttonToGradientSpacing: CGFloat = 50.0
  private static let horizontalSpacing: CGFloat = 30.0

  // MARK: Interactions

  var userDidTapClose: Interaction?
  var userDidTapActionButton: Interaction?
  var userDidTapContact: CustomInteraction<CustomerSupportContactCellVM.Kind>?
  var userDidScroll: CustomInteraction<CGFloat>?

  lazy var contentCollection: UICollectionView = {
    let collection = UICollectionView(frame: .zero, collectionViewLayout: CollectionWithShadowLayout())
    collection.delegate = self
    collection.dataSource = self

    collection.register(ContentCollectionTitleCell.self)
    collection.register(ContentCollectionTextCell.self)
    collection.register(ContentCollectionImageCell.self)
    collection.register(ContentCollectionSpacer.self)
    collection.register(ContentCollectionButtonCell.self)
    collection.register(CustomerSupportContactCell.self)
    collection.register(CustomerSupportInfoHeaderCell.self)
    collection.register(CustomerSupportInfoCell.self)

    return collection
  }()

  private var closeButton = ImageButton()

  private let headerView = UIView()
  private let headerTitleView = UILabel()

  // MARK: - Setup

  func setup() {
    self.addSubview(self.contentCollection)
    self.addSubview(self.headerView)
    self.addSubview(self.closeButton)

    self.headerView.addSubview(self.headerTitleView)

    self.closeButton.on(.touchUpInside) { [weak self] _ in
      self?.userDidTapClose?()
    }
  }

  // MARK: - Style

  func style() {
    Self.Style.collectionView(self.contentCollection)
    Self.Style.background(self)
    Self.Style.closeButton(self.closeButton)
    Self.Style.header(self.headerView)
  }

  // MARK: - Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    if model.shouldReloadCollection(oldVM: oldModel) {
      self.contentCollection.updateDecoratedCellPaths {
        model.cellVM(for: model.cells[$0.item], isLastCell: false) is CellWithShadow
      }
      self.contentCollection.reloadData()
    }

    Self.Style.headerTitle(self.headerTitleView, content: L10n.Settings.Setting.contactSupport)

    if model.shouldUpdateHeader(oldVM: oldModel) {
      UIView.update(shouldAnimate: oldModel != nil) {
        self.headerView.alpha = model.isHeaderVisible.cgFloat
      }
    }
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.contentCollection.pin.all()

    self.closeButton.pin
      .top(30)
      .right(28)
      .sizeToFit()

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
      let collectionViewLayout = self.contentCollection.collectionViewLayout as? UICollectionViewFlowLayout,
      collectionViewLayout.estimatedItemSize == .zero // avoid multiple adjust iteration
    else {
      return
    }

    collectionViewLayout.estimatedItemSize = CGSize(
      width: self.contentCollection.frame.width,
      height: 150
    )

    self.contentCollection.contentInset = UIEdgeInsets(
      top: 80,
      left: 0,
      bottom: self.safeAreaInsets.bottom + 40,
      right: 0
    )
  }
}

// MARK: UICollectionViewDataSource

extension CustomerSupportView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.model?.cells.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard
      let model = self.model,
      let item = model.cells[safe: indexPath.row]
    else {
      AppLogger.fatalError("This should never happen")
    }

    let isLastCell = indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1

    switch item {
    case .title:
      return self.dequeue(
        ContentCollectionTitleCell.self,
        for: indexPath,
        in: collectionView,
        using: model.cellVM(for: item, isLastCell: isLastCell)
      )
    case .textualContent:
      return self.dequeue(
        ContentCollectionTextCell.self,
        for: indexPath,
        in: collectionView,
        using: model.cellVM(for: item, isLastCell: isLastCell)
      )
    case .button:
      let cell = self.dequeue(
        ContentCollectionButtonCell.self,
        for: indexPath,
        in: collectionView,
        using: model.cellVM(for: item, isLastCell: isLastCell)
      )
      cell.userDidTapButton = { [weak self] in
        self?.userDidTapActionButton?()
      }

      return cell
    case .separator:
      return self.dequeue(
        ContentCollectionImageCell.self,
        for: indexPath,
        in: collectionView,
        using: model.cellVM(for: item, isLastCell: isLastCell)
      )
    case .spacer:
      return self.dequeue(
        ContentCollectionSpacer.self,
        for: indexPath,
        in: collectionView,
        using: model.cellVM(for: item, isLastCell: isLastCell)
      )
    case .contact:
      let cell = self.dequeue(
        CustomerSupportContactCell.self,
        for: indexPath,
        in: collectionView,
        using: model.cellVM(for: item, isLastCell: isLastCell)
      )
      cell.didTapContact = { [weak self] contact in
        self?.userDidTapContact?(contact)
      }

      return cell
    case .infoHeader:
      return self.dequeue(
        CustomerSupportInfoHeaderCell.self,
        for: indexPath,
        in: collectionView,
        using: model.cellVM(for: item, isLastCell: isLastCell)
      )
    case .info:
      return self.dequeue(
        CustomerSupportInfoCell.self,
        for: indexPath,
        in: collectionView,
        using: model.cellVM(for: item, isLastCell: isLastCell)
      )
    }
  }

  private func dequeue<Cell: ModellableView & ReusableView & UICollectionViewCell>(
    _ type: Cell.Type,
    for indexPath: IndexPath,
    in collectionView: UICollectionView,
    using viewModel: ViewModel?
  ) -> Cell {
    let cell = collectionView.dequeueReusableCell(Cell.self, for: indexPath)
    cell.model = viewModel as? Cell.VM
    return cell
  }
}

// MARK: UICollectionViewDelegate

extension CustomerSupportView: UICollectionViewDelegateFlowLayout {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.userDidScroll?(scrollView.contentOffset.y)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: false)
    guard let cellType = self.model?.cells[safe: indexPath.item] else {
      return
    }

    switch cellType {
    case .title, .textualContent, .button, .separator, .spacer, .infoHeader, .info:
      return
    case .contact(let kind):
      self.userDidTapContact?(kind)
    }
  }
}

// MARK: Style

private extension CustomerSupportView {
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
