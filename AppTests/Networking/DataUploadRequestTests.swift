// DataUploadRequestTests.swift
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
import Models
import Networking
import XCTest

class DataUploadRequestTests: XCTestCase {
  func testTeksAreCappedTo14() throws {
    let teks = (0 ..< 100).map { _ in CodableTemporaryExposureKey.mock() }
    let requestBody = DataUploadRequest.Body(
      teks: teks,
      province: "AA",
      exposureDetectionSummaries: [],
      maximumExposureInfoCount: 0,
      maximumExposureDetectionSummaryCount: 0,
      countriesOfInterest: []
    )

    XCTAssertEqual(requestBody.teks.count, 14)
  }

  func testTeksAreSortedByRollingNumberDescending() throws {
    let teks = (0 ..< 100).map { _ in CodableTemporaryExposureKey.mock() }.shuffled()
    let requestBody = DataUploadRequest.Body(
      teks: teks,
      province: "AA",
      exposureDetectionSummaries: [],
      maximumExposureInfoCount: 0,
      maximumExposureDetectionSummaryCount: 0,
      countriesOfInterest: []
    )

    for (index, tek) in requestBody.teks.enumerated() {
      guard let nextTek = requestBody.teks[safe: index + 1] else {
        continue
      }

      XCTAssertGreaterThanOrEqual(tek.rollingStartNumber, nextTek.rollingStartNumber)
    }
  }

  func testSummariesAreCapped() throws {
    let cap = 100
    let summaries = (0 ..< 1000).map { _ in CodableExposureDetectionSummary.mock() }
    let requestBody = DataUploadRequest.Body(
      teks: [],
      province: "AA",
      exposureDetectionSummaries: summaries,
      maximumExposureInfoCount: 0,
      maximumExposureDetectionSummaryCount: cap,
      countriesOfInterest: []
    )

    XCTAssertEqual(requestBody.exposureDetectionSummaries.count, cap)
  }

  func testExposureInfoAreCapped() throws {
    let cap = 100
    let summaries = (0 ..< 1000).map { _ in CodableExposureDetectionSummary.mock() }
    let requestBody = DataUploadRequest.Body(
      teks: [],
      province: "AA",
      exposureDetectionSummaries: summaries,
      maximumExposureInfoCount: cap,
      maximumExposureDetectionSummaryCount: Int.max,
      countriesOfInterest: []
    )

    XCTAssertEqual(requestBody.exposureDetectionSummaries.flatMap { $0.exposureInfo }.count, cap)
  }

  func testLeastRecentSummaryIsDiscarded() throws {
    let cap = 2
    let date = Date()
    let oldestDate = date.addingTimeInterval(-300_000)
    let newestDate = date.addingTimeInterval(300_000)

    let oldSummary = CodableExposureDetectionSummary(
      date: oldestDate,
      matchedKeyCount: 1,
      daysSinceLastExposure: 2,
      attenuationDurations: [100, 200],
      maximumRiskScore: 3,
      exposureInfo: []
    )
    let normalSummary = CodableExposureDetectionSummary(
      date: date,
      matchedKeyCount: 1,
      daysSinceLastExposure: 2,
      attenuationDurations: [100, 200],
      maximumRiskScore: 3,
      exposureInfo: []
    )
    let recentSummary = CodableExposureDetectionSummary(
      date: newestDate,
      matchedKeyCount: 1,
      daysSinceLastExposure: 2,
      attenuationDurations: [100, 200],
      maximumRiskScore: 3,
      exposureInfo: []
    )

    let summaries: [CodableExposureDetectionSummary] = [normalSummary, oldSummary, recentSummary]

    let requestBody = DataUploadRequest.Body(
      teks: [],
      province: "AA",
      exposureDetectionSummaries: summaries,
      maximumExposureInfoCount: 0,
      maximumExposureDetectionSummaryCount: cap,
      countriesOfInterest: []
    )

    XCTAssertEqual(Set(requestBody.exposureDetectionSummaries), Set([oldSummary, normalSummary]))
  }

