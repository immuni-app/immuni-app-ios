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
  enum CellType: Equatable {
    case textualContent(String)
    case button
    case separator
    case spacer
    case contact
  }

  /// The array of cells in the collection.
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

  func cellVM(for item: CellType) -> ViewModel? {
    switch item {
    case .textualContent(let content):
      return ContentCollectionTextCellVM(content: content)
    case .button:
      return nil
    case .separator:
      return nil
    case .spacer:
      return nil
    case .contact:
      return nil
    }
  }
}

extension CustomerSupportVM {
  init?(state: AppState?, localState: CustomerSupportLS) {
    self.cells = [
      .textualContent(L10n.PermissionTutorial.Notifications.first),
      .textualContent(L10n.PermissionTutorial.Notifications.second)
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

    collection.register(ContentCollectionTextCell.self)

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
    case .textualContent:
      return self.dequeue(ContentCollectionTextCell.self, for: indexPath, in: collectionView, using: model.cellVM(for: item))
    case .button:
      return self.dequeue(ContentCollectionButtonCell.self, for: indexPath, in: collectionView, using: model.cellVM(for: item))
    case .separator:
      return self.dequeue(ContentCollectionImageCell.self, for: indexPath, in: collectionView, using: model.cellVM(for: item))
    case .spacer:
      return self.dequeue(ContentCollectionSpacer.self, for: indexPath, in: collectionView, using: model.cellVM(for: item))
    case .contact:
      return self.dequeue(ContentCollectionTextCell.self, for: indexPath, in: collectionView, using: model.cellVM(for: item))
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
