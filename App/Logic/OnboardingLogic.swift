// OnboardingLogic.swift
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
import ImmuniExposureNotification
import Katana
import Models
import Tempura

extension Logic {
  enum Onboarding {}
}

extension Logic.Onboarding {
  /// Shows the onboarding's necessary steps, assuming there is at least one step to show
  struct ShowNecessarySteps: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()
      let nextStep = state.nextOnboardingStep

      if state.toggles.isOnboardingCompleted {
        // this should never happen, move to the tabbar
        context.dispatch(Show(Screen.tabBar, animated: false))
      } else if nextStep is CompleteOnboarding {
        // the onboarding has not been marked as completed, but the
        // user has completed it outside the app (e.g., by giving Immuni the
        // required permissions). Handle the case by not showing the onboarding
        try context.awaitDispatch(Logic.ForceUpdate.RemoveScheduledOSReminderIfNeeded())
        try context.awaitDispatch(MarkOnboardingAsCompleted())
        context.dispatch(Show(Screen.tabBar, animated: false))
      } else {
        // normal onboarding flow
        context.anyDispatch(nextStep)
      }
    }
  }
}

// MARK: Region

extension Logic.Onboarding {
  /// Handles the region step completed by the user
  struct HandleRegionStepCompleted: AppSideEffect {
    let region: Region

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      // handle abroad region
      if self.region.isAbroadRegion {
        // if the user cancels, the promise throws and the flow is interrupted.
        // If the user accepts, instead, the flows continues as expected
        try Hydra.await(self.showAbroadConfirmation(dispatch: context.anyDispatch(_:)))
      }

      if self.region.provinces.count == 1, let province = self.region.provinces.first {
        // province step not necessary
        try context.awaitDispatch(SetUserProvince(province: province))
        let nextStep = context.getState().nextOnboardingStep
        context.anyDispatch(nextStep)
        return
      }

      // show province selector
      try context
        .awaitDispatch(Show(
          Screen.onboardingStep,
          animated: true,
          context: OnboardingContainerNC.NavigationContext(child: .province(region: self.region))
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
}

// MARK: Province

extension Logic.Onboarding {
  /// Handles the province step completed by the user
  struct HandleProvinceStepCompleted: AppSideEffect {
    let selectedProvince: Province

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(SetUserProvince(province: self.selectedProvince))
      let nextStep = context.getState().nextOnboardingStep
      context.anyDispatch(nextStep)
    }
  }
}

// MARK: Exposure Permission

extension Logic.Onboarding {
  struct ShowExposureNotification: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Show(
        Screen.onboardingStep,
        animated: true,
        context: OnboardingContainerNC.NavigationContext(child: .exposureNotificationPermissions)
      ))

      // wait for the exposure to be authorized. Note that this check will survive until
      // the app is killed. In that case the onboarding logic is simply restarted and this
      // point never reached (in case of exposure authorization)
      try context.awaitDispatch(WaitForState(closure: { state in
        state.environment.exposureNotificationAuthorizationStatus.isAuthorized
      }))

      // dismiss permission tutorial view if visible
      try context.awaitDispatch(Logic.PermissionTutorial.DismissIfVisible())

      // exposure notification activated. Move to next step
      let state = context.getState()
      let nextStep = state.nextOnboardingStep
      context.anyDispatch(nextStep)
    }
  }

  /// Handles the exposure permission step completed by the user
  struct UserDidTapExposureActionButton: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()
      let authStatus = state.environment.exposureNotificationAuthorizationStatus

      switch authStatus {
      case .authorized, .authorizedAndActive, .authorizedAndInactive, .authorizedAndBluetoothOff:
        // do nothing, the `ShowExposureNotification` manages the transition
        return

      case .unknown:
        // ask the permission
        try context
          .awaitDispatch(Show(
            Screen.permissionOverlay,
            animated: true,
            context: OnboardingPermissionOverlayLS(type: .exposureNotification)
          ))
        try Hydra.await(Promise<Void>.deferring(of: 1))
        _ = try Hydra.await(context.dependencies.exposureNotificationManager.askAuthorizationAndStart())

        try context.awaitDispatch(Logic.Lifecycle.ScheduleBackgroundTask())
        try context.awaitDispatch(Hide(Screen.permissionOverlay, animated: false))
        try context.awaitDispatch(Logic.Lifecycle.RefreshAuthorizationStatuses())

      case .restricted, .notAuthorized:
        context.dispatch(Logic.PermissionTutorial.ShowActivateExposureNotificationTutorial())
      }
    }
  }
}

// MARK: Bluetooth off

extension Logic.Onboarding {
  struct ShowBluetoothOff: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Show(
        Screen.onboardingStep,
        animated: true,
        context: OnboardingContainerNC.NavigationContext(child: .bluetoothOff)
      ))

      // wait for the bluetooth to be activated. Note that this check will survive until
      // the app is killed. In that case the onboarding logic is simply restarted and this
      // point never reached (in case of bt activation)
      try context.awaitDispatch(WaitForState(closure: { state in
        state.environment.exposureNotificationAuthorizationStatus != .authorizedAndBluetoothOff
      }))

      // dismiss permission tutorial view if visible
      try context.awaitDispatch(Logic.PermissionTutorial.DismissIfVisible())

      // bluetooth activated. Move to next step
      let state = context.getState()
      let nextStep = state.nextOnboardingStep
      context.anyDispatch(nextStep)
    }
  }

  /// Handles the exposure permission step completed by the user
  struct UserDidTapBluetoothOffActionButton: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      context.dispatch(Logic.PermissionTutorial.ShowEnableBluetoothTutorial())
    }
  }
}