  func testMostRecentInfoIsDiscardedIfSameRisk() throws {
    let cap = 2
    let risk = 3
    let date = Date()
    let oldestDate = date.addingTimeInterval(-300_000)
    let newestDate = date.addingTimeInterval(300_000)

    let oldInfo = CodableExposureInfo(
      date: oldestDate,
      duration: 1,
      attenuationValue: 2,
      attenuationDurations: [100, 200],
      transmissionRiskLevel: 3,
      totalRiskScore: risk
    )

    let normalInfo = CodableExposureInfo(
      date: date,
      duration: 1,
      attenuationValue: 2,
      attenuationDurations: [100, 200],
      transmissionRiskLevel: 3,
      totalRiskScore: risk
    )

    let recentInfo = CodableExposureInfo(
      date: newestDate,
      duration: 1,
      attenuationValue: 2,
      attenuationDurations: [100, 200],
      transmissionRiskLevel: 3,
      totalRiskScore: risk
    )

    let summary = CodableExposureDetectionSummary(
      date: newestDate,
      matchedKeyCount: 1,
      daysSinceLastExposure: 2,
      attenuationDurations: [100, 200],
      maximumRiskScore: 3,
      exposureInfo: [oldInfo, recentInfo, normalInfo]
    )

    let requestBody = DataUploadRequest.Body(
      teks: [],
      province: "AA",
      exposureDetectionSummaries: [summary],
      maximumExposureInfoCount: cap,
      maximumExposureDetectionSummaryCount: Int.max,
      countriesOfInterest: []
    )

    XCTAssertEqual(Set(requestBody.exposureDetectionSummaries.flatMap { $0.exposureInfo }), Set([normalInfo, oldInfo]))
  }

  func testLowestRiskInfoIsDiscarded() throws {
    let cap = 2
    let date = Date()

    let lowRisk = CodableExposureInfo(
      date: date,
      duration: 1,
      attenuationValue: 2,
      attenuationDurations: [100, 200],
      transmissionRiskLevel: 3,
      totalRiskScore: 1
    )
    let normalRisk = CodableExposureInfo(
      date: date,
      duration: 1,
      attenuationValue: 2,
      attenuationDurations: [100, 200],
      transmissionRiskLevel: 3,
      totalRiskScore: 2
    )
    let highRisk = CodableExposureInfo(
      date: date,
      duration: 1,
      attenuationValue: 2,
      attenuationDurations: [100, 200],
      transmissionRiskLevel: 3,
      totalRiskScore: 3
    )

    let summary = CodableExposureDetectionSummary(
      date: date,
      matchedKeyCount: 1,
      daysSinceLastExposure: 2,
      attenuationDurations: [100, 200],
      maximumRiskScore: 3,
      exposureInfo: [lowRisk, highRisk, normalRisk]
    )

    let requestBody = DataUploadRequest.Body(
      teks: [],
      province: "AA",
      exposureDetectionSummaries: [summary],
      maximumExposureInfoCount: cap,
      maximumExposureDetectionSummaryCount: Int.max,
      countriesOfInterest: []
    )

    XCTAssertEqual(Set(requestBody.exposureDetectionSummaries.flatMap { $0.exposureInfo }), Set([normalRisk, highRisk]))
  }

  // european countries
  func testTeksAreCappedTo14WithCountriesOfInterest() throws {
    let teks = (0 ..< 100).map { _ in CodableTemporaryExposureKey.mock() }
    let requestBody = DataUploadRequest.Body(
      teks: teks,
      province: "AA",
      exposureDetectionSummaries: [],
      maximumExposureInfoCount: 0,
      maximumExposureDetectionSummaryCount: 0,
      countriesOfInterest: [
        Country(countryId: "PL", countryHumanReadableName: "POLONIA"),
        Country(countryId: "DE", countryHumanReadableName: "GERMANIA")
      ]
    )

    XCTAssertEqual(requestBody.teks.count, 14)
  }

