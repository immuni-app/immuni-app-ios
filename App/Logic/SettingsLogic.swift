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
  /// Shows the Upload Data screen
  struct ShowUploadData: AppSideEffect {
    
    let callCenterMode: Bool
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        try context.awaitDispatch(Logic.DataUpload.ShowUploadData(callCenterMode: self.callCenterMode))
    }
  }
  /// Shows the Upload Data Autonomous screen
  struct ShowUploadDataAutonomous: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
    try context.awaitDispatch(Logic.DataUpload.ShowUploadDataAutonomous())
        }
      }
      
  /// Shows the Choose Data Upload Mode screen
  struct ShowChooseDataUploadMode: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
          try context.awaitDispatch(Logic.DataUpload.ShowChooseDataUploadMode())
        }
      }
  /// Shows the FAQs screen
  struct ShowFAQs: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      let hasLocalFAQs = state.faq.faqs(for: state.environment.userLanguage) != nil
      guard !hasLocalFAQs else {
        // There are cached FAQs for the user's language.
        try context.awaitDispatch(Show(Screen.faq, animated: true))
        return
      }

      try context.awaitDispatch(Logic.Loading.Show())
      do {
        try Hydra.await(context.dispatch(Logic.Configuration.PerformFAQFetch()).timeout(timeout: 5))
        try context.awaitDispatch(Logic.Loading.Hide())
        try context.awaitDispatch(Show(Screen.faq, animated: true))
      } catch {
        try context.awaitDispatch(Logic.Loading.Hide())

        // Show an error alert
        let model = Alert.Model(
          title: L10n.UploadData.ConnectionError.title,
          message: L10n.UploadData.ConnectionError.message,
          preferredStyle: .alert,
          actions: [
            .init(title: L10n.UploadData.ConnectionError.action, style: .default)
          ]
        )

        context.dispatch(Logic.Alert.Show(alertModel: model))
      }
    }
  }

  /// Shows a single FAQ
  struct ShowFAQ: AppSideEffect {
    let faq: FAQ

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Show(Screen.question, animated: true, context: QuestionLS(faq: self.faq)))
    }
  }

  /// Shows a the privacy notice
  struct ShowPrivacyNotice: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Show(Screen.privacy, animated: true))
    }
  }

  /// Shows a the full privacy policy
  struct ShowFullPrivacyNotice: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      guard let privacyNoticeURL = state.configuration.privacyNoticeURL(for: state.environment.userLanguage) else {
        // server misconfiguration
        return
      }

      try context.awaitDispatch(Logic.Shared.OpenURL(url: privacyNoticeURL))
    }
  }

  /// Shows the TOU page
  struct ShowTOU: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      guard let termsOfUseURL = state.configuration.termsOfUseURL(for: state.environment.userLanguage) else {
        // server misconfiguration
        return
      }

      try context.awaitDispatch(Logic.Shared.OpenURL(url: termsOfUseURL))
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

      try Hydra.await(context.dependencies.application.goTo(url: url).run())
    }
  }

  /// Share the app
  struct ShareApp: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Show(Screen.shareText, animated: true, context: L10n.Settings.Setting.Share.message))
    }
  }

  /// Shows the customer support screen
  struct ShowCustomerSupport: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Logic.Lifecycle.RefreshNetworkReachabilityStatus())
      try context.awaitDispatch(Show(Screen.customerSupport, animated: true))
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

      // handle abroad region
      if self.region.isAbroadRegion {
        // if the user cancels, the promise throws and the flow is interrupted.
        // If the user accepts, instead, the flows continues as expected
        try Hydra.await(self.showAbroadConfirmation(dispatch: context.anyDispatch(_:)))
      }

      if
        self.region.provinces.count == 1,
        let province = self.region.provinces.first
      {
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

    private func showAbroadConfirmation(dispatch: @escaping AnyDispatch) -> Promise<Void> {
      return Promise { resolve, reject, _ in
        let model = Alert.Model(
          title: L10n.Onboarding.Region.Abroad.Alert.title,
          message: L10n.Onboarding.Region.Abroad.Alert.message,
          preferredStyle: .alert,
          actions: [
            .init(title: L10n.Onboarding.Region.Abroad.Alert.cancel, style: .cancel, onTap: {
              reject(AbroadConfirmationError.userCancelled)
            }),

            .init(title: L10n.Onboarding.Region.Abroad.Alert.confirm, style: .default, onTap: {
              resolve(())
            })
          ]
        )

        _ = dispatch(Logic.Alert.Show(alertModel: model))
      }
    }

    private enum AbroadConfirmationError: Error {
      case userCancelled
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

// MARK: Update Country

extension Logic.Settings {
  /// Shows the flow to update the country
  struct ShowUpdateCountry: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      let dummyIngestionWindowDuration = state.configuration.dummyIngestionWindowDuration
      let countries = state.exposureDetection.countriesOfInterest
      let lan = Locale.current.languageCode ?? "en"
      // swiftlint:disable:next force_unwrapping
      let countryList: [String: String] = state.configuration.countries[lan] ?? state.configuration.countries["en"]!

      try context.awaitDispatch(Show(
        Screen.updateCountry,
        animated: true,
        context: CountriesOfInterestLS(
          dummyIngestionWindowDuration: dummyIngestionWindowDuration,
          currentCountries: countries,
          countryList: countryList
        )
      ))
    }
  }

  /// Update the countries selected by the user
  struct CompleteUpdateCountries: AppSideEffect {
    /// This number represents the maximum amount of countries that can be selected
    static let selectionLimitOfCountries = 3

    let newCountries: [CountryOfInterest]

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let appState = context.getState()

      var newCountriesOfInterest: [CountryOfInterest] = []
        
      let lan = Locale.current.languageCode ?? "en"
      // swiftlint:disable:next force_unwrapping
      let countryList: [String: String] = appState.configuration.countries[lan] ?? appState.configuration.countries["en"]!
      let countryListIds = countryList.keys

      for countryOfInterest in appState.exposureDetection.countriesOfInterest {
        if self.newCountries.contains(countryOfInterest) && countryListIds.contains(countryOfInterest.country.countryId) {
                 newCountriesOfInterest.append(countryOfInterest)
               }
             }

      for country in self.newCountries {
        if !appState.exposureDetection.countriesOfInterest.contains(country) {
          newCountriesOfInterest.append(CountryOfInterest(country: country.country, selectionDate: Date()))
        }
      }

      var countriesState = appState.exposureDetection.countriesOfInterest.map { $0.country.countryId }
      var countriesLocal = newCountriesOfInterest.map { $0.country.countryId }
      countriesState.sort()
      countriesLocal.sort()

      if newCountriesOfInterest.count > Self.selectionLimitOfCountries {
        // the promise throws and the flow is interrupted.
        try Hydra.await(self.showCountriesLimitExceededAlert(dispatch: context.anyDispatch(_:)))
      }
      if countriesLocal != countriesState {
        // if the user cancels, the promise throws and the flow is interrupted.
        // If the user accepts, instead, the flows continues as expected
        try Hydra.await(self.showUpdateCountriesConfirmation(dispatch: context.anyDispatch(_:)))
      }

      try context.awaitDispatch(Logic.Onboarding.SetUserCountries(countries: newCountriesOfInterest))
      context.dispatch(Hide(Screen.updateCountry, animated: true))
    }

    private func showUpdateCountriesConfirmation(dispatch: @escaping AnyDispatch) -> Promise<Void> {
      return Promise { resolve, reject, _ in
        let model = Alert.Model(
          title: L10n.CountriesOfInterest.Confirm.title,
          message: L10n.CountriesOfInterest.Confirm.description,
          preferredStyle: .alert,
          actions: [
            .init(title: L10n.Onboarding.Region.Abroad.Alert.cancel, style: .cancel, onTap: {
              reject(UpdateCountriesConfirmationError.userCancelled)
            }),

            .init(title: L10n.Onboarding.Region.Abroad.Alert.confirm, style: .default, onTap: {
              resolve(())
            })
          ]
        )

        _ = dispatch(Logic.Alert.Show(alertModel: model))
      }
    }

    private func showCountriesLimitExceededAlert(dispatch: @escaping AnyDispatch) -> Promise<Void> {
      return Promise { _, reject, _ in
        let model = Alert.Model(
          title: L10n.CountriesOfInterest.Alert.title,
          message: L10n.CountriesOfInterest.Alert.description,
          preferredStyle: .alert,
          actions: [
            .init(title: L10n.Onboarding.Region.Abroad.Alert.confirm, style: .cancel, onTap: {
              reject(UpdateCountriesConfirmationError.userCancelled)
            })
          ]
        )

        _ = dispatch(Logic.Alert.Show(alertModel: model))
      }
    }

    private enum UpdateCountriesConfirmationError: Error {
      case userCancelled
    }
  }
}

