// ENManager+ExposureNotificationProvider.swift
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

import ExposureNotification
import Extensions
import Foundation
import Hydra

/// Conformance of `ENManager` to `ExposureNotificationProvider`.
@available(iOS 13.5, *)
extension ENManager: ExposureNotificationProvider {
  public var status: ExposureNotificationStatus {
    return ExposureNotificationStatus(
      authorizationStatus: Self.authorizationStatus,
      frameworkStatus: self.exposureNotificationStatus
    )
  }

  public func activate() -> Promise<Void> {
    return Promise { self.activate(completionHandler: $0) }
  }

  public func setExposureNotificationEnabled(_ enabled: Bool) -> Promise<Void> {
    return Promise { self.setExposureNotificationEnabled(enabled, completionHandler: $0) }
  }

  public func detectExposures(
    configuration: ExposureDetectionConfiguration,
    diagnosisKeyURLs: [URL]
  ) -> Promise<ExposureDetectionSummary> {
    let typedConfiguration = configuration as? ENExposureConfiguration
      ?? LibLogger.fatalError("Unexpected type passed as configuration \(configuration)")

    return Promise {
      self.detectExposures(
        configuration: typedConfiguration,
        diagnosisKeyURLs: diagnosisKeyURLs,
        completionHandler: $0
      )
    }
    .then { summary in summary.toExposureDetectionSummary() }
  }

  public func getExposureInfo(from summary: ExposureDetectionSummaryData, userExplanation: String) -> Promise<[ExposureInfo]> {
    let typedSummary = summary as? ENExposureDetectionSummary
      ?? LibLogger.fatalError("Unexpected type passed as summary \(summary)")

    return Promise { self.getExposureInfo(summary: typedSummary, userExplanation: userExplanation, completionHandler: $0) }
  }

  public func getDiagnosisKeys() -> Promise<[TemporaryExposureKey]> {
    return Promise {
      #if DEBUG
        // this method requires special entitlements that cannot be shipped on the App Store.
        // However, it is useful for debugging purposes.
        self.getTestDiagnosisKeys(completionHandler: $0)
      #else
        self.getDiagnosisKeys(completionHandler: $0)
      #endif
    }
  }

  public func deactivate() -> Promise<Void> {
    return Promise<Void> { resolve, _, _ in
      self.invalidationHandler = { resolve(()) }
      self.invalidate()
    }
  }
}
