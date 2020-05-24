// ExposureNotificationProvider.swift
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

/// Protocol that defines a provider of the Exposure Notification feature.
public protocol ExposureNotificationProvider {
  /// Returns the current status of the exposure notification service.
  var status: ExposureNotificationStatus { get }

  /// Activates the provider. This must be called at the beginning of the lifecycle of each provider's instance.
  func activate() -> Promise<Void>

  /// Enables or disables the exposure notification service.
  func setExposureNotificationEnabled(_ enabled: Bool) -> Promise<Void>

  /// Performs the download of keys from the given `diagnosisKeyURLs`, and returns a summary of all related exposure events.
  func detectExposures(configuration: ExposureDetectionConfiguration, diagnosisKeyURLs: [URL])
    -> Promise<ExposureDetectionSummary>

  /// Returns more detailed info about the exposure events summarized in an `ExposureDetectionSummary`
  func getExposureInfo(from summary: ExposureDetectionSummaryData, userExplanation: String) -> Promise<[ExposureInfo]>

  /// Retrieves the `TemporaryExposureKey`s of the user, after explicit authorization
  func getDiagnosisKeys() -> Promise<[TemporaryExposureKey]>

  /// Deactivates the provider, indicating that it can be discarded.
  func deactivate() -> Promise<Void>
}
