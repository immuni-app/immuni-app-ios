// DebugMenuAlertController.swift
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

import UIKit

// MARK: Alert Controller

final class DebugMenuAlertController: UIAlertController {
  convenience init(_ model: DebugMenuAlertModel) {
    self.init(title: model.title, message: model.message, preferredStyle: model.preferredStyle)

    model.configureTextFields.forEach { self.addTextField(configurationHandler: $0) }
    model.actions.forEach { self.addAction(DebugMenuAlertAction($0, alert: self)) }
  }
}

// MARK: Alert Model

public struct DebugMenuAlertModel {
  public typealias TextFieldConfiguration = (UITextField) -> Void

  public var title: String?
  public var message: String?
  public var preferredStyle: UIAlertController.Style
  public var actions: [DebugMenuAlertActionModel]
  public var configureTextFields: [TextFieldConfiguration?]

  public init(
    title: String?,
    message: String?,
    style: UIAlertController.Style = .alert,
    actions: [DebugMenuAlertActionModel]
  ) {
    self.title = title
    self.message = message
    self.preferredStyle = style
    self.actions = actions
    self.configureTextFields = []
  }
}

// MARK: Alert Action

class DebugMenuAlertAction: UIAlertAction {
  convenience init(_ model: DebugMenuAlertActionModel, alert: UIAlertController) {
    self.init(title: model.title, style: model.style) { [unowned alert] _ in model.action?(alert) }
    self.isEnabled = model.isEnabled
  }
}

// MARK: Alert Action Model

public struct DebugMenuAlertActionModel {
  public typealias Interaction = (UIAlertController) -> Void

  public var title: String?
  public var style: UIAlertAction.Style
  public var isEnabled: Bool
  public var action: Interaction?

  public init(
    title: String?,
    style: UIAlertAction.Style = .default,
    isEnabled: Bool = true,
    action: Interaction? = nil
  ) {
    self.title = title
    self.style = style
    self.isEnabled = isEnabled
    self.action = action
  }
}
