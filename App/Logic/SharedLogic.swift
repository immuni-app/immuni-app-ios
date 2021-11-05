// SharedLogic.swift
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
import Hydra
import Katana
import MessageUI
import Models
import Tempura

extension Logic {
  enum Shared {}
}

extension Logic.Shared {
  /// Handle interaction when user taps on a push notification.
  struct HandleNotificationResponse: AppSideEffect {
    let requestNotificationID: String

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      if Logic.ForceUpdate.forceUpdateNotificationIDs.contains(self.requestNotificationID) {
        context.dispatch(OpenAppStorePage())
      }

      if Logic.CovidStatus.covidNotificationIDs.contains(self.requestNotificationID) {
        context.dispatch(HandleContactNotification())
      }
    }
  }

  /// Open AppStore page of the application
  struct OpenAppStorePage: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let appRelativeUrl = context.dependencies.bundle.appStoreID.flatMap { "app/id" + $0 } ?? ""
      guard let url = URL(string: "https://itunes.apple.com/\(appRelativeUrl)") else {
        return
      }

      try Hydra.await(context.dependencies.application.goTo(url: url))
    }
  }

  /// Open an URL in Safari or default browser.
  struct OpenURL: AppSideEffect {
    let url: URL
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try Hydra.await(context.dependencies.application.goTo(url: self.url))
    }
  }

  /// Dial phone number and start a call.
  struct DialPhoneNumber: AppSideEffect {
    let number: String
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      guard let url = URL(string: "tel://\(self.number.replacingOccurrences(of: " ", with: ""))") else {
        return
      }
      try Hydra.await(context.dependencies.application.goTo(url: url))
    }
  }

  /// Dial phone number and start a call.
  struct DialCallCenter: AppSideEffect {
    let number: String = "800912491"
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
    guard let url = URL(string: "tel://\(self.number.replacingOccurrences(of: " ", with: ""))") else {
          return
        }
    try Hydra.await(context.dependencies.application.goTo(url: url))
      }
    }

  /// Side effect to send an email with given recipient, subject and body.
  struct SendEmail: AppSideEffect {
    let recipient: String
    let subject: String
    let body: String

    public func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      guard !self.openInMail(context, recipient: self.recipient) else {
        return
      }

      guard !self.openInGmail(context, recipient: self.recipient) else {
        return
      }
    }

    private func openInMail(_ context: SideEffectContext<AppState, AppDependencies>, recipient: String) -> Bool {
      guard MFMailComposeViewController.canSendMail() else {
        return false
      }

      context
        .dispatch(Show(
          Screen.mailComposer,
          animated: true,
          context: MessageComposerContext(subject: self.subject, body: self.body, recipient: self.recipient)
        ))

      return true
    }

    private func openInGmail(_ context: SideEffectContext<AppState, AppDependencies>, recipient: String) -> Bool {
      return mainThread {
        guard
          let subject = self.subject.escaped(),
          let body = self.body.escaped(),
          let url = URL(string: "googlegmail:///co?to=\(recipient)&subject=\(subject)&body=\(body)"),
          context.dependencies.application.canOpenURL(url)

        else {
          return false
        }

        context.dependencies.application.open(url, options: [:], completionHandler: nil)
        return true
      }
    }
  }

  /// Update selected tab of the tabbar during this session.
  struct UpdateSelectedTab: AppStateUpdater {
    let tab: TabbarVM.Tab

    func updateState(_ state: inout AppState) {
      guard state.environment.selectedTab != self.tab else {
        return
      }

      state.environment.selectedTab = self.tab
    }
  }

  /// Show sensitive data cover.
  struct ShowSensitiveDataCoverIfNeeded: AppSideEffect {
    /// The list of screens that can present the cover.
    static let possiblePresenters: [String] = [Screen.tabBar.rawValue, Screen.onboardingStep.rawValue]
    /// The list of screens that, if present, will block the presentation of a cover.
    static let possibleBlockers: [String] = [
      // avoid double presentation
      Screen.sensitiveDataCover.rawValue,
      // avoid when a native alert presentation is needed
      Screen.permissionOverlay.rawValue
    ]

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      guard
        context.dependencies.application.currentRoutableIdentifiers
        .contains(where: { Self.possiblePresenters.contains($0) })
      else {
        return
      }
      guard
        !context.dependencies.application.currentRoutableIdentifiers
        .contains(where: { Self.possibleBlockers.contains($0) })
      else {
        return
      }

      context.dispatch(Show(Screen.sensitiveDataCover, animated: false))
    }
  }

  /// Hide sensitive data cover.
  struct HideSensitiveDataCoverIfPresent: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      guard context.dependencies.application.currentRoutableIdentifiers.contains(Screen.sensitiveDataCover.rawValue) else {
        return
      }
      context.dispatch(Hide(Screen.sensitiveDataCover, animated: false))
    }
  }

  /// Opens App's settings page in the native setting app
  struct OpenSettings: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      guard let url = URL(string: UIApplication.openSettingsURLString) else {
        return
      }

      try Hydra.await(context.dependencies.application.goTo(url: url).run())
    }
  }

  /// This action preloads all the Lottie Animation structs. This is done as a workaround for the performance regression on
  /// Lottie 3 ( https://github.com/airbnb/lottie-ios/issues/895 ).
  /// Most of the issue is due to the serialization of the Lottie JSON and this action prevents the app to perform this
  /// serialization multiple times as the used `animation` property in `AnimationAsset` are statically allocated.
  /// The issue is particularly evident in collection views with multiple animations in multiple cells.
  struct PreloadAssets: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      _ = AnimationAsset.allCases.map { $0.animation }
    }
  }
}

// MARK: - Private

private extension String {
  func escaped() -> String? {
    return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
  }
}

private extension Logic.Shared {
  /// Handle contact notification opened. This action will present the Suggestion view from the home tab.
  /// The action will aumatically wait for the app setup to be completed before showing the suggestions view.
  struct HandleContactNotification: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      // wait for the tabbar to be shown. Note that this check will survive until
      // the app is killed.
      try context.awaitDispatch(WaitForState(closure: { _ -> Bool in
        context.dependencies.application.currentRoutableIdentifiers
          .contains(Screen.tabBar.rawValue)
      }))

      // move to home tab and show suggestions view.
      try context.awaitDispatch(Logic.Shared.UpdateSelectedTab(tab: .home))
      try context.awaitDispatch(Logic.Suggestions.ShowSuggestions())
    }
  }
}
