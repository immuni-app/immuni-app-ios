// CertificatesNC.swift
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
import Katana
import UIKit

class CertificatesNC: UINavigationController {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .darkContent
  }

  var store: PartialStore<AppState>

  init(store: PartialStore<AppState>) {
    self.store = store
      super.init(rootViewController: CertificatesVC(store: store, localState: CertificatesLS()))
  }

  required init?(coder aDecoder: NSCoder) {
    AppLogger.fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setNavigationBarHidden(true, animated: false)
    self.interactivePopGestureRecognizer?.delegate = nil
  }
}

