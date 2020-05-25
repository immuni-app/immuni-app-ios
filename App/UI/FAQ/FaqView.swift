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

  func shouldUpdateHeader(oldModel: FaqVM?) -> Bool {
    return self.isHeaderVisible != oldModel?.isHeaderVisible
  }

  func shouldReloadCollection(oldModel: FaqVM?) -> Bool {
    guard let oldModel = oldModel else {
      return true
    }

    return self.faqs != oldModel.faqs
  }

  func cellModel(for indexPath: IndexPath) -> ViewModel? {
    guard let faq = self.faqs[safe: indexPath.item] else {
      return nil
    }
    return FaqCellVM(faq: faq)
  }

  var shouldShowBackButton: Bool { !self.isPresentedModally }
  var shouldShowCloseButton: Bool { self.isPresentedModally }
}

extension FaqVM {
  init?(state: AppState?, localState: FAQLS) {
    guard let state = state else {
      return nil
    }

    self.faqs = state.faq.faqs(for: state.environment.userLanguage)
    self.isPresentedModally = localState.isPresentedModally
    self.isHeaderVisible = localState.isHeaderVisible
  }
}

// MARK: - View

class FaqView: UIView, ViewControllerModellableView {
  typealias VM = FaqVM

  private static let horizontalSpacing: CGFloat = 30.0

  private let backgroundGradientView = GradientView()
  private let headerView = UIView()
  private let title = UILabel()
  private var backButton = ImageButton()
  private var closeButton = ImageButton()
  let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

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

    self.backButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapBack?()
    }

    self.closeButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapBack?()
    }

    self.collection.register(FaqCell.self)

    self.collection.delegate = self
    self.collection.dataSource = self
  }

  // MARK: - Style

  func style() {
    Self.Style.background(self)
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
      }
    }

    self.backButton.alpha = model.shouldShowBackButton.cgFloat
    self.closeButton.alpha = model.shouldShowCloseButton.cgFloat
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

    self.headerView.pin
      .left()
      .top()
      .right()
      .height(self.title.frame.maxY + 20)

    self.collection.pin
      .horizontally()
      .below(of: self.title)
      .marginTop(5)
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
    static func background(_ view: UIView) {
      view.backgroundColor = Palette.grayWhite
    }

    static func backgroundGradient(_ gradientView: GradientView) {
      gradientView.isUserInteractionEnabled = false
      gradientView.gradient = Palette.gradientBackgroundBlueOnBottom
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

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.userDidScroll?(scrollView.contentOffset.y)
  }
}
