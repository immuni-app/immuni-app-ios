// SuggestionsLogic.swift
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

import Hydra
import Katana
import Tempura

extension Logic {
  enum Suggestions {}
}

extension Logic.Suggestions {}

extension Logic.Suggestions {
  /// Shows the suggestions screen
  struct ShowSuggestions: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      context.dispatch(Show(Screen.suggestions, animated: true))
    }
  }
}

// MARK: User Inputs

extension Logic.Suggestions {
  /// Triggers the alert dismissal, which is used in case the user is in contact with the ASL
  struct DismissContactNotifications: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try Hydra.await(Promise<Void>.alertPromise(
        using: context.anyDispatch(_:),
        title: L10n.Suggestions.Alert.AslContactConfirmation.title,
        message: L10n.Suggestions.Alert.AslContactConfirmation.description,
        affermativeAnswer: L10n.Suggestions.Alert.AslContactConfirmation.positiveAnswer,
        negativeAnswer: L10n.Suggestions.Alert.AslContactConfirmation.negativeAnswer
      ))

      try context.awaitDispatch(Hide(Screen.suggestions, animated: true))
      try context.awaitDispatch(Logic.CovidStatus.UpdateStatusWithEvent(event: .userEvent(.alertDismissal)))
    }
  }

  /// Triggers the alert dismissal, which is used in case the user is in contact with the ASL
  struct HideAlert: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try Hydra.await(Promise<Void>.alertPromise(
        using: context.anyDispatch(_:),
        title: L10n.Suggestions.Alert.HideAlert.title,
        message: L10n.Suggestions.Alert.HideAlert.description,
        affermativeAnswer: L10n.Suggestions.Alert.HideAlert.positiveAnswer,
        negativeAnswer: L10n.Suggestions.Alert.HideAlert.negativeAnswer
      ))

      try context.awaitDispatch(Hide(Screen.suggestions, animated: true))
      try context.awaitDispatch(Logic.CovidStatus.UpdateStatusWithEvent(event: .userEvent(.alertDismissal)))
    }
  }

  /// Triggers the no longer positive
  struct NoLongerPositive: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try Hydra.await(Promise<Void>.alertPromise(
        using: context.anyDispatch(_:),
        title: L10n.Suggestions.Alert.CovidNegative.title,
        message: L10n.Suggestions.Alert.CovidNegative.description,
        affermativeAnswer: L10n.Suggestions.Alert.CovidNegative.positiveAnswer,
        negativeAnswer: L10n.Suggestions.Alert.CovidNegative.negativeAnswer
      ))

      try context.awaitDispatch(Hide(Screen.suggestions, animated: true))
      try context.awaitDispatch(Logic.CovidStatus.UpdateStatusWithEvent(event: .userEvent(.recoverConfirmed)))
    }
  }
}

// MARK: Models

private extension Logic.Suggestions {
  enum AlertError: Error {
    case userRejected
  }
}

// MARK: Helpers

private extension Promise {
  /// Helper that creates a promise that throws when the user rejects the alert
  /// (that is, negativeAnswer is selected)
  static func alertPromise(
    using dispatch: @escaping AnyDispatch,
    title: String,
    message: String,
    affermativeAnswer: String,
    negativeAnswer: String
  ) -> Promise<Void> {
    return Promise<Void> { resolve, reject, _ in
      let negativeResponseAction = Alert.ActionModel(title: negativeAnswer, style: .cancel) {
        reject(Logic.Suggestions.AlertError.userRejected)
      }

      let positiveResponseAction = Alert.ActionModel(title: affermativeAnswer, style: .default) {
        resolve(())
      }

      _ = dispatch(Logic.Alert.Show(alertModel: .init(
        title: title,
        message: message,
        preferredStyle: .alert,
        actions: [negativeResponseAction, positiveResponseAction]
      )))
    }
  }
}
