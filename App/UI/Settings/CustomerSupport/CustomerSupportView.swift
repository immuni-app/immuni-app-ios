// CustomerSupportView.swift
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

struct CustomerSupportVM: ViewModelWithLocalState {}

extension CustomerSupportVM {
  init?(state: AppState?, localState: CustomerSupportLS) {
    guard let state = state else {
      return nil
    }
  }
}

// MARK: - View

class CustomerSupportView: UIView, ViewControllerModellableView {
  typealias VM = CustomerSupportVM

  // MARK: - Setup

  func setup() {}

  // MARK: - Style

  func style() {
    Self.Style.background(self)
  }

  // MARK: - Update

  func update(oldModel: VM?) {
    guard let model = self.model else {
      return
    }
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()
  }
}

// MARK: - Style

private extension CustomerSupportView {
  enum Style {
    static func background(_ view: UIView) {
      view.backgroundColor = Palette.redLight
    }
  }
}
