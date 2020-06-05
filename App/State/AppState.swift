// AppState.swift
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
import Models

struct AppState: State, Codable {
  typealias UserId = String

  enum CodingKeys: CodingKey {
    case toggles
    case user
    case exposureDetection
    case configuration
    case analytics
    case ingestion
    case faq
  }

  // MARK: Persisted slices

  /// Slice related to toggles used by the application
  var toggles = TogglesState()

  /// Slice related to the user
  var user = UserState()

  /// Slice related to Exposure Detection
  var exposureDetection = ExposureDetectionState()

  /// Slice related to configuration parameters for the app
  var configuration = Configuration()

  /// Slice of state related to the analytics part of the app
  var analytics = AnalyticsState()

  /// Slice of the state related to the ingestion server
  var ingestion = IngestionState()

  /// Slice of state related to the FAQ
  var faq = FaqState()

  // MARK: Not Persisted slices

  var environment = EnvironmentState()

  init() {}
}

// MARK: Force update

extension AppState {
  /// Whether the app should be blocked because of an urgent update.
  /// This is used only in exceptional cases (e.g., distruptive bugs in production)
  func shouldBlockApplication(bundle: Bundle) -> Bool {
    if self.toggles.mustShowForceUpdate {
      return true
    }

    guard let buildVersion = bundle.intBuildVersion else {
      return false
    }

    return buildVersion < self.configuration.minimumBuildVersion
  }
}
