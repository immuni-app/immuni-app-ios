// AnimationView+Utils.swift
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

import Lottie

extension AnimationView {
  /// Play animation if possible accessibility wise.
  /// - note: this won't automatically be checked when the app returns from background.
  func playIfPossible() {
    guard !UIAccessibility.isReduceMotionEnabled else {
      self.stop()
      self.currentProgress = 1
      return
    }
    if !self.isAnimationPlaying {
      self.play()
    }
  }
}

/// Enum containing all the animations name of the app.
enum AnimationAsset: String, CaseIterable, Equatable {
  case hiw1 = "hiw_1"
  case hiw2 = "hiw_2"
  case hiw3 = "hiw_3"
  case hiw4 = "hiw_4"
  case hiw5 = "hiw_5"
}

extension AnimationAsset {
  /// An helper to get the Animation object related to the `AnimationAsset` statically computed.
  /// Check  `PreloadAssets` action for better documentation.
  var animation: Animation? {
    switch self {
    case .hiw1:
      return AnimationAsset.hiw1Animation
    case .hiw2:
      return AnimationAsset.hiw2Animation
    case .hiw3:
      return AnimationAsset.hiw3Animation
    case .hiw4:
      return AnimationAsset.hiw4Animation
    case .hiw5:
      return AnimationAsset.hiw5Animation
    }
  }

  static let hiw1Animation = Animation.named(AnimationAsset.hiw1.rawValue)
  static let hiw2Animation = Animation.named(AnimationAsset.hiw2.rawValue)
  static let hiw3Animation = Animation.named(AnimationAsset.hiw3.rawValue)
  static let hiw4Animation = Animation.named(AnimationAsset.hiw4.rawValue)
  static let hiw5Animation = Animation.named(AnimationAsset.hiw5.rawValue)
}
