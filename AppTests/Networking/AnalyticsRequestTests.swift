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
    let date = Date(timeIntervalSince1970: 1_591_961_672) //  2020-06-12T11:34:32
    let body = AnalyticsRequest.Body(
      province: .agrigento,
      exposureNotificationStatus: .authorized,
      pushNotificationStatus: .authorized,
      lastExposureDate: date,
      now: { Date() }
    )

    XCTAssertEqual(body.province, Province.agrigento.rawValue)
    XCTAssertEqual(body.exposurePermission, 1)
    XCTAssertEqual(body.notificationPermission, 1)
    XCTAssertEqual(body.bluetoothActive, 1)
    XCTAssertEqual(body.exposureNotification, 1)
    XCTAssertEqual(body.lastExposureDate, "2020-06-12")
  }

  func testNotAuthorized() {
    let date = Date(timeIntervalSince1970: 1_591_961_672) //  2020-06-12T11:34:32
    let body = AnalyticsRequest.Body(
      province: .agrigento,
      exposureNotificationStatus: .notAuthorized,
      pushNotificationStatus: .denied,
      lastExposureDate: date,
      now: { Date() }
    )

    XCTAssertEqual(body.province, Province.agrigento.rawValue)
    XCTAssertEqual(body.exposurePermission, 0)
    XCTAssertEqual(body.notificationPermission, 0)
    XCTAssertEqual(body.bluetoothActive, 1)
    XCTAssertEqual(body.exposureNotification, 1)
    XCTAssertEqual(body.lastExposureDate, "2020-06-12")
  }

  func testRestricted() {
    let date = Date(timeIntervalSince1970: 1_591_961_672) //  2020-06-12T11:34:32
    let body = AnalyticsRequest.Body(
      province: .agrigento,
      exposureNotificationStatus: .restricted,
      pushNotificationStatus: .denied,
      lastExposureDate: date,
      now: { Date() }
    )

    XCTAssertEqual(body.province, Province.agrigento.rawValue)
    XCTAssertEqual(body.exposurePermission, 0)
    XCTAssertEqual(body.notificationPermission, 0)
    XCTAssertEqual(body.bluetoothActive, 1)
    XCTAssertEqual(body.exposureNotification, 1)
    XCTAssertEqual(body.lastExposureDate, "2020-06-12")
  }

  func testUnknown() {
    let date = Date(timeIntervalSince1970: 1_591_961_672) //  2020-06-12T11:34:32
    let body = AnalyticsRequest.Body(
      province: .agrigento,
      exposureNotificationStatus: .unknown,
      pushNotificationStatus: .notDetermined,
      lastExposureDate: date,
      now: { Date() }
    )

    XCTAssertEqual(body.province, Province.agrigento.rawValue)
    XCTAssertEqual(body.exposurePermission, 0)
    XCTAssertEqual(body.notificationPermission, 0)
    XCTAssertEqual(body.bluetoothActive, 1)
    XCTAssertEqual(body.exposureNotification, 1)
    XCTAssertEqual(body.lastExposureDate, "2020-06-12")
  }

  func testBluetoothOff() {
    let date = Date(timeIntervalSince1970: 1_591_961_672) //  2020-06-12T11:34:32
    let body = AnalyticsRequest.Body(
      province: .agrigento,
      exposureNotificationStatus: .authorizedAndBluetoothOff,
      pushNotificationStatus: .denied,
      lastExposureDate: date,
      now: { Date() }
    )

    XCTAssertEqual(body.province, Province.agrigento.rawValue)
    XCTAssertEqual(body.exposurePermission, 0)
    XCTAssertEqual(body.notificationPermission, 0)
    XCTAssertEqual(body.bluetoothActive, 0)
    XCTAssertEqual(body.exposureNotification, 1)
    XCTAssertEqual(body.lastExposureDate, "2020-06-12")
  }

  func testNoExposures() {
    let date = Date(timeIntervalSince1970: 1_591_961_672) //  2020-06-12T11:34:32
    let now = { date }
    let body = AnalyticsRequest.Body(
      province: .agrigento,
      exposureNotificationStatus: .authorizedAndBluetoothOff,
      pushNotificationStatus: .denied,
      lastExposureDate: nil,
      now: now
    )

    XCTAssertEqual(body.province, Province.agrigento.rawValue)
    XCTAssertEqual(body.exposurePermission, 0)
    XCTAssertEqual(body.notificationPermission, 0)
    XCTAssertEqual(body.bluetoothActive, 0)
    XCTAssertEqual(body.exposureNotification, 0)
    XCTAssertEqual(body.lastExposureDate, "2020-06-12")
  }

  func testEncodedCorrectly() throws {
    let date = Date(timeIntervalSince1970: 1_591_961_672) //  2020-06-12T11:34:32
    let body = AnalyticsRequest.Body(
      province: .agrigento,
      exposureNotificationStatus: .authorized,
      pushNotificationStatus: .authorized,
      lastExposureDate: date,
      now: { Date() }
    )

    let data = try JSONEncoder().encode(body)
    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    XCTAssertEqual(dictionary?["province"] as? String, Province.agrigento.rawValue)
    XCTAssertEqual(dictionary?["exposure_permission"] as? Int, 1)
    XCTAssertEqual(dictionary?["notification_permission"] as? Int, 1)
    XCTAssertEqual(dictionary?["bluetooth_active"] as? Int, 1)
    XCTAssertEqual(dictionary?["exposure_notification"] as? Int, 1)
  }
}
