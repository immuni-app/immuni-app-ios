// HomeLogic.swift
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

import Katana
import Tempura

extension Logic {
  enum Home {}
}

extension Logic.Home {}

// MARK: Fix Service

extension Logic.Home {
  /// Shows the fix active service screen, if necessary
  struct ShowFixActiveService: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      guard let dispatchable = state.nextFixActiveServiceStep else {
        // nothing to do here
        return
      }

      context.anyDispatch(dispatchable)
    }
  }

  /// Shows the tutorial to deactivate the service.
  struct ShowDeactivateService: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      context.dispatch(Show(
        Screen.permissionTutorial,
        animated: true,
        context: PermissionTutorialLS(content: .deactivateServiceInstructions)
      ))
    }
  }

  /// Shows the stay home discover more
  struct ShowStayHomeDiscoverMore: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        
      let state = context.getState()
      let lan = Locale.current.languageCode ?? "en"
      let message = state.configuration.riskExposure[lan]
      guard let message = message else { return }
        
      let content = PermissionTutorialVM.Content(
        title: L10n.Suggestions.StayHome.DiscoverMore.title,
        items: [
          .spacer(.big),
          .textualContent(message, isDark: false),
          .spacer(.big)
        ],
        mainActionTitle: nil,
        action: nil
      )
      context.dispatch(Show(
        Screen.permissionTutorial,
        animated: true,
        context: PermissionTutorialLS(content: content)
        ))
      }
    }

  /// Shows the push notification step and waits for the fullfilment of the
  fileprivate struct ShowPushNotification: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Show(
        Screen.fixActiveService,
        animated: true,
        context: OnboardingContainerNC.NavigationContext(child: .fixPushNotificationPermissions)
      ))

      // wait for the push to be authorized. Note that this check will survive until
      // the app is killed, the vc dismissed or the condition met
      try context.awaitDispatch(WaitForState(closure: { state in
        let isScreenPresented = context.dependencies.application.currentRoutableIdentifiers
          .contains(Screen.fixActiveService.rawValue)

        guard isScreenPresented else {
          // screen no more presented, let's invalidate the check and the entire side effect
          throw FixPermissionError.checkNotLongerNecessary
        }

        return state.environment.pushNotificationAuthorizationStatus.allowsSendingNotifications
      }))

      // push activated. Move to next step, or dismiss
      let state = context.getState()
      let nextStep = state.nextFixActiveServiceStep ?? DismissFixPermissions()
      context.anyDispatch(nextStep)
    }
  }

  /// Shows the exposure notification step and waits for the fullfilment of the
  fileprivate struct ShowExposureNotification: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Show(
        Screen.fixActiveService,
        animated: true,
        context: OnboardingContainerNC.NavigationContext(child: .fixExposureNotificationPermissions)
      ))

      // wait for the exposure to be authorized. Note that this check will survive until
      // the app is killed, the vc dismissed or the condition met
      try context.awaitDispatch(WaitForState(closure: { state in
        let isScreenPresented = context.dependencies.application.currentRoutableIdentifiers
          .contains(Screen.fixActiveService.rawValue)

        guard isScreenPresented else {
          // screen no more presented, let's invalidate the check and the entire side effect
          throw FixPermissionError.checkNotLongerNecessary
        }

        // [MB] Note: the beta 2 has a bug where this state is not changed when switching the app
        // and activating the permissions. Let's wait for a newer build before changing the UX
        // and tell users to kill the app
        return state.environment.exposureNotificationAuthorizationStatus.isAuthorized
      }))

      // exposure notification activated. Move to next step, or dismiss
      let state = context.getState()
      let nextStep = state.nextFixActiveServiceStep ?? DismissFixPermissions()
      context.anyDispatch(nextStep)
    }
  }

  fileprivate struct ShowBluetoothOff: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context.awaitDispatch(Show(
        Screen.fixActiveService,
        animated: true,
        context: OnboardingContainerNC.NavigationContext(child: .fixBluetoothOff)
      ))

      // wait for the exposure to be authorized. Note that this check will survive until
      // the app is killed, the vc dismissed or the condition met
      try context.awaitDispatch(WaitForState(closure: { state in

        let isScreenPresented = context.dependencies.application.currentRoutableIdentifiers
          .contains(Screen.fixActiveService.rawValue)

        guard isScreenPresented else {
          // screen no more presented, let's invalidate the check and the entire side effect
          throw FixPermissionError.checkNotLongerNecessary
        }

        return state.environment.exposureNotificationAuthorizationStatus != .authorizedAndBluetoothOff
      }))

      // bluetooth activated. Move to next step, or dismiss
      let state = context.getState()
      let nextStep = state.nextFixActiveServiceStep ?? DismissFixPermissions()
      context.anyDispatch(nextStep)
    }
  }

  /// Dismisses the fix permission screen
  private struct DismissFixPermissions: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      context.dispatch(Hide(Screen.fixActiveService, animated: true))
    }
  }
    
  /// Shows the Green Certificate screen
  struct ShowGreenCertificate: AppSideEffect {
      
    let certificate: GreenCertificate?
    let favoriteMode: Bool
      
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        var currentDgc: Int = 0
        if let certificate = self.certificate, let greenCertificates = context.getState().user.greenCertificates {
            var greenCertificatesReversed = greenCertificates.reversed()
            let index = greenCertificatesReversed.firstIndex(where: {$0.id == certificate.id})
            if let index = index {
                currentDgc = greenCertificatesReversed.distance(from: greenCertificatesReversed.startIndex, to: index)
            }
        }
        try context.awaitDispatch(Show(Screen.greenCertificate, animated: true, context: GreenCertificateLS(greenCertificates: context.getState().user.greenCertificates, selectedCertificate: self.certificate, favoriteMode: self.favoriteMode, currentDgc: currentDgc)))
        }
      }
    
  /// Handle Add To Home
  struct HandleAddToHome: AppSideEffect {
        
    let certificate: GreenCertificate
        
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        let state = context.getState()
        guard let _ = state.user.favoriteGreenCertificate else {
            try context.awaitDispatch(AddToHome(dgc: certificate))
            try context.awaitDispatch(ShowHandleAddToHomeAlert(title: L10n.HomeView.GreenCertificate.Alert.AddedToHome.title, message: L10n.HomeView.GreenCertificate.Alert.AddedToHome.message))
            return
          }
        if certificate.id == state.user.favoriteGreenCertificate?.id {
          try context.awaitDispatch(RemoveFromHome(dgc: certificate))
          try context.awaitDispatch(ShowHandleAddToHomeAlert(title: L10n.HomeView.GreenCertificate.Alert.RemovedFromHome.title, message: L10n.HomeView.GreenCertificate.Alert.RemovedFromHome.message))
          }
        else {
            try context.awaitDispatch(ShowReplaceAddedToHomeDialog(certificate: certificate))
          }
    }
  }
  /// Add To Home
  struct AddToHome: AppStateUpdater {
        
    let dgc: GreenCertificate
    func updateState(_ state: inout AppState) {
        state.user.favoriteGreenCertificate = dgc
      }
    }
    
  /// Remove from Home
  struct RemoveFromHome: AppStateUpdater {
          
    let dgc: GreenCertificate
    func updateState(_ state: inout AppState) {
        state.user.favoriteGreenCertificate = nil
      }
    }
    
  /// Shows the handle add to home alert
  struct ShowHandleAddToHomeAlert: AppSideEffect {
      
    let title: String
    let message: String

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
            
        let model = Alert.Model(
            title: title,
            message: message,
            preferredStyle: .alert,
            actions: [
                .init(title: L10n.HomeView.GreenCertificate.Alert.Ok.label, style: .cancel)
            ]
        )
        try context.awaitDispatch(Logic.Alert.Show(alertModel: model))
        }
    }
  /// Shows the replace added to home dialog
  struct ShowReplaceAddedToHomeDialog: AppSideEffect {

    let certificate: GreenCertificate

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
              
       let model = Alert.Model(
            title: L10n.HomeView.GreenCertificate.Dialog.ReplaceAddedToHome.title,
            message: L10n.HomeView.GreenCertificate.Dialog.ReplaceAddedToHome.message,
            preferredStyle: .alert,
            actions: [
                .init(title: L10n.HomeView.GreenCertificate.Dialog.Cancel.label, style: .cancel),
                .init(title: L10n.HomeView.GreenCertificate.Dialog.Confirm.label, style: .default, onTap: {
                    context.dispatch(AddToHome(dgc: certificate))
                })
            ]
        )
        
        try context.awaitDispatch(Logic.Alert.Show(alertModel: model))
        }
    }
  /// Shows the Green certificate detail
  struct ShowGreenCertificateDetail: AppSideEffect {
    let dgc: GreenCertificate
    
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
        switch dgc.certificateType {
        case .test:
            try context
                .awaitDispatch(Show(
                Screen.greenCertificateTestDetail,
                animated: true,
                    context: GreenCertificateTestDetailLS(greenCertificate: dgc)
                ))
        case .vaccine:
            try context
                .awaitDispatch(Show(
                Screen.greenCertificateVaccineDetail,
                animated: true,
                    context: GreenCertificateVaccineDetailLS(greenCertificate: dgc)
                ))
        case .recovery:
            try context
                .awaitDispatch(Show(
                Screen.greenCertificateRecoveryDetail,
                animated: true,
                    context: GreenCertificateRecoveryDetailLS(greenCertificate: dgc)
                ))
   
        case .exemption:
            try context
                .awaitDispatch(Show(
                Screen.greenCertificateExemptionDetail,
                animated: true,
                    context: GreenCertificateExemptionDetailLS(greenCertificate: dgc)
                ))
        }
        
          }
    }
  /// Shows the  ShowGenerateGreenCertificateVC screen
  struct ShowGenerateGreenCertificate: AppSideEffect {
      
      func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
          
        try context.awaitDispatch(Show(Screen.generateGreenCertificate, animated: true, context: GenerateGreenCertificateLS()))
          }
      }
 
  /// Updates the user Green Certificate
  struct UpdateGreenCertificate: AppStateUpdater {
      
    let newGreenCertificate: GreenCertificate
    func updateState(_ state: inout AppState) {
        if let dgcs = state.user.greenCertificates {
            if dgcs.filter({ $0.id == newGreenCertificate.id }).count == 0 {
                state.user.greenCertificates?.append(newGreenCertificate)
            }
        }
        else{
            state.user.greenCertificates = [newGreenCertificate]
          }
      }
    }
  /// Delete the user Green Certificate
  struct DeleteGreenCertificate: AppStateUpdater {
      
    let id: String
    func updateState(_ state: inout AppState) {
        if let dgcs = state.user.greenCertificates {
        state.user.greenCertificates = dgcs.filter({ $0.id != id })
        }
        if let favoriteGreenCertificate = state.user.favoriteGreenCertificate, favoriteGreenCertificate.id == id  {
            state.user.favoriteGreenCertificate = nil
        }
      }
    }
  /// Update flag show modal Dgc
  struct UpdateFlagShowModalDgc: AppStateUpdater {
        
    func updateState(_ state: inout AppState) {
        state.user.showModalDgc = false
        }
    }
}

// MARK: Helpers

private extension AppState {
  /// Calculates the next step of the fix active service step based on the state.
  var nextFixActiveServiceStep: AnySideEffect? {
    if !self.environment.pushNotificationAuthorizationStatus.allowsSendingNotifications {
      return Logic.Home.ShowPushNotification()
    } else if !self.environment.exposureNotificationAuthorizationStatus.isAuthorized {
      return Logic.Home.ShowExposureNotification()
    } else if self.environment.exposureNotificationAuthorizationStatus == .authorizedAndBluetoothOff {
      return Logic.Home.ShowBluetoothOff()
    } else {
      return nil
    }
  }
}

private extension Logic.Home {
  /// Errors for the fix permission logic
  private enum FixPermissionError: Error {
    case checkNotLongerNecessary
  }
}
