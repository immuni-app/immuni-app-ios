// DebugMenu.swift
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

import Extensions
import UIKit

/// A debug menu to be displayed inside iOS applications for debugging purposes.
open class DebugMenu: NSObject {
  public unowned var wrappedConfigurationProvider: DebugMenuConfigurationProvider?

  /// Creates a new debug menu
  override public init() {}

  /// Starts the Debug Menu with the given configuration provider
  ///    - parameter configurationProvider: The configuration provider.
  public func start(with configurationProvider: DebugMenuConfigurationProvider) {
    self.wrappedConfigurationProvider = configurationProvider
  }

  func presentDebugMenuItems() {
    mainThread {
      self.handlePresentDebugMenu()
    }
  }

  private func handlePresentDebugMenu() {
    guard !self.configurationProvider.isPresentingDebugMenu else { return }

    let appVersion = self.configurationProvider.bundle.appVersion ?? "unknown"
    let bundleVersion = self.configurationProvider.bundle.bundleVersion ?? "unknown"
    let title = "\(appVersion) \(bundleVersion)\nHow can I help you?"

    let actionSheet = DebugMenuViewController(title: title)

    // iPad support
    let popoverPresentation = actionSheet.popoverPresentationController
    popoverPresentation?.sourceView = self.configurationProvider.window.topViewController?.view
    popoverPresentation?.sourceRect = .zero
    popoverPresentation?.permittedArrowDirections = [.up]

    let state = self.configurationProvider.getState()

    for item in self.configurationProvider.items(state: state) {
      let action = UIAlertAction(title: item.title, style: .default, handler: { [unowned self] _ in

        switch item.task {
        case .perform(let closure):
          closure()

        case .dispatchable(let dispatchable):
          _ = self.configurationProvider.dispatch(dispatchable)
        }
      })

      actionSheet.addAction(action)
    }

    let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    actionSheet.addAction(dismissAction)

    self.configurationProvider.window.topViewController?.present(actionSheet, animated: true)
  }
}

private extension DebugMenu {
  var configurationProvider: DebugMenuConfigurationProvider {
    guard let configurationProvider = self.wrappedConfigurationProvider else {
      LibLogger.fatalError("You must call start before using Postman")
    }

    return configurationProvider
  }
}
