// SuggestionView.swift
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

class SuggestionsView: UIView, ViewControllerModellableView {
  typealias VM = SuggestionsVM

  static let cellMessageInset: CGFloat = 30
  static let cellContainerInset: CGFloat = 25

  private let background = GradientView()
  let collection = UICollectionView(frame: .zero, collectionViewLayout: CollectionWithStickyCellsLayout())
  private let headerContainer = UIView()
  let headerView = GradientView()
  private let headerTitleView = UILabel()
  private var closeButton = ImageButton()

  var didTapClose: Interaction?
  var userDidScroll: CustomInteraction<CGFloat>?
  var didTapCollectionButton: CustomInteraction<SuggestionsButtonCellVM.ButtonInteraction>?
  var userDidTapURL: CustomInteraction<URL>?
  var didTapDiscoverMoreStayHome: Interaction?

  // MARK: - Setup

  func setup() {
    self.addSubview(self.background)
    self.addSubview(self.collection)
    self.addSubview(self.headerContainer)
    self.addSubview(self.closeButton)
    self.headerContainer.addSubview(self.headerView)
    self.headerView.addSubview(self.headerTitleView)

    self.collection.register(SuggestionsHeaderCell.self)
    self.collection.register(SuggestionsSpacer.self)
    self.collection.register(SuggestionsAlertCell.self)
    self.collection.register(SuggestionsInfoCell.self)
    self.collection.register(SuggestionsMessageCell.self)
    self.collection.register(SuggestionsInstructionCell.self)
    self.collection.register(SuggestionsButtonCell.self)
    self.collection.register(SuggestionsSeparator.self)

    self.collection.delegate = self
    self.collection.dataSource = self

    self.closeButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapClose?()
    }
  }

  // MARK: - Style

  func style() {
    Self.Style.background(self.background)
    Self.Style.collection(self.collection)
    Self.Style.headerContainer(self.headerContainer)
    SharedStyle.closeButton(self.closeButton, color: Palette.white)
  }

  // MARK: - Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    Self.Style.header(self.headerView, gradient: model.headerGradient)
    Self.Style.headerTitle(self.headerTitleView, content: model.headerTitle)

    if model.shouldUpdateHeader(oldModel: oldModel) {
      UIView.update(shouldAnimate: oldModel != nil) {
        self.headerContainer.alpha = model.isHeaderVisible.cgFloat
      }
    }

    if model.shouldReloadCollection(oldModel: oldModel) {
      self.collection.reloadData()
    }
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.background.pin.all()
    self.collection.pin.all()

    self.closeButton.pin
      .top(30 + self.safeAreaInsets.top)
      .right(28)
      .sizeToFit()

    self.headerTitleView.pin
      .left(30)
      .before(of: self.closeButton)
      .vCenter(to: self.closeButton.edge.vCenter)
      .marginRight(15)
      .sizeToFit(.width)

    self.headerContainer.pin
      .left()
      .top()
      .right()
      .height(self.headerTitleView.frame.maxY + 20)

    self.headerView.pin.all()

    self.afterLayout()
  }

  private func afterLayout() {
    guard let collectionViewLayout = self.collection.collectionViewLayout as? UICollectionViewFlowLayout else {
      return
    }
    collectionViewLayout.itemSize = UICollectionViewFlowLayout.automaticSize
    collectionViewLayout.estimatedItemSize = CGSize(width: self.collection.bounds.width, height: 50)
    collectionViewLayout.minimumLineSpacing = 0
  }
}

// MARK: - Style

private extension SuggestionsView {
  enum Style {
    static func background(_ view: GradientView) {
      view.gradient = Palette.gradientBlueOnTop
    }

    static func collection(_ collectionView: UICollectionView) {
      collectionView.backgroundColor = .clear
      collectionView.showsVerticalScrollIndicator = false
    }

    static func headerContainer(_ view: UIView) {
      view.backgroundColor = Palette.purple
      view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.clipsToBounds = true
    }

    static func header(_ view: GradientView, gradient: Gradient?) {
      guard let gradient = gradient else {
        return
      }
      view.gradient = gradient
    }

    static func headerTitle(_ label: UILabel, content: String) {
      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: TextStyles.h4Bold.byAdding(
          .color(Palette.white)
        ),
        numberOfLines: 1
      )
    }
  }
}

// MARK: - UICollectionViewDataSource

extension SuggestionsView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
      return self.dequeue(SuggestionsHeaderCell.self, for: indexPath, in: collectionView, using: cellModel)
    case .spacer:
      return self.dequeue(SuggestionsSpacer.self, for: indexPath, in: collectionView, using: cellModel)
    case .alert:
      return self.dequeue(SuggestionsAlertCell.self, for: indexPath, in: collectionView, using: cellModel)
    case .info:
      return self.dequeue(SuggestionsInfoCell.self, for: indexPath, in: collectionView, using: cellModel)
    case .message:
      let cell = self.dequeue(SuggestionsMessageCell.self, for: indexPath, in: collectionView, using: cellModel)
      cell.userDidTapURL = { [weak self] url in self?.userDidTapURL?(url) }
      return cell
    case .instruction:
      let cell = self.dequeue(SuggestionsInstructionCell.self, for: indexPath, in: collectionView, using: cellModel)
      cell.didTapDiscoverMoreStayHome = { [weak self] in self?.didTapDiscoverMoreStayHome?() }
      return cell
    case .button:
      let cell = self.dequeue(SuggestionsButtonCell.self, for: indexPath, in: collectionView, using: cellModel)
      cell.didTapButton = { [weak self] interaction in
        self?.didTapCollectionButton?(interaction)
      }
      return cell
    case .separator:
      return self.dequeue(SuggestionsSeparator.self, for: indexPath, in: collectionView, using: cellModel)
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

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.userDidScroll?(scrollView.contentOffset.y)
  }

  /// The size of the header if collection is not scrolled
  var headerDefaultSize: CGFloat {
    return self.collection
      .cellForItem(at: IndexPath(item: 0, section: 0))?
      .sizeThatFits(CGSize(width: self.bounds.width, height: .infinity))
      .height ?? 100
  }

  /// The minimum size of the header
  var headerMinHeight: CGFloat {
    return (
      self.collection
        .cellForItem(at: IndexPath(item: 0, section: 0)) as? StickyCell
    )?
      .minimumHeight ?? 77
  }
}
