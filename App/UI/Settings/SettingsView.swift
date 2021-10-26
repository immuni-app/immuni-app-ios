// SettingsView.swift
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

struct SettingsVM: ViewModelWithLocalState {
  enum Setting: Equatable {
    case loadData
    case faq
    case tos
    case privacy
    case chageProvince
    case updateCountry
    case shareApp
    case customerSupport
    case leaveReview
    case debugUtilities
  }

  enum Header: Equatable {
    case data
    case info
    case general
  }

  struct Section: Equatable {
    let header: Header
    let settings: [Setting]
  }

  /// The sections containing the info for the cells to be shown in the collection.
  let sections: [Section]
  /// The app name.
  let appName: String
  /// The version of the currently installed app.
  let appVersion: String
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  let isHeaderVisible: Bool

  var footerVM: SettingFooterVM {
    return SettingFooterVM(title: "\(self.appName) \(self.appVersion)")
  }

  func shouldUpdateHeader(oldModel: SettingsVM?) -> Bool {
    guard let oldModel = oldModel else {
      return true
    }

    return self.isHeaderVisible != oldModel.isHeaderVisible
  }

  func shouldReloadCollection(oldModel: SettingsVM?) -> Bool {
    guard let oldModel = oldModel else {
      return true
    }

    return self.sections != oldModel.sections
  }

  func cellModel(for indexPath: IndexPath) -> ViewModel? {
    guard let setting = self.sections[safe: indexPath.section]?.settings[safe: indexPath.item] else {
      return nil
    }
    let isLastSectionCell = self.sections[safe: indexPath.section]?.settings.count == indexPath.item + 1
    return SettingCellVM(setting: setting, shouldShowSeparator: !isLastSectionCell)
  }

  func headerModel(for indexPath: IndexPath) -> ViewModel? {
    guard let header = self.sections[safe: indexPath.section]?.header else {
      return nil
    }
    return SettingHeaderVM(header: header)
  }

  static let defaultSections: [Section] = [
    Section(
      header: .data,
      settings: [.loadData]
    ),

    Section(
      header: .info,
      settings: [.faq, .tos, .privacy]
    ),

    Section(
      header: .general,
      settings: [.shareApp, .customerSupport, .leaveReview, .chageProvince, .updateCountry]
    )
  ]
}

extension SettingsVM {
  init?(state: AppState?, localState: SettingsLS) {
    guard let state = state else {
      return nil
    }

    var sections: [Section] = Self.defaultSections
    #if canImport(DebugMenu)
      sections.append(Section(header: .general, settings: [.debugUtilities]))
    #endif

    self.sections = sections

    self.appName = state.environment.appName
    self.appVersion = state.environment.appVersion

    self.isHeaderVisible = localState.isHeaderVisible
  }
}

// MARK: - View

class SettingsView: UIView, ViewControllerModellableView {
  typealias VM = SettingsVM
  static let collectionInset: CGFloat = 30
  static let shadowVerticalInset: CGFloat = 10
  private static let horizontalSpacing: CGFloat = 30.0

  private let backgroundGradientView = GradientView()
  let collection = UICollectionView(frame: .zero, collectionViewLayout: CollectionWithShadowLayout())
  private let headerView = UIView()
  private let headerTitle = UILabel()

  var userDidScroll: CustomInteraction<CGFloat>?
  var didTapCell: CustomInteraction<SettingsVM.Setting>?

  // MARK: - Setup

  func setup() {
    self.addSubview(self.backgroundGradientView)
    self.addSubview(self.collection)
    self.addSubview(self.headerView)
    self.addSubview(self.headerTitle)

    self.collection.register(SettingCell.self)
    self.collection.registerHeader(SettingHeader.self)
    self.collection.registerFooter(SettingFooter.self)

    self.collection.delegate = self
    self.collection.dataSource = self
  }

  // MARK: - Style

  func style() {
    Self.Style.backgroundGradient(self.backgroundGradientView)
    Self.Style.background(self)
    Self.Style.collection(self.collection)
    Self.Style.header(self.headerView)
    Self.Style.headerTitle(self.headerTitle)
  }

