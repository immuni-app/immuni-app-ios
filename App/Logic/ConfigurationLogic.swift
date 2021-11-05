// ConfigurationLogic.swift
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
import Models

extension Logic {
  enum Configuration {}
}

extension Logic.Configuration {
  /// Download the updated configuration from the server and persist it in the state.
  /// This will also trigger a refresh of the FAQs
  struct DownloadAndUpdateConfiguration: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      guard let buildNumber = context.dependencies.bundle.intBuildVersion else {
        return
      }

      let configuration = try Hydra.await(context.dependencies.networkManager.getConfiguration(for: buildNumber))

      try context.awaitDispatch(UpdateConfiguration(configuration: configuration))

      // refresh FAQs as well
      try context.awaitDispatch(PerformFAQFetch())
    }
  }

  /// Performs a network request and stores the FAQs in the state
  struct PerformFAQFetch: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      guard
        let faqURL = state.configuration.faqURL(for: state.environment.userLanguage),
        var components = URLComponents(url: faqURL, resolvingAgainstBaseURL: false)

      else {
        throw FAQError.invalidConfiguration
      }

      let path = components.path

      // remove path
      components.path = ""
      let baseURL = try components.asURL()

      let faqs: [FAQ] = try Hydra.await(context.dependencies.networkManager.getFAQ(baseURL: baseURL, path: path))
      try context.awaitDispatch(UpdateFAQs(faqs: faqs, language: state.environment.userLanguage))
    }
  }
}

// MARK: Private

private extension Logic.Configuration {
  /// Updates the local configuration
  private struct UpdateConfiguration: AppStateUpdater {
    let configuration: Models.Configuration

    func updateState(_ state: inout AppState) {
      state.configuration = self.configuration
    }
  }

  /// Updates the local FAQs
  struct UpdateFAQs: AppStateUpdater {
    let faqs: [FAQ]
    let language: UserLanguage

    func updateState(_ state: inout AppState) {
      state.faq.fetchedFAQs = self.faqs
      state.faq.latestFetchLanguage = self.language
    }
  }
}

// MARK: Models

extension Logic.Configuration {
  enum FAQError: Error {
    case invalidConfiguration
  }
}