  func testTeksAreSortedByRollingNumberDescendingWithCountriesOfInterest() throws {
    let teks = (0 ..< 100).map { _ in CodableTemporaryExposureKey.mock() }.shuffled()
    let requestBody = DataUploadRequest.Body(
      teks: teks,
      province: "AA",
      exposureDetectionSummaries: [],
      maximumExposureInfoCount: 0,
      maximumExposureDetectionSummaryCount: 0,
      countriesOfInterest: [
        Country(countryId: "PL", countryHumanReadableName: "POLONIA"),
        Country(countryId: "DE", countryHumanReadableName: "GERMANIA")
      ]
    )

    for (index, tek) in requestBody.teks.enumerated() {
      guard let nextTek = requestBody.teks[safe: index + 1] else {
        continue
      }

      XCTAssertGreaterThanOrEqual(tek.rollingStartNumber, nextTek.rollingStartNumber)
    }
  }

  func testSummariesAreCappedWithCountriesOfInterest() throws {
    let cap = 100
    let summaries = (0 ..< 1000).map { _ in CodableExposureDetectionSummary.mock() }
    let requestBody = DataUploadRequest.Body(
      teks: [],
      province: "AA",
      exposureDetectionSummaries: summaries,
      maximumExposureInfoCount: 0,
      maximumExposureDetectionSummaryCount: cap,
      countriesOfInterest: [
        Country(countryId: "PL", countryHumanReadableName: "POLONIA"),
        Country(countryId: "DE", countryHumanReadableName: "GERMANIA")
      ]
    )

    XCTAssertEqual(requestBody.exposureDetectionSummaries.count, cap)
  }

  func testExposureInfoAreCappedWithCountriesOfInterest() throws {
    let cap = 100
    let summaries = (0 ..< 1000).map { _ in CodableExposureDetectionSummary.mock() }
    let requestBody = DataUploadRequest.Body(
      teks: [],
      province: "AA",
      exposureDetectionSummaries: summaries,
      maximumExposureInfoCount: cap,
      maximumExposureDetectionSummaryCount: Int.max,
      countriesOfInterest: [
        Country(countryId: "PL", countryHumanReadableName: "POLONIA"),
        Country(countryId: "DE", countryHumanReadableName: "GERMANIA")
      ]
    )

    XCTAssertEqual(requestBody.exposureDetectionSummaries.flatMap { $0.exposureInfo }.count, cap)
  }

  func testLeastRecentSummaryIsDiscardedWithCountriesOfInterest() throws {
    let cap = 2
    let date = Date()
    let oldestDate = date.addingTimeInterval(-300_000)
    let newestDate = date.addingTimeInterval(300_000)

    let oldSummary = CodableExposureDetectionSummary(
      date: oldestDate,
      matchedKeyCount: 1,
      daysSinceLastExposure: 2,
      attenuationDurations: [100, 200],
      maximumRiskScore: 3,
      exposureInfo: []
    )
    let normalSummary = CodableExposureDetectionSummary(
      date: date,
      matchedKeyCount: 1,
      daysSinceLastExposure: 2,
      attenuationDurations: [100, 200],
      maximumRiskScore: 3,
      exposureInfo: []
    )
    let recentSummary = CodableExposureDetectionSummary(
      date: newestDate,
      matchedKeyCount: 1,
      daysSinceLastExposure: 2,
      attenuationDurations: [100, 200],
      maximumRiskScore: 3,
      exposureInfo: []
    )

    let summaries: [CodableExposureDetectionSummary] = [normalSummary, oldSummary, recentSummary]

    let requestBody = DataUploadRequest.Body(
      teks: [],
      province: "AA",
      exposureDetectionSummaries: summaries,
      maximumExposureInfoCount: 0,
      maximumExposureDetectionSummaryCount: cap,
      countriesOfInterest: [
        Country(countryId: "PL", countryHumanReadableName: "POLONIA"),
        Country(countryId: "DE", countryHumanReadableName: "GERMANIA")
      ]
    )

    XCTAssertEqual(Set(requestBody.exposureDetectionSummaries), Set([oldSummary, normalSummary]))
  }

