// CustomerSupportVC.swift
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
import Tempura

class CustomerSupportVC: ViewControllerWithLocalState<CustomerSupportView> {
  override func setupInteraction() {
    self.rootView.userDidTapClose = { [weak self] in
      // At the moment we don't have the need of informing the caller
      self?.dispatch(Hide(animated: true))
    }

    self.rootView.userDidScroll = { [weak self] scrollOffset in
      if scrollOffset > 0 {
        self?.localState.isHeaderVisible = true
      } else if scrollOffset < -20 {
        self?.localState.isHeaderVisible = false
      }
    }

    self.rootView.userDidTapActionButton = { [weak self] in
      self?.dispatch(Logic.Settings.ShowFAQs())
    }

    self.rootView.userDidTapContact = { [weak self] contact in
      switch contact {
      case .email:
        self?.dispatch(Logic.Settings.SendCustomerSupportEmail())
      case .phone(let number, _, _):
        self?.dispatch(Logic.Shared.DialPhoneNumber(number: number))
      }
    }
  }
}

// MARK: - LocalState

struct CustomerSupportLS: LocalState {
  /// Whether the header is visible in the view. The header is shown only when the content is scrolled.
  var isHeaderVisible: Bool = false
}
