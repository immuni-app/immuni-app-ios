// SuggestionsVM.swift
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

struct SuggestionsVM: ViewModelWithLocalState {
  enum CellType: Equatable {
    case header(dayOfContact: CalendarDay?)
    case spacer(size: SuggestionsSpacerVM.Size)
    case alert(text: String)
    case info(text: String, subtitle: String)
    case message(text: String, url: URL? = nil)
    case instruction(instruction: SuggestionsInstructionCellVM.Instruction)
    case button(interaction: SuggestionsButtonCellVM.ButtonInteraction)
    case separator
  }

  /// The current covid status of the user.
  let covidStatus: CovidStatus

  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  let isHeaderVisible: Bool

  /// The URL of the privacy notice
  let privacyNoticeURL: URL?

  var cellTypes: [CellType] {
    switch self.covidStatus {
    case .neutral:
      return Self.neutralCells()
    case .risk(let lastContact):
      return Self.riskCells(lastContact: lastContact, privacyNoticeURL: self.privacyNoticeURL)
    case .positive:
      return Self.positiveCells()
    }
  }

  var headerGradient: Gradient? {
    switch self.covidStatus {
    case .neutral:
      return nil
    case .positive:
      return Palette.gradientPrimary
    case .risk:
      return Palette.gradientRed
    }
  }

  var headerTitle: String {
    switch self.covidStatus {
    case .neutral, .positive:
      return L10n.Suggestions.Header.ShortTitle.neutral
    case .risk:
      return L10n.Suggestions.Risk.title
    }
  }

  func shouldUpdateHeader(oldModel: SuggestionsVM?) -> Bool {
    guard let oldModel = oldModel else {
      return true
    }

    return self.isHeaderVisible != oldModel.isHeaderVisible
  }

  func shouldReloadCollection(oldModel: SuggestionsVM?) -> Bool {
    guard let oldModel = oldModel else {
      return true
    }

    return self.cellTypes != oldModel.cellTypes
  }

  func cellType(for indexPath: IndexPath) -> CellType? {
    return self.cellTypes[safe: indexPath.item]
  }

  func cellModel(for indexPath: IndexPath) -> ViewModel? {
    guard let cellType = self.cellType(for: indexPath) else {
      return nil
    }

    switch cellType {
    case .header(let dayOfContact):
      return SuggestionsHeaderCellVM(covidStatus: self.covidStatus, dayOfContact: dayOfContact)
    case .spacer(let size):
      return SuggestionsSpacerVM(size: size)
    case .alert(let text):
      return SuggestionsAlertCellVM(message: text)
    case .info(let text, let subtitle):
      return SuggestionsInfoCellVM(title: text, subtitle: subtitle)
    case .message(let text, let url):
      return SuggestionsMessageCellVM(message: text, url: url)
    case .instruction(let instruction):
      return SuggestionsInstructionCellVM(instruction: instruction)
    case .button(let interaction):
      return SuggestionsButtonCellVM(interaction: interaction)
    case .separator:
      return SuggestionsSeparatorVM()
    }
  }
}

extension SuggestionsVM {
  init?(state: AppState?, localState: SuggestionsLS) {
    guard let state = state else {
      return nil
    }

    self.covidStatus = state.user.covidStatus
    self.privacyNoticeURL = state.configuration.privacyNoticeURL(for: state.environment.userLanguage)
    self.isHeaderVisible = localState.isHeaderVisible
  }
}

extension SuggestionsVM {
  static func neutralCells() -> [CellType] {
    return [
      .header(dayOfContact: nil),
      .spacer(size: .medium),
      .alert(text: L10n.Suggestions.Neutral.alert),
      .spacer(size: .small),
      .message(text: L10n.Suggestions.Neutral.message),
      .spacer(size: .small),
      .instruction(instruction: .ministerialDecree),
      .spacer(size: .tiny),
      .instruction(instruction: .washHands),
      .spacer(size: .tiny),
      .instruction(instruction: .useNapkins),
      .spacer(size: .tiny),
      .instruction(instruction: .socialDistance),
      .spacer(size: .tiny),
      .instruction(instruction: .wearMask),
      .spacer(size: .big)
    ]
  }

  static func riskCells(lastContact: CalendarDay, privacyNoticeURL: URL?) -> [CellType] {
    return [
      .header(dayOfContact: lastContact),
      .spacer(size: .big),
      .message(text: L10n.Suggestions.Instruction.followInstructions),
      .spacer(size: .small),
      .instruction(instruction: .contactDoctor),
      .spacer(size: .small),
      .message(text: L10n.Suggestions.Instruction.HideIfContactDoctor.message),
      .spacer(size: .small),
      .button(interaction: .dismissContactNotifications),
      .spacer(size: .medium),
      .separator,
      .spacer(size: .medium),
      .message(text: L10n.Suggestions.Instruction.whileWaitingDoctor),
      .spacer(size: .medium),
      .instruction(instruction: .stayHome),
      .spacer(size: .tiny),
      .instruction(instruction: .limitMovements),
      .spacer(size: .tiny),
      .instruction(instruction: .distance),
      .spacer(size: .tiny),
      .instruction(instruction: .washHands),
      .spacer(size: .tiny),
      .instruction(instruction: .useNapkins),
      .spacer(size: .tiny),
      .instruction(instruction: .checkSymptoms),
      .spacer(size: .tiny),
      .instruction(instruction: .isolate),
      .spacer(size: .tiny),
      .instruction(instruction: .contactAuthorities),
      .spacer(size: .medium),
      .message(text: L10n.Suggestions.Instruction.under18Message),
      .spacer(size: .medium),
      .separator,
      .spacer(size: .medium),
      .message(text: L10n.Suggestions.Instruction.HideAlert.message),
      .spacer(size: .medium),
      .button(interaction: .dismissCovidNotifications),
      .spacer(size: .medium),
      .separator,
      .spacer(size: .small),
      .message(text: L10n.Suggestions.Risk.First.message),
      .spacer(size: .tiny),
      .message(text: L10n.Suggestions.Risk.Second.message),
      .spacer(size: .tiny),
      .message(text: L10n.Suggestions.Risk.Third.message),
      .spacer(size: .tiny),
      .message(text: L10n.Suggestions.Risk.Fourth.message, url: privacyNoticeURL),
      .spacer(size: .big)
    ]
  }

  static func positiveCells() -> [CellType] {
    return [
      .header(dayOfContact: nil),
      .spacer(size: .big),
      .info(text: L10n.Suggestions.Positive.Info.title, subtitle: L10n.Suggestions.Positive.Info.subtitle),
      .spacer(size: .medium),
      .separator,
      .spacer(size: .medium),
      .message(text: L10n.Suggestions.Positive.CovidNegative.message),
      .spacer(size: .medium),
      .button(interaction: .covidNegative),
      .spacer(size: .big)
    ]
  }
}