  // MARK: - Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    if model.shouldReloadCollection(oldModel: oldModel) {
      self.collection.updateDecoratedCellPaths { model.cellModel(for: $0) is CellWithShadow }
      self.collection.reloadData()
    }

    if model.shouldUpdateHeader(oldModel: oldModel) {
      UIView.update(shouldAnimate: oldModel != nil) {
        self.headerView.alpha = model.isHeaderVisible.cgFloat
      }
    }
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.backgroundGradientView.pin.all()

    self.collection.pin
      .horizontally()
      .top(self.safeAreaInsets.top)
      .bottom(self.safeAreaInsets.bottom)

    self.headerTitle.pin
      .top(self.safeAreaInsets.top + 20)
      .horizontally(Self.horizontalSpacing)
      .sizeToFit(.width)

    self.headerView.pin
      .left()
      .top()
      .right()
      .height(self.headerTitle.frame.maxY + 20)

    self.updateAfterLayout()
  }

  private func updateAfterLayout() {
    guard
      let collectionViewLayout = self.collection.collectionViewLayout as? UICollectionViewFlowLayout,
      collectionViewLayout.estimatedItemSize == .zero // avoid multiple adjust iteration
    else {
      return
    }

    collectionViewLayout.itemSize = UICollectionViewFlowLayout.automaticSize
    collectionViewLayout.estimatedItemSize = CGSize(width: self.collection.bounds.width, height: 50)
    collectionViewLayout.minimumLineSpacing = 0

    self.collection.contentInset.top = self.headerTitle.frame.maxY - self.safeAreaInsets.top
    self.collection.contentInset.bottom = 20
  }
}

// MARK: - Style

private extension SettingsView {
  enum Style {
    static func background(_ view: UIView) {
      view.backgroundColor = Palette.grayWhite
    }

    static func backgroundGradient(_ gradientView: GradientView) {
      gradientView.isUserInteractionEnabled = false
      gradientView.gradient = Palette.gradientBackgroundBlueOnBottom
    }

    static func collection(_ collectionView: UICollectionView) {
      collectionView.backgroundColor = .clear
      collectionView.showsVerticalScrollIndicator = false
    }

    static func header(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
      view.layer.cornerRadius = 15.0
      view.addShadow(.headerLightBlue)
    }

    static func headerTitle(_ label: UILabel) {
      let content = L10n.Tabbar.Title.settings
      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: TextStyles.h2Smaller.byAdding(
          .color(Palette.grayDark)
        )
      )
    }
  }
}

// MARK: - UICollectionViewDataSource

extension SettingsView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.model?.sections[safe: section]?.settings.count ?? 0
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return self.model?.sections.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard
      let model = self.model,
      let cellModel = model.cellModel(for: indexPath)
    else {
      return UICollectionViewCell()
    }

    let cell = collectionView.dequeueReusableCell(SettingCell.self, for: indexPath)
    cell.model = cellModel as? SettingCellVM
    cell.didTapCell = { [weak self] setting in
      self?.didTapCell?(setting)
    }
    return cell
  }

  func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    if kind == UICollectionView.elementKindSectionHeader {
      let header = collectionView.dequeueReusableHeader(SettingHeader.self, for: indexPath)
      header.model = self.model?.headerModel(for: indexPath) as? SettingHeaderVM
      return header
    } else if kind == UICollectionView.elementKindSectionFooter {
      let footer = collectionView.dequeueReusableFooter(SettingFooter.self, for: indexPath)
      footer.model = self.model?.footerVM
      return footer
    }

    return UICollectionReusableView()
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForHeaderInSection section: Int
  ) -> CGSize {
    let view = self.collectionView(
      collectionView,
      viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
      at: IndexPath(item: 0, section: section)
    )
    return view.sizeThatFits(
      CGSize(width: collectionView.frame.size.width - collectionView.contentInset.horizontal, height: .infinity)
    )
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForFooterInSection section: Int
  ) -> CGSize {
    guard section + 1 == self.model?.sections.count else {
      return .zero
    }
    let view = self.collectionView(
      collectionView,
      viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter,
      at: IndexPath(item: 0, section: section)
    )
    return view.sizeThatFits(
      CGSize(width: collectionView.frame.size.width - collectionView.contentInset.horizontal, height: .infinity)
    )
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.userDidScroll?(scrollView.contentOffset.y + scrollView.contentInset.top)
  }
}
