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
      let failedAttempts = state.user.otpUploadFailedAttempts

      let errorSecondsLeft: Int
      let recentFailedAttempts: Int

      if
        let lastOtpFailedAttempt = state.user.lastOtpUploadFailedAttempt,
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
      #warning("rework")
//      let state = context.getState()
//      let hasLocalFAQs = !state.faqState.faqs.isEmpty
//
//      try context.awaitDispatch(Logic.Loading.Show(message: L10n.Faq.loading))
//
//      do {
//        if hasLocalFAQs {
//          // loads faqs best effort (that is, wait 5 seconds and proceed with old data)
//          // note the try? that prevents the throw
//          try? await(context.dispatch(PerformFAQFetch()).timeout(timeout: 5))
//        } else {
//          try context.awaitDispatch(PerformFAQFetch())
//        }
//
//        try context.awaitDispatch(Logic.Loading.Hide())
//        try context.awaitDispatch(Show(Screen.faq, animated: true))
//      } catch {
//        try context.awaitDispatch(Logic.Loading.Hide())
//
//        // handle errors by showing an error
//        let model = Alert.Model(
//          title: L10n.Error.FaqDownload.title,
//          message: L10n.Error.FaqDownload.message,
//          preferredStyle: .alert,
//          actions: [
//            .init(title: L10n.Error.FaqDownload.action, style: .default)
//          ]
//        )
//
//        context.dispatch(Logic.Alert.Show(alertModel: model))
//      }
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

// MARK: Fetch FAQ

private extension Logic.Settings {
  /// Performs a network request and stores the FAQs in the state
  struct PerformFAQFetch: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      #warning("rework")
//      let state = context.getState()
//
//      guard
//        let faqURL = state.configuration.faqURL(for: state.environment.userLanguage),
//        var components = URLComponents(url: faqURL, resolvingAgainstBaseURL: false)
//
//        else {
//          throw FAQError.invalidConfiguration
//      }
//
//      let path = components.path
//
//      // remove path
//      components.path = ""
//      let baseURL = try components.asURL()
//
//      let faqs: [FAQ] = try await(context.dependencies.networkManager.getFAQ(baseURL: baseURL, path: path))
//      try context.awaitDispatch(UpdateFAQs(faqs: faqs))
    }
  }
}

// MARK: Private State Updaters

private extension Logic.Settings {
  /// Updates the local FAQs
  struct UpdateFAQs: AppStateUpdater {
    let faqs: [FAQ]
    let language: UserLanguage

    func updateState(_ state: inout AppState) {
      state.faqState.fetchedFAQs = self.faqs
      state.faqState.latestFetchLanguage = self.language
    }
  }

  /// Refreshes the OTP
  struct RefreshOTP: AppStateUpdater {
    func updateState(_ state: inout AppState) {
      state.user.otp = OTP()
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

// MARK: Models

extension Logic.Settings {
  enum FAQError: Error {
    case invalidConfiguration
  }
}
