// ExposureNotificationManager.swift
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
import Foundation
import Hydra

public class ExposureNotificationManager {
  /// The internal provider of the Exposure Notification feature
  private let provider: ExposureNotificationProvider

  /// Initializer that allows to pass a custom `ExposureNotificationProvider`
  public init(provider: ExposureNotificationProvider) {
    self.provider = provider
    Self.synchronized { provider.activate() }
  }

  /// Convenience initializer that uses Apple's default if the version of iOS supports them, empty stubs otherwise.
  public convenience init() {
    let provider: ExposureNotificationProvider

    #if targetEnvironment(simulator)
      provider = ExposureNotificationProviderStub(status: .authorizedAndActive)
    #else
      if #available(iOS 13.5, *) {
        provider = ENManager()
      } else {
        provider = ExposureNotificationProviderStub(status: .restricted)
      }
    #endif

    self.init(provider: provider)
  }

  /// The current authorization status for the manager
  public func getStatus() -> Promise<ExposureNotificationStatus> {
    return Self.synchronized {
      .init(resolved: self.provider.status)
    }
  }

  /// If the user already granted authorization for the Exposure Notification, then start the manager. Otherwise, fail silently.
  /// This is meant to be called at every startup.
  /// In all cases it returns the updated manager status
  public func startIfAuthorized() -> Promise<ExposureNotificationStatus> {
    return Self.synchronized {
      self.enableManager(silently: true)
        .catch(in: .background) { _ in }
        .then(in: .background) { _ in self.provider.status }
    }
  }

  /// Explicitly ask the user authorization for the Exposure Notification. If granted, starts the manager.
  /// In all cases it returns the updated manager status
  public func askAuthorizationAndStart() -> Promise<ExposureNotificationStatus> {
    return Self.synchronized {
      self.enableManager(silently: false)
        .catch(in: .background) { _ in }
        .then(in: .background) { _ in self.provider.status }
    }
  }

  /// Returns a summary of the user's exposures.
  /// - Parameter configuration: a set of scores and weights to be applied to the detection session
  /// - Parameter diagnosisKeyURLs: the URLs containing the latest batches of COVID-positive keys
  public func getDetectionSummary(
    configuration: ExposureDetectionConfiguration,
    diagnosisKeyURLs: [URL]
  ) -> Promise<ExposureDetectionSummary> {
    return Self.synchronized {
      self.provider.detectExposures(configuration: configuration, diagnosisKeyURLs: diagnosisKeyURLs)
    }
  }

  /// Returns more detailed information about each exposure event of the user with a COVID-positive key.
  /// It assumes that `getDetectionSummary(keys:)` has been called before, and returns information about exposures to those keys.
  public func getExposureInfo(from summary: ExposureDetectionSummary, userExplanation: String) -> Promise<[ExposureInfo]> {
    switch summary {
    case .noMatch:
      return .init(resolved: [])
    case .matches(let info):
      return Self.synchronized {
        self.provider.getExposureInfo(from: info, userExplanation: userExplanation)
      }
    }
  }

  /// Returns the list of `TemporaryExposureKey`s by this user
  public func getDiagnosisKeys() -> Promise<[TemporaryExposureKey]> {
    return Self.synchronized {
      self.provider.getDiagnosisKeys()
    }
  }

  /// Disables the manager and prepares it for being destroyed.
  public func deactivate() -> Promise<Void> {
    return Self.synchronized {
      self.provider.deactivate()
    }
  }
}

// MARK: - Internal helpers

extension ExposureNotificationManager {
  /// The internal queue used to synchronize operations on the manager
  private static let managerQueue = DispatchQueue(label: "immuni.exposure_notification_manager.queue", qos: .userInteractive)

  /// Enables the manager, therefore starting the Exposure Notification feature.
  /// - Parameter silently: `true` if the operation should fail silently in case the permission was not granted, `false` if it
  /// should prompt the authorization request to the user.
  private func enableManager(silently: Bool) -> Promise<Void> {
    guard !silently || self.provider.status.canPerformDetection else {
      return .init(resolved: ())
    }

    return self.provider.setExposureNotificationEnabled(true)
  }

  /// Wraps a promise chain in a synchronized operation executed on the `managerQueue`
  @discardableResult
  static func synchronized<T>(_ block: @escaping () -> Promise<T>) -> Promise<T> {
    return Promise<T>(in: .custom(queue: self.managerQueue)) { resolve, reject, _ in
      do {
        resolve(try Hydra.await(block()))
      } catch {
        reject(error)
      }
    }.run()
  }
}
