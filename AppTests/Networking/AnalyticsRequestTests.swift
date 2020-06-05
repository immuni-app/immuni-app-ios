// AnalyticsRequestTests.swift
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

// swiftlint:disable superfluous_disable_command force_try implicitly_unwrapped_optional force_unwrapping force_cast

import Alamofire
import Models
import Networking
import XCTest

class AnalyticsRequestTests: XCTestCase {
  func testAuthorized() {
    let body = AnalyticsRequest.Body(
      province: .agrigento,
      exposureNotificationStatus: .authorized,
      pushNotificationStatus: .authorized,
      riskyExposureDetected: true,
      analyticsToken: "token"
    )

    XCTAssertEqual(body.operatingSystem, "ios")
    XCTAssertEqual(body.province, Province.agrigento.rawValue)
    XCTAssertEqual(body.exposurePermission, 1)
    XCTAssertEqual(body.notificationPermission, 1)
    XCTAssertEqual(body.bluetoothActive, 1)
    XCTAssertEqual(body.exposureNotification, 1)
    XCTAssertEqual(body.analyticsToken, "token")
  }

  func testNotAuthorized() {
    let body = AnalyticsRequest.Body(
      province: .agrigento,
      exposureNotificationStatus: .notAuthorized,
      pushNotificationStatus: .denied,
      riskyExposureDetected: true,
      analyticsToken: "token"
    )

    XCTAssertEqual(body.operatingSystem, "ios")
    XCTAssertEqual(body.province, Province.agrigento.rawValue)
    XCTAssertEqual(body.exposurePermission, 0)
    XCTAssertEqual(body.notificationPermission, 0)
    XCTAssertEqual(body.bluetoothActive, 1)
    XCTAssertEqual(body.exposureNotification, 1)
    XCTAssertEqual(body.analyticsToken, "token")
  }

  func testRestricted() {
    let body = AnalyticsRequest.Body(
      province: .agrigento,
      exposureNotificationStatus: .restricted,
      pushNotificationStatus: .denied,
      riskyExposureDetected: true,
      analyticsToken: "token"
    )

    XCTAssertEqual(body.operatingSystem, "ios")
    XCTAssertEqual(body.province, Province.agrigento.rawValue)
    XCTAssertEqual(body.exposurePermission, 0)
    XCTAssertEqual(body.notificationPermission, 0)
    XCTAssertEqual(body.bluetoothActive, 1)
    XCTAssertEqual(body.exposureNotification, 1)
    XCTAssertEqual(body.analyticsToken, "token")
  }

  func testUnknown() {
    let body = AnalyticsRequest.Body(
      province: .agrigento,
      exposureNotificationStatus: .unknown,
      pushNotificationStatus: .notDetermined,
      riskyExposureDetected: true,
      analyticsToken: "token"
    )

    XCTAssertEqual(body.operatingSystem, "ios")
    XCTAssertEqual(body.province, Province.agrigento.rawValue)
    XCTAssertEqual(body.exposurePermission, 0)
    XCTAssertEqual(body.notificationPermission, 0)
    XCTAssertEqual(body.bluetoothActive, 1)
    XCTAssertEqual(body.exposureNotification, 1)
    XCTAssertEqual(body.analyticsToken, "token")
  }

  func testBluetoothOff() {
    let body = AnalyticsRequest.Body(
      province: .agrigento,
      exposureNotificationStatus: .authorizedAndBluetoothOff,
      pushNotificationStatus: .denied,
      riskyExposureDetected: true,
      analyticsToken: "token"
    )

    XCTAssertEqual(body.operatingSystem, "ios")
    XCTAssertEqual(body.province, Province.agrigento.rawValue)
    XCTAssertEqual(body.exposurePermission, 0)
    XCTAssertEqual(body.notificationPermission, 0)
    XCTAssertEqual(body.bluetoothActive, 0)
    XCTAssertEqual(body.exposureNotification, 1)
    XCTAssertEqual(body.analyticsToken, "token")
  }

  func testEncodedCorrectly() throws {
    let body = AnalyticsRequest.Body(
      province: .agrigento,
      exposureNotificationStatus: .authorized,
      pushNotificationStatus: .authorized,
      riskyExposureDetected: true,
      analyticsToken: "token"
    )

    let data = try JSONEncoder().encode(body)
    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    XCTAssertEqual(dictionary?["os"] as? String, "ios")
    XCTAssertEqual(dictionary?["province"] as? String, Province.agrigento.rawValue)
    XCTAssertEqual(dictionary?["exposure_permission"] as? Int, 1)
    XCTAssertEqual(dictionary?["notification_permission"] as? Int, 1)
    XCTAssertEqual(dictionary?["bluetooth_active"] as? Int, 1)
    XCTAssertEqual(dictionary?["exposure_notification"] as? Int, 1)
    XCTAssertEqual(dictionary?["device_token"] as? String, "token")
  }
}
