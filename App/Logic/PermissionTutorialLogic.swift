// PermissionTutorialLogic.swift
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
  enum PermissionTutorial {}
}

extension Logic.PermissionTutorial {
  /// Shows the tutorial to update the OS
  struct ShowUpdateOperatingSystem: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context
        .awaitDispatch(Show(
          Screen.permissionTutorial,
          animated: true,
          context: PermissionTutorialLS(content: .updateOperatingSystem)
        ))
    }
  }

  /// Shows further explainations about updating the OS
  struct ShowCantUpdateOperatingSystem: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context
        .awaitDispatch(Show(
          Screen.permissionTutorial,
          animated: true,
          context: PermissionTutorialLS(content: .cantUpdateOperatingSystem)
        ))
    }
  }

  /// Shows the how immuni works page
  struct ShowHowImmuniWorks: AppSideEffect {
    let showFaqButton: Bool
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context
        .awaitDispatch(Show(
          Screen.permissionTutorial,
          animated: true,
          context: PermissionTutorialLS(content: .howImmuniWorks(shouldShowFaqButton: self.showFaqButton))
        ))
    }
  }

  /// Shows the explaination about why province/region is required
  struct ShowWhyProvinceRegion: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context
        .awaitDispatch(Show(
          Screen.permissionTutorial,
          animated: true,
          context: PermissionTutorialLS(content: .whyProvinceRegion)
        ))
    }
  }

  /// Shows the Exposure notification activation tutorial
  struct ShowActivateExposureNotificationTutorial: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let exposureNotificationAuthorizationStatus = context.getState().environment.exposureNotificationAuthorizationStatus

      switch exposureNotificationAuthorizationStatus {
      case .restricted:
        try context
          .awaitDispatch(Show(
            Screen.permissionTutorial,
            animated: true,
            context: PermissionTutorialLS(content: .exposureNotificationRestrictedInstructions)
          ))

      case .notAuthorized:
        try context
          .awaitDispatch(Show(
            Screen.permissionTutorial,
            animated: true,
            context: PermissionTutorialLS(content: .exposureNotificationUnauthorizedInstructions)
          ))

      case .authorized, .authorizedAndActive, .authorizedAndInactive, .authorizedAndBluetoothOff, .unknown:
        // should never happen
        break
      }
    }
  }

  /// Shows the bluetooth tutorial
  struct ShowEnableBluetoothTutorial: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context
        .awaitDispatch(Show(
          Screen.permissionTutorial,
          animated: true,
          context: PermissionTutorialLS(content: .bluetoothInstructions)
        ))
    }
  }

  /// Shows the Push activation tutorial
  struct ShowPushNotificationTutorial: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context
        .awaitDispatch(Show(
          Screen.permissionTutorial,
          animated: true,
          context: PermissionTutorialLS(content: .notificationInstructions)
        ))
    }
  }

  /// Dismiss the tutorial view if visible
  struct DismissIfVisible: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let isScreenPresented = context.dependencies.application.currentRoutableIdentifiers
        .contains(Screen.permissionTutorial.rawValue)
      if isScreenPresented {
        try context.awaitDispatch(Hide(Screen.permissionTutorial, animated: true))
      }
    }
  }

  /// Shows the how to upload when positive explaination
  struct ShowHowToUploadWhenPositive: AppSideEffect {
    let callCenterMode: Bool
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context
        .awaitDispatch(Show(
          Screen.permissionTutorial,
          animated: true,
            context: PermissionTutorialLS(content: callCenterMode ? .howToUploadWhenPositiveCallCenter : .howToUploadWhenPositive)
        ))
    }
  }
  /// Shows the how to upload when positive explaination
  struct ShowHowToUploadWhenPositiveAutonomous: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context
          .awaitDispatch(Show(
            Screen.permissionTutorial,
            animated: true,
            context: PermissionTutorialLS(content: .howToUploadWhenPositiveAutonomous)
          ))
      }
    }
  /// Shows the how to generate Digital Green Certificate
  struct ShowHowToGenerateDigitalGreenCertificate: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context
        .awaitDispatch(Show(
            Screen.permissionTutorial,
            animated: true,
            context: PermissionTutorialLS(content: .howToGenerateDigitalGreenCertificate)
          ))
        }
    }
  /// Shows further explainations about how to verify that Immuni is working
  struct ShowVerifyImmuniWorks: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context
        .awaitDispatch(Show(
          Screen.permissionTutorial,
          animated: true,
          context: PermissionTutorialLS(content: .verifyImmuniWorks)
        ))
    }
  }
}
