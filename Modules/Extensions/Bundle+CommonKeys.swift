// Bundle+CommonKeys.swift
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
import UIKit

public extension Bundle {
  /**
   `CFBundleShortVersionString` specifies the release version number of the bundle,
   which identifies a released iteration of the app.
   */
  var appVersion: String? {
    return self.infoDictionary?["CFBundleShortVersionString"] as? String
  }

  /**
   `CFBundleVersion` specifies the build version number of the bundle,
   which identifies an iteration (released or unreleased) of the bundle.
   */
  var bundleVersion: String? {
    return self.infoDictionary?["CFBundleVersion"] as? String
  }

  /// Specifies the id of the application in the Apple store
  var appStoreID: String? {
    return self.infoDictionary?["IMAppstoreID"] as? String
  }

  /// Helper to get the app name as is displayed in the springboard.
  var appDisplayName: String? {
    return self.infoDictionary?["CFBundleDisplayName"] as? String
  }

  /// The backend URL string
  var backendURLString: String? {
    return self.infoDictionary?["IMBackendURL"] as? String
  }

  /// The build version as integer
  var intBuildVersion: Int? {
    guard
      let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
      let intBuildVersion = Int(buildVersion)
    else {
      return nil
    }

    return intBuildVersion
  }

  /// Unwrapped getter for the bundle identifier
  var unwrappedBundleIdentifier: String {
    self.bundleIdentifier ?? LibLogger.fatalError("Missing bundle identifier")
  }
}
