// CustomerSupportVM.swift
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

struct CustomerSupportVM: ViewModelWithLocalState {
  enum CellType: Equatable {
    case title(String)
    case textualContent(String)
    case button(String, String)
    case separator
    case spacer(ContentCollectionSpacerVM.Size)
    case contact(CustomerSupportContactCellVM.Kind)
    case infoHeader(String)
    case info(String, String)
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

  func cellVM(for item: CellType, isLastCell: Bool) -> ViewModel? {
    switch item {
    case .title(let title):
      return ContentCollectionTitleCellVM(content: title)
    case .textualContent(let content):
      return ContentCollectionTextCellVM(content: content)
    case .button(let description, let title):
      return ContentCollectionButtonCellVM(description: description, buttonTitle: title)
    case .separator:
      return ContentCollectionImageCellVM(content: Asset.Common.separator.image)
    case .spacer(let size):
      return ContentCollectionSpacerVM(size: size)
    case .contact(let kind):
      return CustomerSupportContactCellVM(kind: kind)
    case .infoHeader(let title):
      return CustomerSupportInfoHeaderCellVM(title: title)
    case .info(let info, let value):
      return CustomerSupportInfoCellVM(info: info, value: value, shouldShowSeparator: !isLastCell)
    }
  }
}

extension CustomerSupportVM {
  static let cells: [CellType] = [
    .title(L10n.Support.title),
    .spacer(.medium),
    .textualContent(L10n.Support.Faq.description),
    .button("", L10n.Support.Faq.action),
    .spacer(.big),
    .separator,
    .spacer(.big),
    .textualContent(L10n.Support.contactSupport),
    .spacer(.small),
    .contact(.phone),
    .spacer(.tiny),
    .contact(.email),
    .spacer(.small),
    .separator,
    .spacer(.small),
    .infoHeader(L10n.Support.Info.title)
  ]

  init?(state: AppState?, localState: CustomerSupportLS) {
    var cells = CustomerSupportVM.cells
    cells.append(contentsOf: [
      .info(L10n.Support.Info.Item.os, "iOS 13.1.5"),
      .info(L10n.Support.Info.Item.device, "iPhone XS"),
      .info(L10n.Support.Info.Item.exposureNotificationEnabled, "Attive"),
      .info(L10n.Support.Info.Item.bluetoothEnabled, "Attivo"),
      .info(L10n.Support.Info.Item.appVersion, "1.0.0 (23)"),
      .info(L10n.Support.Info.Item.connectionType, "WiFi")
    ])
    self.cells = cells
    self.isHeaderVisible = localState.isHeaderVisible
  }
}
