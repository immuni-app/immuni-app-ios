// TabbarView.swift
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
import Tempura

// MARK: - View Model

struct TabbarVM: ViewModelWithState {
  enum Tab: Int {
    case home
    case settings

    var selectedImage: UIImage {
      switch self {
      case .home:
        return Asset.Tabbar.homeSelected.image
      case .settings:
        return Asset.Tabbar.settingsSelected.image
      }
    }

    var deselectedImage: UIImage {
      switch self {
      case .home:
        return Asset.Tabbar.homeUnselected.image
      case .settings:
        return Asset.Tabbar.settingsUnselected.image
      }
    }

    var title: String {
      switch self {
      case .home:
        return L10n.Tabbar.Title.home
      case .settings:
        return L10n.Tabbar.Title.settings
      }
    }
  }

  /// The tabbar cells.
  let tabs: [Tab]
  /// The currently selected tab.
  let selectedTab: Tab

  var cellModels: [TabbarCellVM] {
    return self.tabs.map { tab in
      TabbarCellVM(tab: tab, isSelected: tab == self.selectedTab)
    }
  }

  func needToReloadIndexPath(oldModel: TabbarVM?) -> [IndexPath] {
    guard let oldModel = oldModel,
          oldModel.selectedTab != self.selectedTab
    else {
      return []
    }

    return [
      self.tabs.firstIndex(of: oldModel.selectedTab).map { IndexPath(row: $0, section: 0) },
      self.tabs.firstIndex(of: self.selectedTab).map { IndexPath(row: $0, section: 0) }
    ]
    .compactMap { $0 }
  }

  func shouldReloadWholeTabbar(oldModel: TabbarVM?) -> Bool {
    guard let oldModel = oldModel else {
      return true
    }

    return self.tabs != oldModel.tabs
  }
}

extension TabbarVM {
  init(state: AppState) {
    self.tabs = [.home, .settings]
    self.selectedTab = state.environment.selectedTab
  }
}

// MARK: - View

class TabbarView: UIView, ViewControllerModellableView {
  typealias VM = TabbarVM

  /// The tabbar height
  static let tabBarHeight: CGFloat = 69

  let shadow = UIView()
  let container = UIView()
  private lazy var collection: UICollectionView = {
    let layout = UICollectionViewFlowLayout()

    layout.scrollDirection = .horizontal

    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0

    let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collection.delegate = self
    collection.dataSource = self

    collection.register(TabbarCell.self, forCellWithReuseIdentifier: TabbarCell.identifierForReuse)
    return collection
  }()

  var didSelectCell: ((TabbarVM.Tab) -> Void)?

  // MARK: - Setup

  func setup() {
    self.addSubview(self.shadow)
    self.shadow.addSubview(self.container)
    self.addSubview(self.collection)

    self.shadow.isUserInteractionEnabled = false
    self.collection.accessibilityTraits = .tabBar
  }

  // MARK: - Style

  func style() {
    Self.Style.shadow(self.shadow)
    Self.Style.container(self.container)
    Self.Style.collection(self.collection)
  }

  // MARK: - Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    if model.shouldReloadWholeTabbar(oldModel: oldModel) {
      self.collection.reloadData()
    }

    for indexPath in model.needToReloadIndexPath(oldModel: oldModel) {
      let tabbarCell = self.collection.cellForItem(at: indexPath) as? TabbarCell
      tabbarCell?.model = self.model?.cellModels[indexPath.row]
    }
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.collection.pin
      .width(min(700, self.bounds.width)).hCenter()
      .height(TabbarView.tabBarHeight)
      .bottom(self.safeAreaInsets.bottom)

    self.shadow.pin.all()

    self.container.pin
      .width(min(700, self.bounds.width)).hCenter()
      .height(TabbarView.tabBarHeight + self.safeAreaInsets.bottom)
      .bottom()
  }
}

// MARK: - Style

private extension TabbarView {
  enum Style {
    static func container(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    static func shadow(_ view: UIView) {
      view.addShadow(.tabbar)
    }

    static func collection(_ collectionView: UICollectionView) {
      collectionView.backgroundColor = .clear
      collectionView.isScrollEnabled = false
      collectionView.bounces = false
      guard let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
        return
      }
      collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
      collectionViewLayout.minimumLineSpacing = 0
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TabbarView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let tab = self.model?.tabs[indexPath.row] else {
      return
    }

    self.didSelectCell?(tab)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    guard let model = self.model else { return .zero }

    // compute the width of a single cell
    let singleWidth: CGFloat = collectionView.bounds.width / CGFloat(model.tabs.count)
    return CGSize(width: singleWidth, height: TabbarView.tabBarHeight)
  }
}

extension TabbarView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.model?.tabs.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabbarCell.identifierForReuse, for: indexPath)

    guard let typedCell = cell as? TabbarCell else {
      AppLogger.fatalError("cell must conform to TabbarCell")
    }

    typedCell.model = self.model?.cellModels[indexPath.row]
    return typedCell
  }
}
