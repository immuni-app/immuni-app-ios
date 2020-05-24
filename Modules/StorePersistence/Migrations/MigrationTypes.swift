// MigrationTypes.swift
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

/// Raw representation of the State as Swift Dictionary
public typealias RawState = [String: Any]
/// ID/Name of a migration
public typealias MigrationID = String
/// A migration handler modifies a raw state passed as input to perform a migration
public typealias MigrationHandler = (inout RawState) -> Void
/// Convenience typealias for a `State` that is also `Codable`
public typealias CodableState = State & Codable

/// Describes how to handle a failure in decoding the state when the app starts or a migration is performed
public enum ErrorHandlingType {
  /// StorePersistence will try to decode the state again with the provided json
  case retry(RawState)
  /// StorePersistence will just crash
  case abort
}

/// Where/when did a decoding error occur
public enum DecodingErrorContext: Equatable {
  /// When the app was started, before applying any migration
  case atAppStart
  /// After applying the migrations
  case afterPerformingMigrations([MigrationID])
  /// After trying to handle an error with error handling type `retry(_)`
  case afterRetry
}
