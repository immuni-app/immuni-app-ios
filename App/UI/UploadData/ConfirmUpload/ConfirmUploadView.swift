// ConfirmUploadView.swift
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

struct ConfirmUploadVM: ViewModelWithLocalState {
  /// The kind of data that are going to be uploaded.
  let dataKindsInfo: [ConfirmUploadLS.DataKind]

  func shouldReloadCollection(oldModel: ConfirmUploadVM?) -> Bool {
    guard let oldModel = oldModel else {
      return true
    }

    return self.dataKindsInfo != oldModel.dataKindsInfo
  }

  func cellModel(for index: Int) -> ViewModel? {
    guard let cellKind = self.dataKindsInfo[safe: index] else {
      return nil
    }
    return ConfirmUploadCellVM(kind: cellKind)
  }
}

extension ConfirmUploadVM {
  init?(state: AppState?, localState: ConfirmUploadLS) {
    self.dataKindsInfo = localState.dataKindsInfo
  }
}

// MARK: - View

class ConfirmUploadView: UIView, ViewControllerModellableView {
  typealias VM = ConfirmUploadVM

  private let footer = UIView()
  private let footerMessage = UILabel()
  let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

  private var actionButton = ButtonWithInsets()
  private var closeButton = ImageButton()

  var didTapAction: Interaction?
  var didTapClose: Interaction?

  // MARK: - Setup

  func setup() {
    self.addSubview(self.collection)
    self.addSubview(self.footer)
    self.addSubview(self.footerMessage)
    self.addSubview(self.actionButton)
    self.addSubview(self.closeButton)

    self.actionButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapAction?()
    }
    self.closeButton.on(.touchUpInside) { [weak self] _ in
      self?.didTapClose?()
    }

    self.collection.register(ConfirmUploadTitleCell.self)
    self.collection.register(ConfirmUploadCell.self)

    self.collection.delegate = self
    self.collection.dataSource = self
  }

  // MARK: - Style

  func style() {
    Self.Style.background(self)
    Self.Style.footer(self.footer)
    Self.Style.footerMessage(self.footerMessage)
    Self.Style.collection(self.collection)
    SharedStyle.closeButton(self.closeButton)
    SharedStyle.primaryButton(self.actionButton, title: L10n.ConfirmData.Button.title)
  }

  // MARK: - Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }

    if model.shouldReloadCollection(oldModel: oldModel) {
      self.collection.reloadData()
    }
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.closeButton.pin
      .top(30 + self.safeAreaInsets.top)
      .right(28)
      .sizeToFit()

    self.actionButton.pin
      .width(min(self.bounds.width - 30 * 2, 315))
      .hCenter()
      .sizeToFit(.width)
      .minHeight(55)
      .bottom(20 + self.safeAreaInsets.bottom)

    self.footerMessage.pin
      .horizontally(45)
      .sizeToFit(.width)
      .above(of: self.actionButton)
      .marginBottom(27)

    self.footer.pin
      .horizontally()
      .bottom()
      .top(to: self.footerMessage.edge.top)
      .marginTop(-28)

    self.collection.pin
      .horizontally()
      .top()
      .above(of: self.footer)
      .marginBottom(-30)

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
  }
}

// MARK: - Style

private extension ConfirmUploadView {
  enum Style {
    static func background(_ view: UIView) {
      view.backgroundColor = Palette.grayWhite
    }

    static func footer(_ view: UIView) {
      view.backgroundColor = Palette.white
      view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
      view.layer.cornerRadius = SharedStyle.cardCornerRadius
      view.addShadow(.headerLightBlue)
    }

    static func collection(_ collectionView: UICollectionView) {
      collectionView.backgroundColor = .clear
      collectionView.contentInset = UIEdgeInsets(top: 70, left: 0, bottom: 50, right: 0)
      collectionView.showsVerticalScrollIndicator = false
    }

    static func footerMessage(_ label: UILabel) {
      let content = L10n.ConfirmData.footerMessage
      let textStyle = TextStyles.p.byAdding(
        .color(Palette.grayNormal),
        .alignment(.center)
      )

      TempuraStyles.styleStandardLabel(
        label,
        content: content,
        style: textStyle
      )
    }
  }
}

// MARK: - UICollectionViewDataSource

extension ConfirmUploadView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return (self.model?.dataKindsInfo.count ?? 0) + 1
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard indexPath.item > 0 else {
      let cell = collectionView.dequeueReusableCell(ConfirmUploadTitleCell.self, for: indexPath)
      return cell
    }

    guard
      let model = self.model,
      let cellModel = model.cellModel(for: indexPath.item - 1)
    else {
      return UICollectionViewCell()
    }

    let cell = collectionView.dequeueReusableCell(ConfirmUploadCell.self, for: indexPath)
    cell.model = cellModel as? ConfirmUploadCellVM
    return cell
  }
}
