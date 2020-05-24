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
  enum Configuration {
    /// Download the updated configuration from the server and persist it in the state
    struct DownloadAndUpdateConfiguration: AppSideEffect {
      func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        guard let buildNumber = context.dependencies.bundle.intBuildVersion else {
          return
        }

        let configuration = try await(context.dependencies.networkManager.getConfiguration(for: buildNumber))
        try context.awaitDispatch(UpdateConfiguration(configuration: configuration))
      }
    }

    private struct UpdateConfiguration: AppStateUpdater {
      let configuration: Models.Configuration

      func updateState(_ state: inout AppState) {
        state.configuration = self.configuration
        state.toggles.isConfigurationEverDownloaded = true
      }
    }
  }
}
