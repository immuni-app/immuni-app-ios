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
import Foundation
import Tempura

struct CustomerSupportVM: ViewModelWithLocalState {
  typealias CellType = PermissionTutorialVM.Content.Item

  /// ...
  let cells: [CellType]
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  let isHeaderVisible: Bool

  func shouldReloadCollection(oldVM: Self?) -> Bool {
    guard let oldVM = oldVM else {
      return true
    }

    return self.cells != oldVM.cells
  }

  func shouldUpdateHeader(oldVM: Self?) -> Bool {
    guard let oldVM = oldVM else {
      return true
    }

    return self.isHeaderVisible != oldVM.isHeaderVisible
  }

  func cellVM(for item: CellType) -> ViewModel {
    switch item {
    case .title(let title):
      return PermissionTutorialTitleCellVM(content: title)

    case .textualContent(let content):
      return PermissionTutorialTextCellVM(content: content)

    case .animationContent(let animationAsset):
      return PermissionTutorialAnimationCellVM(
        asset: animationAsset,
        shouldPlay: false
      )

    case .imageContent(let image):
      return PermissionTutorialImageCellVM(content: image)

    case .textAndImage(let text, let image, let alignment):
      return PermissionTutorialTextAndImageCellVM(textualContent: text, image: image, alignment: alignment)

    case .spacer(let size):
      return PermissionTutorialSpacerVM(size: size)

    case .scrollableButton(let description, let buttonTitle):
      return PermissionTutorialButtonCellVM(description: description, buttonTitle: buttonTitle)
    }
  }
}

extension CustomerSupportVM {
  init?(state: AppState?, localState: CustomerSupportLS) {
    guard let state = state else {
      return nil
    }

    self.cells = [
      .textualContent(L10n.PermissionTutorial.Notifications.first),
      .spacer(.medium),
      .textualContent(L10n.PermissionTutorial.Notifications.second),
      .imageContent(Asset.PermissionTutorial.notification.image)
    ]
    self.isHeaderVisible = localState.isHeaderVisible
  }
}

// MARK: - View

class CustomerSupportView: UIView, ViewControllerModellableView {
  typealias VM = CustomerSupportVM

  private static let buttonToGradientSpacing: CGFloat = 50.0
  private static let horizontalSpacing: CGFloat = 30.0

  // MARK: Interactions

  var userDidTapClose: Interaction?
  var userDidScroll: CustomInteraction<CGFloat>?

  lazy var contentCollection: UICollectionView = {
    let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    collection.delegate = self
    collection.dataSource = self

    collection.register(PermissionTutorialTitleCell.self)
    collection.register(PermissionTutorialTextCell.self)
    collection.register(PermissionTutorialAnimationCell.self)
    collection.register(PermissionTutorialImageCell.self)
    collection.register(PermissionTutorialTextAndImageCell.self)
    collection.register(PermissionTutorialSpacer.self)
    collection.register(PermissionTutorialButtonCell.self)

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
    guard let collectionViewLayout = self.contentCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
      return
    }

    collectionViewLayout.estimatedItemSize = CGSize(
      width: self.contentCollection.frame.width,
      height: 150
    )

    self.contentCollection.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)
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

    switch item {
    case .title:
      return self.dequeue(PermissionTutorialTitleCell.self, for: indexPath, in: collectionView, using: model.cellVM(for: item))

    case .textualContent:
      return self.dequeue(PermissionTutorialTextCell.self, for: indexPath, in: collectionView, using: model.cellVM(for: item))

    case .animationContent:
      return self.dequeue(
        PermissionTutorialAnimationCell.self,
        for: indexPath,
        in: collectionView,
        using: model.cellVM(for: item)
      )

    case .imageContent:
      return self.dequeue(PermissionTutorialImageCell.self, for: indexPath, in: collectionView, using: model.cellVM(for: item))

    case .textAndImage:
      return self.dequeue(
        PermissionTutorialTextAndImageCell.self,
        for: indexPath,
        in: collectionView,
        using: model.cellVM(for: item)
      )

    case .spacer:
      return self.dequeue(PermissionTutorialSpacer.self, for: indexPath, in: collectionView, using: model.cellVM(for: item))

    case .scrollableButton:
      let cell = self.dequeue(
        PermissionTutorialButtonCell.self,
        for: indexPath,
        in: collectionView,
        using: model.cellVM(for: item)
      )
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

extension CustomerSupportView: UICollectionViewDelegateFlowLayout {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.userDidScroll?(scrollView.contentOffset.y)
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
