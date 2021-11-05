// AlertLogic.swift
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
import Hydra
import Katana
import Tempura
import UIKit

// MARK: - Alert

enum Alert {
  /// A struct containing all the info to dispatch a `Show` alert action.
  struct Model {
    var title: String?
    var message: String?
    var preferredStyle: UIAlertController.Style = .alert
    var actions: [ActionModel] = []
    var preferredActionIndex: Int?
  }

  /// A struct containing all the info to create an `UIAlertAction`
  struct ActionModel {
    var title: String?
    var style: UIAlertAction.Style = .default
    var onTap: Interaction? = nil

    func byAddingResolve(_ resolve: @escaping (()) -> Void) -> Self {
      var copy = self
      let originalAction = self.onTap

      copy.onTap = {
        originalAction?()
        resolve(())
      }

      return copy
    }
  }
}

// MARK: - Logic

extension Logic {
  enum Alert {}
}

extension Logic.Alert {
  /// Navigation action to show an alert.
  struct Show: AppSideEffect {
    let alertModel: Alert.Model

    init(alertModel: Alert.Model) {
      self.alertModel = alertModel
    }

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let promise = Promise<Void>(in: .main) { resolve, _, _ in

        // forward resolve so that the promise is blocking until the alert is dismissed
        let actions = self.alertModel.actions.map { $0.byAddingResolve(resolve) }
        var model = self.alertModel
        model.actions = actions

        _ = context.dispatch(Tempura.Show(Screen.alert, animated: false, context: model))
      }

      try Hydra.await(promise)
    }
  }
}

// MARK: - Convenience

extension UIAlertController {
  /// Initializes the UIAlertController with the information provided in the Alert.Content object.
  /// If no color is defined on the action, the Palette.accentDarker color is used
  convenience init(content: Alert.Model) {
    self.init(title: content.title, message: content.message, preferredStyle: .alert)

    let actions = content.actions.map { actionModel in
      UIAlertAction(title: actionModel.title, style: actionModel.style) { _ in
        actionModel.onTap?()
      }
    }

    for action in actions {
      self.addAction(action)
    }

    self.preferredAction = content.preferredActionIndex.flatMap { actions[safe: $0] }
  }
}
