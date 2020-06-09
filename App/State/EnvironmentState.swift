// EnvironmentState.swift
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

import Alamofire
import ImmuniExposureNotification
import Katana
import Models
import PushNotification
import UIKit

// MARK: - Environment State

struct EnvironmentState {
  /// The current state of the keyboard
  var keyboardState = KeyboardState()

  /// The app display name. Taken from the Bundle
  var appName: String = "Immuni"

  /// The app version. Taken from the Bundle
  var appVersion: String = "1.0.0 (1)"

  /// The version of the Operative System.
  var osVersion: String = "iOS 13.0.0"

  /// A string describing the device model.
  var deviceModel: String = "iPhone 11"

  /// The current network reachability status.
  var networkReachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown

  /// Last explored tab during this session
  var selectedTab: TabbarVM.Tab = .home

  /// The current push notification permissions
  var pushNotificationAuthorizationStatus: PushNotificationStatus = .notDetermined

  /// The current exposure notification permissions
  var exposureNotificationAuthorizationStatus: ExposureNotificationStatus = .unknown

  /// The user's language
  var userLanguage: UserLanguage = .english
}

// MARK: - Keyboard State

extension EnvironmentState {
  struct KeyboardState: Equatable {
    static let defaultAnimationDuration: Double = 0.3
    static let defaultAnimationCurve: UIView.AnimationCurve = .easeInOut
    enum Visibility: Equatable {
      case hidden
      case visible(frame: CGRect)
    }

    var visibility: Visibility = .hidden
    var animationDuration = defaultAnimationDuration
    var animationCurve = defaultAnimationCurve

    /// The current height of the keyboard. 0 if the keyboard is hidden
    var height: CGFloat {
      switch self.visibility {
      case .hidden:
        return 0
      case .visible(let frame):
        return frame.height
      }
    }

    var animationOptions: UIView.AnimationOptions {
      let curve: UIView.AnimationOptions = {
        switch self.animationCurve {
        case .easeIn: return .curveEaseIn
        case .easeOut: return .curveEaseOut
        case .easeInOut: return .curveEaseInOut
        case .linear: return .curveLinear
        @unknown default: return .curveEaseInOut
        }
      }()
      return [.beginFromCurrentState, curve]
    }
  }
}
