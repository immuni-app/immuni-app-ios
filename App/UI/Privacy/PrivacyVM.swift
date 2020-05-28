// PrivacyVM.swift
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
import Katana
import Tempura

struct PrivacyVM {
  /// The items to be shown in the collection
  let items: [CellType]
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  let isHeaderVisible: Bool
  /// The title of the action button.
  let buttonTitle: String
  /// The title to be shown in the header.
  let headerTitle: String

  func shouldReloadCollection(oldVM: Self?) -> Bool {
    guard let oldVM = oldVM else {
      return true
    }

    return self.items != oldVM.items
  }

  func shouldUpdateHeader(oldVM: Self?) -> Bool {
    return self.isHeaderVisible != oldVM?.isHeaderVisible
  }
}

extension PrivacyVM: ViewModelWithLocalState {
  init?(state: AppState?, localState: PrivacyLS) {
    guard let state = state else {
      return nil
    }

    let configuration = state.configuration
    let touURL = configuration.termsOfUseURL(for: state.environment.userLanguage)
    let privacyNoticeURL = configuration.privacyNoticeURL(for: state.environment.userLanguage)

    switch localState.kind {
    case .onboarding:
      self = Self.onboardingPrivacy(
        isHeaderVisible: localState.isHeaderVisible,
        touURL: touURL,
        privacyNoticeURL: privacyNoticeURL,
        isAbove14Checked: localState.isAbove14Checked,
        isAbove14Errored: localState.isAbove14Errored,
        isReadPrivacyNoticeChecked: localState.isReadPrivacyNoticeChecked,
        isReadPrivacyNoticeErrored: localState.isReadPrivacyNoticeErrored
      )

    case .settings:
      self = Self.settingsPrivacy(isHeaderVisible: localState.isHeaderVisible)
    }
  }
}

extension PrivacyVM {
  /// Creates a VM for the Onboarding privacy screen
  static func onboardingPrivacy(
    isHeaderVisible: Bool,
    touURL: URL?,
    privacyNoticeURL: URL?,
    isAbove14Checked: Bool,
    isAbove14Errored: Bool,
    isReadPrivacyNoticeChecked: Bool,
    isReadPrivacyNoticeErrored: Bool
  ) -> Self {
    let items: [CellType] = [
      .title(L10n.Privacy.title),
      .spacer(.medium),
      .privacyItem(.identity),
      .spacer(.medium),
      .privacyItem(.people),
      .spacer(.medium),
      .privacyItem(.location),
      .spacer(.medium),
      .privacyItem(.secure),
      .spacer(.medium),
      .privacyItem(.ministry),
      .spacer(.medium),
      .privacyItem(.italy),
      .spacer(.medium),
      .privacyItem(.deleteData),
      .spacer(.small),
      .checkbox(type: .above14, isSelected: isAbove14Checked, isErrored: isAbove14Errored, linkedURL: nil),
      .checkbox(
        type: .privacyNoticeRead,
        isSelected: isReadPrivacyNoticeChecked,
        isErrored: isReadPrivacyNoticeErrored,
        linkedURL: privacyNoticeURL
      ),
      .tou(touURL)
    ]

    return Self(items: items, isHeaderVisible: isHeaderVisible, buttonTitle: L10n.Privacy.next, headerTitle: L10n.Privacy.title)
  }

  /// Creates a VM for the Settings privacy screen.
  static func settingsPrivacy(isHeaderVisible: Bool) -> Self {
    let items: [CellType] = [
      .title(L10n.Privacy.Settings.title),
      .spacer(.medium),
      .privacyItem(.identity),
      .spacer(.medium),
      .privacyItem(.people),
      .spacer(.medium),
      .privacyItem(.location),
      .spacer(.medium),
      .privacyItem(.secure),
      .spacer(.medium),
      .privacyItem(.ministry),
      .spacer(.medium),
      .privacyItem(.italy),
      .spacer(.medium),
      .privacyItem(.deleteData)
    ]

    return Self(
      items: items,
      isHeaderVisible: isHeaderVisible,
      buttonTitle: L10n.Privacy.Settings.showFull,
      headerTitle: L10n.Privacy.Settings.title
    )
  }
}

extension PrivacyVM {
  enum CellType: Equatable {
    case privacyItem(PrivacyItemCellVM.CellType)
    case title(String)
    case checkbox(type: PrivacyCheckboxCellVM.CellType, isSelected: Bool, isErrored: Bool, linkedURL: URL?)
    case spacer(PrivacySpacerCellVM.Size)
    case tou(URL?)

    var cellVM: ViewModel {
      switch self {
      case .privacyItem(let type):
        return PrivacyItemCellVM(type: type)

      case .title(let title):
        return PrivacyTitleCellVM(content: title)

      case .checkbox(let type, let isSelected, let isErrored, let linkedURL):
        return PrivacyCheckboxCellVM(type: type, isSelected: isSelected, isErrored: isErrored, linkedURL: linkedURL)

      case .spacer(let size):
        return PrivacySpacerCellVM(size: size)

      case .tou(let url):
        return PrivacyTOUCellVM(content: L10n.Privacy.tos, tosURL: url)
      }
    }
  }
}