  func testMostRecentInfoIsDiscardedIfSameRiskWithCountriesOfInterest() throws {
    let cap = 2
    let risk = 3
    let date = Date()
    let oldestDate = date.addingTimeInterval(-300_000)
    let newestDate = date.addingTimeInterval(300_000)

    let oldInfo = CodableExposureInfo(
      date: oldestDate,
      duration: 1,
      attenuationValue: 2,
      attenuationDurations: [100, 200],
      transmissionRiskLevel: 3,
      totalRiskScore: risk
    )

    let normalInfo = CodableExposureInfo(
      date: date,
      duration: 1,
      attenuationValue: 2,
      attenuationDurations: [100, 200],
      transmissionRiskLevel: 3,
      totalRiskScore: risk
    )

    let recentInfo = CodableExposureInfo(
      date: newestDate,
      duration: 1,
      attenuationValue: 2,
      attenuationDurations: [100, 200],
      transmissionRiskLevel: 3,
      totalRiskScore: risk
    )

    let summary = CodableExposureDetectionSummary(
      date: newestDate,
      matchedKeyCount: 1,
      daysSinceLastExposure: 2,
      attenuationDurations: [100, 200],
      maximumRiskScore: 3,
      exposureInfo: [oldInfo, recentInfo, normalInfo]
    )

    let requestBody = DataUploadRequest.Body(
      teks: [],
      province: "AA",
      exposureDetectionSummaries: [summary],
      maximumExposureInfoCount: cap,
      maximumExposureDetectionSummaryCount: Int.max,
      countriesOfInterest: [
        Country(countryId: "PL", countryHumanReadableName: "POLONIA"),
        Country(countryId: "DE", countryHumanReadableName: "GERMANIA")
      ]
    )

    XCTAssertEqual(Set(requestBody.exposureDetectionSummaries.flatMap { $0.exposureInfo }), Set([normalInfo, oldInfo]))
  }

  func testLowestRiskInfoIsDiscardedWithCountriesOfInterest() throws {
    let cap = 2
    let date = Date()

    let lowRisk = CodableExposureInfo(
      date: date,
      duration: 1,
      attenuationValue: 2,
      attenuationDurations: [100, 200],
      transmissionRiskLevel: 3,
      totalRiskScore: 1
    )
    let normalRisk = CodableExposureInfo(
      date: date,
      duration: 1,
      attenuationValue: 2,
      attenuationDurations: [100, 200],
      transmissionRiskLevel: 3,
      totalRiskScore: 2
    )
    let highRisk = CodableExposureInfo(
      date: date,
      duration: 1,
      attenuationValue: 2,
      attenuationDurations: [100, 200],
      transmissionRiskLevel: 3,
      totalRiskScore: 3
    )

    let summary = CodableExposureDetectionSummary(
      date: date,
      matchedKeyCount: 1,
      daysSinceLastExposure: 2,
      attenuationDurations: [100, 200],
      maximumRiskScore: 3,
      exposureInfo: [lowRisk, highRisk, normalRisk]
    )

    let requestBody = DataUploadRequest.Body(
      teks: [],
      province: "AA",
      exposureDetectionSummaries: [summary],
      maximumExposureInfoCount: cap,
      maximumExposureDetectionSummaryCount: Int.max,
      countriesOfInterest: [
        Country(countryId: "PL", countryHumanReadableName: "POLONIA"),
        Country(countryId: "DE", countryHumanReadableName: "GERMANIA")
      ]
    )

    XCTAssertEqual(Set(requestBody.exposureDetectionSummaries.flatMap { $0.exposureInfo }), Set([normalRisk, highRisk]))
  }
}
