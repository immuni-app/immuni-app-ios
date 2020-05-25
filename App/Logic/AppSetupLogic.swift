// AppSetupLogic.swift
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
  enum AppSetup {}
}

extension Logic.AppSetup {
  /// Performs the initial setup before proceeding to the appropriate view
  struct PerformSetup: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      // Start a best-effort download the configuration / faq from the server
      // in case this is the first launch
      if !state.toggles.isFirstLaunchPerformed {
        let fetchPromise = context
          .dispatch(Logic.Configuration.DownloadAndUpdateConfiguration())
          .timeout(timeout: 10)

        // here we are not interested in the result
        // (e.g., the timeout made the promise fail)
        try? await(fetchPromise)

        // flags the first launch as done to prevent further downloads
        // during the startup phase
        try context.awaitDispatch(PassFirstLaunchExecuted())
      }

      // Navigate to the approprivate view
      context.dispatch(ChangeRoot())
    }
  }

  /// Load the appropriate root view for the application
  struct ChangeRoot: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()
      context.dependencies.application.enableAdaptiveContentSizeMonitor()

      guard #available(iOS 13.5, *) else {
        context.dispatch(Logic.ForceUpdate.ShowOSForceUpdate())
        return
      }

      let shouldBlockApp = state.shouldBlockApplication(bundle: context.dependencies.bundle)

      if shouldBlockApp {
        context.dispatch(Logic.ForceUpdate.ShowAppForceUpdate())
      } else if !state.toggles.isOnboardingPrivacyAccepted {
        context.dispatch(Logic.AppSetup.ShowWelcome())
      } else if !state.toggles.isOnboardingCompleted {
        context.dispatch(Logic.Onboarding.ShowNecessarySteps())
      } else {
        context.dispatch(Logic.AppSetup.ShowTabBar())
      }
    }
  }

  /// Navigation action to show the tab bar containing the home vc.
  struct ShowTabBar: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Show(Screen.tabBar))
    }
  }

  /// Navigation action to show the welcome vc.
  struct ShowWelcome: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Show(Screen.welcome, animated: true))
    }
  }
}

// MARK: State Updater

extension Logic.AppSetup {
  /// Marks the first launch executed as done
  struct PassFirstLaunchExecuted: AppStateUpdater {
    func updateState(_ state: inout AppState) {
      state.toggles.isFirstLaunchPerformed = true
    }
  }
}
