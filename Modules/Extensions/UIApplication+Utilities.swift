// UIApplication+Utilities.swift
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
import Hydra
import UIKit

public extension UIApplication {
  /// Asynchronously attempts to open the resource at the specified AppLink.
  /// If the AppLink is not provided or cannot be opened, the url is opened
  func goTo(url: URL, appLinkUrl: URL? = nil) -> Promise<Void> {
    return Promise(in: .main) { resolve, reject, _ in
      if let appLinkUrl = appLinkUrl, self.canOpenURL(appLinkUrl) {
        self.open(appLinkUrl, options: [:]) { $0 ? resolve(()) : reject(Error.cannotOpenURL) }
      } else if self.canOpenURL(url) {
        self.open(url, options: [:]) { $0 ? resolve(()) : reject(Error.cannotOpenURL) }
      } else {
        reject(Error.cannotOpenURL)
      }
    }
  }

  enum Error: Swift.Error {
    /// The iOS API function `UIApplication.open` could not open the given URL
    case cannotOpenURL
  }
}
