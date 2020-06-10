// FaqView.swift
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

struct FaqVM: ViewModelWithLocalState {
  /// The list of FAQ to show
  let faqs: [FAQ]
  /// Whether the view is presented modally. This will change the back/close button visibility.
  let isPresentedModally: Bool
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  let isHeaderVisible: Bool
  /// Whether the user is actively searching through the search bar.
  let isSearching: Bool
  /// The currently searching string.
  let searchFilter: String

  func shouldUpdateHeader(oldModel: FaqVM?) -> Bool {
    return self.isHeaderVisible != oldModel?.isHeaderVisible
  }

  func shouldUpdateSearchStatus(oldModel: FaqVM?) -> Bool {
    return self.isSearching != oldModel?.isSearching
  }

  func shouldReloadCollection(oldModel: FaqVM?) -> Bool {
    guard let oldModel = oldModel else {
      return true
    }

    if self.faqs != oldModel.faqs {
      return true
    }

    if self.searchFilter != oldModel.searchFilter {
      return true
    }

    return false
  }

  func cellModel(for indexPath: IndexPath) -> ViewModel? {
    guard let faq = self.faqs[safe: indexPath.item] else {
      return nil
    }
    return FaqCellVM(faq: faq, searchFilter: self.searchFilter)
  }

  var searchBarVM: SearchBarVM { SearchBarVM(isSearching: self.isSearching) }
  var shouldShowSeparator: Bool { !self.isHeaderVisible }
  var shouldShowTitle: Bool { !self.isSearching }
  var shouldShowBackButton: Bool { !self.isPresentedModally && !self.isSearching }
  var shouldShowCloseButton: Bool { self.isPresentedModally && !self.isSearching }
}

extension FaqVM {
  init?(state: AppState?, localState: FAQLS) {
    guard
      let state = state,
      let faqs = state.faq.faqs(for: state.environment.userLanguage)
      else {
        return nil
    }

    if localState.searchFilter.isEmpty {
      self.faqs = faqs
    } else {
      let exactMatching = faqs.filter { $0.title.lowercased().contains(localState.searchFilter.lowercased()) }
      let fuzzyMatching = faqs.filter {
        !exactMatching.contains($0) &&
          (
            $0.title.lowercased().fuzzyContains(localState.searchFilter.lowercased()) ||
              $0.content.lowercased().contains(localState.searchFilter.lowercased())
          )
      }
      self.faqs = exactMatching + fuzzyMatching
    }

    self.isPresentedModally = localState.isPresentedModally
    self.isHeaderVisible = localState.isHeaderVisible
    self.isSearching = localState.isSearching
    self.searchFilter = localState.searchFilter
  }
}

// MARK: - View

class FaqView: UIView, ViewControllerModellableView {
  typealias VM = FaqVM

  private static let horizontalSpacing: CGFloat = 30.0

  private let backgroundGradientView = GradientView()
  private let searchBar = SearchBar()
  private let separator = UIImageView()
  private let headerView = UIView()
  private let title = UILabel()
  private var backButton = ImageButton()
  private var closeButton = ImageButton()
  let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

  var didChangeSearchStatus: CustomInteraction<Bool>?
  var didChangeSearchedValue: CustomInteraction<String>?
  var didTapBack: Interaction?
  var didTapCell: CustomInteraction<FAQ>?
  var userDidScroll: CustomInteraction<CGFloat>?

  // MARK: - Setup

  func setup() {
    self.addSubview(self.backgroundGradientView)
    self.addSubview(self.collection)
    self.addSubview(self.headerView)
    self.addSubview(self.title)
    self.addSubview(self.backButton)
    self.addSubview(self.closeButton)
    self.addSubview(self.searchBar)
    self.addSubview(self.separator)

    self.backButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapBack?()
    }

