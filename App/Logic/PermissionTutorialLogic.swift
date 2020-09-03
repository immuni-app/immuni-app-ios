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
      let isUsingSettingsV2: Bool

      if #available(iOS 13.7, *) {
        isUsingSettingsV2 = true
      } else {
        isUsingSettingsV2 = false
      }

      switch (exposureNotificationAuthorizationStatus, isUsingSettingsV2) {
      case (.restricted, false):
        try context
          .awaitDispatch(Show(
            Screen.permissionTutorial,
            animated: true,
            context: PermissionTutorialLS(content: .exposureNotificationRestrictedInstructions)
          ))

      case (.notAuthorized, false):
        try context
          .awaitDispatch(Show(
            Screen.permissionTutorial,
            animated: true,
            context: PermissionTutorialLS(content: .exposureNotificationUnauthorizedInstructions)
          ))

      case (.notAuthorized, true), (.restricted, true):
        try context
          .awaitDispatch(Show(
            Screen.permissionTutorial,
            animated: true,
            context: PermissionTutorialLS(content: .exposureNotificationRestrictedOrUnauthorizedV2Instructions)
          ))

      case (.authorized, _), (.authorizedAndActive, _), (.authorizedAndInactive, _), (.authorizedAndBluetoothOff, _),
           (.unknown, _):
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
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      try context
        .awaitDispatch(Show(
          Screen.permissionTutorial,
          animated: true,
          context: PermissionTutorialLS(content: .howToUploadWhenPositive)
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