// MARK: Customer Support

extension Logic.Settings {
  struct SendCustomerSupportEmail: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()
      guard let recipient = state.configuration.supportEmail else {
        return
      }

      // swiftlint:disable line_length
      let infos = [
        "\(L10n.Support.Info.Item.os): \(state.environment.osVersion)",
        "\(L10n.Support.Info.Item.device): \(state.environment.deviceModel)",
        "\(L10n.Support.Info.Item.exposureNotificationEnabled): \(state.environment.exposureNotificationAuthorizationStatus.isAuthorized ? L10n.Support.Info.ExposureNotifications.active : L10n.Support.Info.ExposureNotifications.inactive)",
        "\(L10n.Support.Info.Item.bluetoothEnabled): \(state.environment.exposureNotificationAuthorizationStatus.canPerformDetection ? L10n.Support.Info.Bluetooth.active : L10n.Support.Info.Bluetooth.inactive)",
        "\(L10n.Support.Info.Item.appVersion): \(state.environment.appVersion)",
        "\(L10n.Support.Info.Item.connectionType): \(state.environment.networkReachabilityStatus.description)",
        "\(L10n.Support.Info.Item.lastENCheck): \(state.exposureDetection.lastDetectionDate?.asFormattedLastENCheck ?? L10n.Support.Info.Item.LastENCheck.none)"
      ]
      // swiftlint:enable line_length
      let infoString = infos.joined(separator: "; ")

      let body = "\r\n——————————\r\n\(L10n.SupportEmail.Body.message)\r\n\r\n\(infoString)"

      context.dispatch(Logic.Shared.SendEmail(recipient: recipient, subject: "", body: body))
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