    self.closeButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapBack?()
    }

    self.searchBar.didChangeSearchStatus = { [weak self] isSearching in
      self?.didChangeSearchStatus?(isSearching)
    }
    self.searchBar.didChangeSearchedValue = { [weak self] value in
      self?.didChangeSearchedValue?(value)
    }

    self.collection.register(FaqCell.self)
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapCollection))
    self.collection.addGestureRecognizer(tapGesture)

    self.collection.delegate = self
    self.collection.dataSource = self
  }

  @objc func didTapCollection() {
    self.searchBar.resignFirstResponder()
  }

  // MARK: - Style

  func style() {
    Self.Style.separator(self.separator)
    Self.Style.backgroundGradient(self.backgroundGradientView)
    Self.Style.header(self.headerView)
    Self.Style.collection(self.collection)
    Self.Style.title(self.title)

    SharedStyle.navigationBackButton(self.backButton)
    SharedStyle.closeButton(self.closeButton)
  }

  // MARK: - Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    if model.shouldReloadCollection(oldModel: oldModel) {
      self.collection.reloadData()
    }

    if model.shouldUpdateHeader(oldModel: oldModel) {
      UIView.update(shouldAnimate: oldModel != nil) {
        self.headerView.alpha = model.isHeaderVisible.cgFloat
        self.separator.alpha = model.shouldShowSeparator.cgFloat
      }
    }

    if model.shouldUpdateSearchStatus(oldModel: oldModel) {
      self.searchBar.model = model.searchBarVM

      let contentOffset = self.collection.contentOffset
      self.setNeedsLayout()
      UIView.update(shouldAnimate: oldModel != nil) {
        self.title.alpha = model.shouldShowTitle.cgFloat
        self.backButton.alpha = model.shouldShowBackButton.cgFloat
        self.closeButton.alpha = model.shouldShowCloseButton.cgFloat
        self.layoutIfNeeded()
        self.collection.setContentOffset(contentOffset, animated: false)
      }
    }
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.backgroundGradientView.pin.all()

    self.backButton.pin
      .left(Self.horizontalSpacing)
      .top(self.universalSafeAreaInsets.top + 20)
      .sizeToFit()

    self.title.pin
      .vCenter(to: self.backButton.edge.vCenter)
      .horizontally(Self.horizontalSpacing + self.backButton.intrinsicContentSize.width + 5)
      .sizeToFit(.width)

    let isSearching = self.model?.isSearching ?? false
    if isSearching {
      self.searchBar.pin
        .horizontally()
        .vCenter(to: self.backButton.edge.vCenter)
        .height(50)
    } else {
      self.searchBar.pin
        .horizontally()
        .below(of: self.title)
        .marginTop(25)
        .height(50)
    }

    self.separator.pin
      .horizontally(25)
      .below(of: self.searchBar)
      .marginTop(25)
      .height(1)

    self.headerView.pin
      .left()
      .top()
      .right()
      .bottom(to: self.separator.edge.bottom)

    self.collection.pin
      .horizontally()
      .below(of: self.separator)
      .bottom(self.universalSafeAreaInsets.bottom)

    self.closeButton.pin
      .sizeToFit()
      .vCenter(to: self.title.edge.vCenter)
      .right(28)

    self.updateAfterLayout()
  }

  private func updateAfterLayout() {
    guard let collectionViewLayout = self.collection.collectionViewLayout as? UICollectionViewFlowLayout else {
      return
    }
    collectionViewLayout.itemSize = UICollectionViewFlowLayout.automaticSize
    collectionViewLayout.estimatedItemSize = CGSize(width: self.collection.bounds.width, height: 50)
    collectionViewLayout.minimumLineSpacing = 0
  }
}

// MARK: - Style

private extension FaqView {
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
      collectionView.contentInset = UIEdgeInsets(top: 18, left: 0, bottom: 50, right: 0)
      collectionView.showsVerticalScrollIndicator = false
    }

    static func title(_ label: UILabel) {
      let content = L10n.Settings.Setting.faq
      TempuraStyles.styleShrinkableLabel(
        label,
        content: content,
        style: TextStyles.navbarSmallTitle.byAdding(
          .color(Palette.grayDark),
          .alignment(.center)
        ),
        numberOfLines: 1
      )
    }
  }
}

// MARK: - UICollectionViewDataSource

extension FaqView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.model?.faqs.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard
      let model = self.model,
      let cellModel = model.cellModel(for: indexPath)
      else {
        return UICollectionViewCell()
    }

    let cell = collectionView.dequeueReusableCell(FaqCell.self, for: indexPath)
    cell.model = cellModel as? FaqCellVM
    cell.didTapCell = { [weak self] faq in
      self?.didTapCell?(faq)
    }
    return cell
  }

  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.searchBar.resignFirstResponder()
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.userDidScroll?(scrollView.contentOffset.y)
  }
}
