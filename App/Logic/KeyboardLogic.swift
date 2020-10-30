// KeyboardLogic.swift
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

extension Logic {
  enum Keyboard {}
}

extension Logic.Keyboard {
  /// This action is invoked every time the keyboard is presented.
  /// It saves the keyboard frame in the state so that it can be used to properly layout elements in each view.
  struct KeyboardWillShow: AppStateUpdater, NotificationObserverDispatchable {
    private let frame: CGRect
    private let animationDuration: Double
    private let animationCurve: UIView.AnimationCurve

    init?(notification: Notification) {
      guard
        notification.name == UIResponder.keyboardWillShowNotification,
        let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
        let animationCurveInt = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
        let animationCurve = UIView.AnimationCurve(rawValue: animationCurveInt)
      else {
        return nil
      }

      self.frame = frame
      self.animationDuration = animationDuration
      self.animationCurve = animationCurve
    }

    func updateState(_ state: inout AppState) {
      state.environment.keyboardState = EnvironmentState.KeyboardState(
        visibility: .visible(frame: self.frame),
        animationDuration: self.animationDuration,
        animationCurve: self.animationCurve
      )
    }
  }

  /// Keyboard is dismissed.
  struct KeyboardWillHide: AppStateUpdater, NotificationObserverDispatchable {
    init?(notification: Notification) {
      guard notification.name == UIResponder.keyboardWillHideNotification else {
        return nil
      }
    }

    func updateState(_ state: inout AppState) {
      state.environment.keyboardState.visibility = .hidden
    }
  }
}
