// Country.swift
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

public struct Country: Equatable, Codable, Hashable {
  public typealias ID = String
  public typealias NAME = String

  public var countryId: ID
  public var countryHumanReadableName: String

  public init(countryId: String, countryHumanReadableName: String) {
    self.countryId = countryId
    self.countryHumanReadableName = countryHumanReadableName
  }

  public static let italyId: Country.ID = "IT"
  public static let italyHumanReadableName: Country.NAME = "ITALIA"
}

extension Country: Comparable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.countryId == rhs.countryId
  }

  public static func < (lhs: Self, rhs: Self) -> Bool {
    return lhs.countryHumanReadableName < rhs.countryHumanReadableName
  }
}

public struct CountryOfInterest: Equatable, Codable {
  /// Country of interest
  public var country: Country

  /// Date of country selection
  public var selectionDate: Date?

  /// The index of latest processed chunk of `TemporaryExposureKeys`
  public var latestProcessedKeyChunkIndex: Int? = nil

  public init(country: Country, selectionDate: Date) {
    self.country = country
    self.selectionDate = selectionDate
  }

  public init(country: Country) {
    self.country = country
  }

  public static func == (lhs: CountryOfInterest, rhs: CountryOfInterest) -> Bool {
    return lhs.country == rhs.country
  }
}
