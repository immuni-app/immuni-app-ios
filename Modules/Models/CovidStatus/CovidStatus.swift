// CovidStatus.swift
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

/// An enum representing the "covid" status in which the user can be
public enum CovidStatus {
  /// The initial state of the statuses. Here we don't have any specific information
  /// about the user
  case neutral

  /// The user had a contact with a COVID-19 positive person
  case risk(lastContact: CalendarDay)

  /// The user is positive to COVID-19. This state is inferred from the `data upload`
  /// functionality (that is, TEKs upload)
  case positive(lastUpload: CalendarDay)

  /// Whether the state represents a positive
  /// state to covid
  public var isCovidPositive: Bool {
    switch self {
    case .risk, .neutral:
      return false

    case .positive:
      return true
    }
  }
}

// MARK: Extensions

public extension CovidStatus {
  /// The raw case of the enum, used to compare user states qualitatively
  enum RawCase: Equatable {
    case neutral
    case risk
    case positive
  }

  var rawCase: RawCase {
    switch self {
    case .neutral:
      return .neutral
    case .risk:
      return .risk
    case .positive:
      return .positive
    }
  }
}

extension CovidStatus: Codable {
  enum CodingKeys: String, CodingKey {
    case type
    case date
  }

  enum Case: String, Codable {
    case neutral
    case risk
    case positive
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Self.CodingKeys)
    let type = try container.decode(Self.Case.self, forKey: .type)

    switch type {
    case .neutral:
      self = .neutral

    case .risk:
      let date = try container.decode(CalendarDay.self, forKey: .date)
      self = .risk(lastContact: date)

    case .positive:
      let date = try container.decode(CalendarDay.self, forKey: .date)
      self = .positive(lastUpload: date)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Self.CodingKeys)

    switch self {
    case .neutral:
      try container.encode(Self.Case.neutral, forKey: .type)

    case .risk(let date):
      try container.encode(Self.Case.risk, forKey: .type)
      try container.encode(date, forKey: .date)

    case .positive(let date):
      try container.encode(Self.Case.positive, forKey: .type)
      try container.encode(date, forKey: .date)
    }
  }
}
