// AnalyticsRequest.swift
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

import Alamofire
import Extensions
import Foundation
import ImmuniExposureNotification
import Models
import PushNotification

public struct AnalyticsRequest: Equatable, JSONRequest {
  // swiftlint:disable:next force_unwrapping
  public var baseURL = URL(string: "https://analytics.immuni.gov.it")!

  public var path = "/v1/analytics/apple/operational-info"
  public var method: HTTPMethod = .post
  public var cachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData

  public let jsonParameter: Body
  public let analyticsToken: String
  public let isDummy: Bool

  public var headers: [HTTPHeader] {
    return HTTPHeader.defaultImmuniHeaders + [
      .authorization(bearerToken: self.analyticsToken),
      .contentType("application/json; charset=UTF-8"),
      .dummyData(self.isDummy)
    ]
  }

  public init(body: Body, analyticsToken: String, isDummy: Bool) {
    self.jsonParameter = body
    self.analyticsToken = analyticsToken
    self.isDummy = isDummy
  }
}

public extension AnalyticsRequest {
  /// The request uses a body with specific choices to ensure that the packet
  /// sizes are always the same, regardless the content. For this reason, integers
  /// are used instead of booleans
  ///
  /// -seeAlso: Traffic-Analysis Mitigation document
  struct Body: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
      case province
      case exposurePermission = "exposure_permission"
      case notificationPermission = "notification_permission"
      case bluetoothActive = "bluetooth_active"
      case exposureNotification = "exposure_notification"
      case lastExposureDate = "last_risky_exposure_on"
    }

    public let province: String
    public let exposurePermission: Int
    public let notificationPermission: Int
    public let bluetoothActive: Int
    public let exposureNotification: Int
    public let lastExposureDate: String

    public init(
      province: Province,
      exposureNotificationStatus: ExposureNotificationStatus,
      pushNotificationStatus: PushNotificationStatus,
      lastExposureDate: Date?,
      now: () -> Date
    ) {
      self.province = province.rawValue
      self.exposurePermission = exposureNotificationStatus.canPerformDetection.intValue
      self.notificationPermission = pushNotificationStatus.allowsSendingNotifications.intValue

      let isBluetoothActive = exposureNotificationStatus != .authorizedAndBluetoothOff
      self.bluetoothActive = isBluetoothActive.intValue

      let isRiskyExposureDetected = lastExposureDate != nil
      self.exposureNotification = isRiskyExposureDetected.intValue
      self.lastExposureDate = (lastExposureDate ?? now()).utcIsoString // discarded if exposureNotification is false
    }
  }
}

public extension AnalyticsRequest.Body {
  /// Instantiates a dummy request body, which forces the caller to pass a `dummyToken` to ensure that it's the same length as
  /// a legitimate token.
  static func dummy(now: () -> Date) -> Self {
    let province = Province.allCases.randomElement()
      ?? LibLogger.fatalError("No provinces defined")

    let exposureNotificationStatus = ExposureNotificationStatus.allCases.randomElement()
      ?? LibLogger.fatalError("No exposure notification statuses defined")

    let pushNotificationStatus = PushNotificationStatus.allCases.randomElement()
      ?? LibLogger.fatalError("No push notification authorization status")

    let lastExposureDate = Bool.random() ? nil : now()

    return Self(
      province: province,
      exposureNotificationStatus: exposureNotificationStatus,
      pushNotificationStatus: pushNotificationStatus,
      lastExposureDate: lastExposureDate,
      now: now
    )
  }
}

private extension Bool {
  /// Returns the int value related to self
  var intValue: Int {
    return self ? 1 : 0
  }
}
