// UploadDataVC.swift
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
import Models
import Tempura

class UploadDataVC: ViewControllerWithLocalState<UploadDataView> {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.startCountDownIfNecessary()
  }

  override func setupInteraction() {
    self.rootView.didTapBack = { [weak self] in
      self?.dispatch(Hide(Screen.uploadData, animated: true))
    }

    self.rootView.didTapVerifyCode = { [weak self] in
      guard let code = self?.viewModel?.code else {
        return
      }
      self?.verifyCode(code: code)
    }

    self.rootView.didTapDiscoverMore = { [weak self] in
        self?.dispatch(Logic.PermissionTutorial.ShowHowToUploadWhenPositive(callCenterMode: self?.localState.callCenterMode ?? true))
    }
    self.rootView.didTapContact = { [weak self] in
      self?.dispatch(Logic.Shared.DialCallCenter())
    }
  }

  private func verifyCode(code: OTP) {
    self.localState.isLoading = true
    self.__unsafeDispatch(Logic.DataUpload.VerifyCode(code: code))
      .then {
        self.localState.isLoading = false
        self.localState.recentFailedAttempts = 0
      }
      .catch { _ in
        self.localState.isLoading = false
        self.localState.recentFailedAttempts += 1
        self.localState.errorSecondsLeft = UploadDataLS.backOffDuration(failedAttempts: self.localState.recentFailedAttempts)
        self.startCountDownIfNecessary()
        self.dispatch(Logic.Accessibility.PostNotification(
          notification: .layoutChanged,
          argument: self.rootView.verifyCard.error
        ))
      }
  }

  private func startCountDownIfNecessary() {
    self.countdown(from: self.localState.errorSecondsLeft)
  }

  private func countdown(from value: Int) {
    self.localState.errorSecondsLeft = value
    guard value > 0 else {
      return
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.countdown(from: value - 1)
    }
  }
}

// MARK: - LocalState

struct UploadDataLS: LocalState {
  /// True if it's not possible to execute a new request.
  var isLoading: Bool = false
  /// The number of recently failed attempts. Used to evaluate the backoff duration.
  var recentFailedAttempts: Int
  /// The number of seconds until a new request can be performed.
  var errorSecondsLeft: Int
    
  let callCenterMode: Bool


  /// Exponential backoff capped at 30 minutes
  static func backOffDuration(failedAttempts: Int) -> Int {
    let exponent = min(failedAttempts, 60) // avoid Int overflow
    return (Int(pow(2, Double(exponent - 1))) * 5).bounded(max: 30 * 60)
  }
}
