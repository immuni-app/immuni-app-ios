// TogglesState.swift
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

struct TogglesState: Codable {
  /// Whether the user has accepted the onboarding's privacy screen
  var isOnboardingPrivacyAccepted: Bool = false

  /// Whether the pin advice view has been shown during onboarding.
  var didShowPinAdvice: Bool = false

  /// Whether the communication advice view has been shown during onboarding.
  var didShowCommunicationAdvice: Bool = false

  /// Whether the onboarding has been completed
  var isOnboardingCompleted: Bool = false

  /// Whether the setup related to the first launch has been performed.
  var isFirstLaunchSetupPerformed: Bool = false

  // MARK: - Debug values

  /// Debug value used to force the ForceUpdate screen at startup
  var mustShowForceUpdate: Bool = false

  /// Whether the push notification test mode is enabled. This must be available
  /// only using the debug menu
  var isPushNotificationDebugMode: Bool = false

  /// Whether to send local notification at execution of background tasks to allow debugging.
  /// It is set from a Debug Menu action.
  var isBackgroundTaskDebugMode: Bool = false

  // MARK: - Migration values

  /// Whether the `ClearRiskStatusIfWronglyAttributed` migration has run
  var isWronglyAttributedRiskStatusBeenChecked: Bool = false
}