// MARK: Push Permission

extension Logic.Onboarding {
  /// Handles the push button action by either showing instructions or the Apple prompt
  struct UserDidTapPushPermissions: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      let currentStatus = state.environment.pushNotificationAuthorizationStatus

      guard currentStatus != .denied else {
        // show the instructions to activate the push
        context.dispatch(Logic.PermissionTutorial.ShowPushNotificationTutorial())
        return
      }

      try context
        .awaitDispatch(Show(
          Screen.permissionOverlay,
          animated: true,
          context: OnboardingPermissionOverlayLS(type: .pushNotification)
        ))
      try Hydra.await(Promise<Void>.deferring(of: 1))
      _ = try Hydra.await(context.dependencies.pushNotification.askForPermission())
      try context.awaitDispatch(Hide(Screen.permissionOverlay, animated: false))
      try context.awaitDispatch(Logic.Lifecycle.RefreshAuthorizationStatuses())

      // navigate away regardless of the user's choice
      let step = context.getState().nextOnboardingStep
      context.anyDispatch(step)
    }
  }
}

// MARK: Advices

extension Logic.Onboarding {
  /// Handles the interaction in the pin advice view.
  struct UserDidTapPinAdvice: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(PassPinAdviceStep())
      // move to next step
      let step = context.getState().nextOnboardingStep
      context.anyDispatch(step)
    }
  }

  /// Handles the interaction in the communication advice view.
  struct UserDidTapCommunicationAdvice: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(PassCommunicationAdviceStep())
      // move to next step
      let step = context.getState().nextOnboardingStep
      context.anyDispatch(step)
    }
  }

  /// Mark pin advice toggle as true.
  private struct PassPinAdviceStep: AppStateUpdater {
    func updateState(_ state: inout AppState) {
      state.toggles.didShowPinAdvice = true
    }
  }

  /// Mark communication advice toggle as true.
  private struct PassCommunicationAdviceStep: AppStateUpdater {
    func updateState(_ state: inout AppState) {
      state.toggles.didShowCommunicationAdvice = true
    }
  }
}

// MARK: Completion

extension Logic.Onboarding {
  /// Completes the onboarding for the user.
  /// This action does not check if all of the onboarding steps have been performed.
  /// Anyhow, this is supposed to be dispatched only as fallback action of the `nextOnboardingStep` computed variable that
  /// indeed performs all the needed checks.
  struct CompleteOnboarding: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      // avoid handling the action multiple times
      guard !context.getState().toggles.isOnboardingCompleted else {
        return
      }
      try context.awaitDispatch(Logic.ForceUpdate.RemoveScheduledOSReminderIfNeeded())
      try context.awaitDispatch(MarkOnboardingAsCompleted())

      try context.awaitDispatch(Show(
        Screen.onboardingStep,
        animated: true,
        context: OnboardingContainerNC.NavigationContext(child: .onboardingCompleted)
      ))
      try Hydra.await(Promise<Void>.deferring(of: 3))
      context.dispatch(Show(Screen.tabBar, animated: false))
    }
  }
}

// MARK: State Updaters

extension Logic.Onboarding {
  /// Sets the user's province
  struct SetUserProvince: AppStateUpdater {
    let province: Province

    func updateState(_ state: inout AppState) {
      state.user.province = self.province
    }
  }

  struct SetUserCountries: AppStateUpdater {
    let countries: [CountryOfInterest]

    func updateState(_ state: inout AppState) {
      state.exposureDetection.countriesOfInterest = self.countries
    }
  }
}

// MARK: Private State Updaters

extension Logic.Onboarding {
  struct MarkOnboardingAsCompleted: AppStateUpdater {
    func updateState(_ state: inout AppState) {
      state.toggles.isOnboardingCompleted = true
    }
  }
}

// MARK: Helpers

private extension AppState {
  /// Calculates the next step of the onboarding based on the state.
  var nextOnboardingStep: AnySideEffect {
    if self.user.province == nil {
      return Show(
        Screen.onboardingStep,
        animated: true,
        context: OnboardingContainerNC.NavigationContext(child: .region)
      )
    }

    if !self.environment.exposureNotificationAuthorizationStatus.isAuthorized {
      return Logic.Onboarding.ShowExposureNotification()
    }

    if self.environment.exposureNotificationAuthorizationStatus == .authorizedAndBluetoothOff {
      return Logic.Onboarding.ShowBluetoothOff()
    }

    if self.environment.pushNotificationAuthorizationStatus == .notDetermined {
      return Show(
        Screen.onboardingStep,
        animated: true,
        context: OnboardingContainerNC.NavigationContext(child: .pushNotificationPermissions)
      )
    }

    if !self.toggles.didShowPinAdvice {
      return Show(
        Screen.onboardingStep,
        animated: true,
        context: OnboardingContainerNC.NavigationContext(child: .pinAdvice)
      )
    }

    if !self.toggles.didShowCommunicationAdvice {
      return Show(
        Screen.onboardingStep,
        animated: true,
        context: OnboardingContainerNC.NavigationContext(child: .communicationAdvice)
      )
    }

    return Logic.Onboarding.CompleteOnboarding()
  }
}
