// CustomerSupportVM.swift
// Copyright (C) 2021 Presidenza del Consiglio dei Ministri.
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

import Alamofire
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
      return ContentCollectionTextCellVM(content: content, useDarkStyle: true)
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
  static let headingCells: [CellType] = [
    .title(L10n.Support.title),
    .spacer(.medium),
    .textualContent(L10n.Support.Faq.description),
    .button("", L10n.Support.Faq.action),
    .spacer(.big)
  ]

  static func cells(
    supportPhone: String?,
    supportPhoneOpeningTime: String?,
    supportPhoneClosingTime: String?,
    supportEmail: String?,
    osVersion: String,
    deviceModel: String,
    exposureNotificationEnabled: Bool,
    bluetoothEnabled: Bool,
    appVersion: String,
    networkReachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus,
    lastENCheck: Date?
  ) -> [CellType] {
    // heading cells
    var cells = CustomerSupportVM.headingCells

    let hasPhoneContact = supportPhone != nil && supportPhoneOpeningTime != nil && supportPhoneClosingTime != nil
    let hasEmailContact = supportEmail != nil

    if hasPhoneContact || hasEmailContact {
      cells.append(contentsOf: [
        .separator,
        .spacer(.big),
        .textualContent(L10n.Support.contactSupport),
        .spacer(.small)
      ])
    }

    // email contact
    if let email = supportEmail {
      cells.append(contentsOf: [
        .contact(.email(email: email)),
        .spacer(.small)
      ])
    }

    // info header
    cells.append(contentsOf: [
      .separator,
      .spacer(.small),
      .infoHeader(L10n.Support.Info.title)
    ])

    // info
    let lastENCheckString = lastENCheck?.asFormattedLastENCheck ?? L10n.Support.Info.Item.LastENCheck.none

    cells.append(contentsOf: [
      .info(L10n.Support.Info.Item.os, osVersion),
      .info(L10n.Support.Info.Item.device, deviceModel),
      .info(
        L10n.Support.Info.Item.exposureNotificationEnabled,
        exposureNotificationEnabled ?
          L10n.Support.Info.ExposureNotifications.active : L10n.Support.Info.ExposureNotifications.inactive
      ),
      .info(
        L10n.Support.Info.Item.bluetoothEnabled,
        bluetoothEnabled ? L10n.Support.Info.Bluetooth.active : L10n.Support.Info.Bluetooth.inactive
      ),
      .info(L10n.Support.Info.Item.appVersion, appVersion),
      .info(L10n.Support.Info.Item.connectionType, networkReachabilityStatus.description),
      .info(L10n.Support.Info.Item.lastENCheck, lastENCheckString)
    ])

    return cells
  }

  init?(state: AppState?, localState: CustomerSupportLS) {
    guard let state = state else {
      return nil
    }

    self.cells = CustomerSupportVM.cells(
      supportPhone: state.configuration.supportPhone,
      supportPhoneOpeningTime: state.configuration.supportPhoneOpeningTime,
      supportPhoneClosingTime: state.configuration.supportPhoneClosingTime,
      supportEmail: state.configuration.supportEmail,
      osVersion: state.environment.osVersion,
      deviceModel: state.environment.deviceModel,
      exposureNotificationEnabled: state.environment.exposureNotificationAuthorizationStatus.isAuthorized,
      bluetoothEnabled: state.environment.exposureNotificationAuthorizationStatus.canPerformDetection,
      appVersion: state.environment.appVersion,
      networkReachabilityStatus: state.environment.networkReachabilityStatus,
      lastENCheck: state.exposureDetection.lastDetectionDate
    )

    self.isHeaderVisible = localState.isHeaderVisible
  }
}

extension NetworkReachabilityManager.NetworkReachabilityStatus {
  var description: String {
    switch self {
    case .unknown:
      return "-"
    case .notReachable:
      return L10n.Support.Info.Item.ConnectionType.none
    case .reachable(let kind):
      switch kind {
      case .ethernetOrWiFi:
        return L10n.Support.Info.Item.ConnectionType.wifi
      case .cellular:
        return L10n.Support.Info.Item.ConnectionType.mobile
      }
    }
  }
}

// MARK: Helpers

extension Date {
  private static var timeFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
  }

  private static var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
  }

  /// Returns a localized, human readable, string that represents
  /// the last EN check
  var asFormattedLastENCheck: String {
    let formattedDate = Self.dateFormatter.string(from: self)
    let formattedTime = Self.timeFormatter.string(from: self)
    return L10n.Support.Info.Item.LastENCheck.date(formattedDate, formattedTime)
  }
}
