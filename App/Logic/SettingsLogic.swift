// SettingsLogic.swift
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
import Foundation
import Hydra
import Katana
import Models
import Tempura

#if canImport(DebugMenu)
  import DebugMenu
#endif

extension Logic {
  enum Settings {}
}

extension Logic.Settings {
  struct ShowUploadData: AppSideEffect {
    /// A threshold to make past failed attempts expire, so that in case of another failed attempt after a long time the
    /// exponential backoff starts from the beginning
    static let recentFailedAttemptsThreshold: TimeInterval = 24 * 60 * 60

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()
      try context.awaitDispatch(RefreshOTP())

      let now = context.dependencies.now()
      let failedAttempts = state.ingestion.otpUploadFailedAttempts

      let errorSecondsLeft: Int
      let recentFailedAttempts: Int

      if
        let lastOtpFailedAttempt = state.ingestion.lastOtpUploadFailedAttempt,
        now.timeIntervalSince(lastOtpFailedAttempt) <= Self.recentFailedAttemptsThreshold {
        let backOffDuration = UploadDataLS.backOffDuration(failedAttempts: failedAttempts)
        let backOffEnd = lastOtpFailedAttempt.addingTimeInterval(TimeInterval(backOffDuration))
        errorSecondsLeft = backOffEnd.timeIntervalSince(now).roundedInt().bounded(min: 0)
        recentFailedAttempts = failedAttempts
      } else {
        errorSecondsLeft = 0
        recentFailedAttempts = 0
      }

      let ls = UploadDataLS(recentFailedAttempts: recentFailedAttempts, errorSecondsLeft: errorSecondsLeft)
      try context.awaitDispatch(Show(Screen.uploadData, animated: true, context: ls))
    }
  }

  /// Shows the FAQs screen
  struct ShowFAQs: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      context.dispatch(Show(Screen.faq, animated: true))
    }
  }

  /// Shows a single FAQ
  struct ShowFAQ: AppSideEffect {
    let faq: FAQ

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Show(Screen.question, animated: true, context: QuestionLS(faq: self.faq)))
    }
  }

  /// Shows a the privacy policy
  struct ShowPrivacyPolicy: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Show(Screen.privacy, animated: true))
    }
  }

  /// Shows a the full privacy policy
  struct ShowFullPrivacyPolicy: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let url = context.getState().configuration.privacyPolicyURL
      try context.awaitDispatch(Show(Screen.web, animated: true, context: WebLS(url: url)))
    }
  }

  /// Shows the TOS page
  struct ShowTOS: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let url = context.getState().configuration.tosURL
      try context.awaitDispatch(Show(Screen.web, animated: true, context: WebLS(url: url)))
    }
  }

  /// Leaves a review for the app
  struct LeaveReview: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      guard
        let appID = context.dependencies.bundle.appStoreID,
        let url = URL(string: "itms-apps://itunes.apple.com/us/app/pages/id\(appID)?mt=8&uo=4&action=write-review")

        else {
          return
      }

      try await(context.dependencies.application.goTo(url: url).run())
    }
  }
}

// MARK: Update Province

extension Logic.Settings {
  /// Shows the flow to update the province
  struct ShowUpdateProvince: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      guard let province = state.user.province else {
        // should never happen
        return
      }

      try context.awaitDispatch(Show(
        Screen.updateProvince,
        animated: true,
        context: province
      ))
    }
  }

  /// Handles the region step completed by the user
  struct HandleRegionStepCompleted: AppSideEffect {
    let region: Region

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      guard let province = state.user.province else {
        // should never happen
        return
      }

      if
        self.region.provinces.count == 1,
        let province = self.region.provinces.first {
        // province step not necessary
        context.dispatch(CompleteUpdateProvince(newProvince: province))
        return
      }

      // show province selector
      try context
        .awaitDispatch(Show(
          Screen.onboardingStep,
          animated: true,
          context: OnboardingContainerNC
            .NavigationContext(child: .updateProvince(selectedRegion: self.region, currentUserProvince: province))
        ))
    }
  }

  struct CompleteUpdateProvince: AppSideEffect {
    let newProvince: Province

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Logic.Onboarding.SetUserProvince(province: self.newProvince))
      context.dispatch(Hide(Screen.updateProvince, animated: true))
    }
  }
}

// MARK: Private State Updaters

private extension Logic.Settings {
  /// Refreshes the OTP
  struct RefreshOTP: AppStateUpdater {
    func updateState(_ state: inout AppState) {
      state.ingestion.otp = OTP()
    }
  }
}

// MARK: Debug Menu

extension Logic.Settings {
  struct ShowDebugMenu: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      #if canImport(DebugMenu)
        try context.awaitDispatch(DebugMenuActions.ShowDebugMenu())
      #else
        AppLogger.fatalError("Debug menu used in non enabled environment. This is critical")
      #endif
    }
  }
}
