// MigrationManager.swift
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

/// The migration manager takes care of registering the migrations that need to be performed and
/// to handle errors while decoding the state.
///
/// Use this class as is if you don't have custom migrations to register. Upon failures the default
/// behaviour is to "abort"
open class PersistStoreMigrationManager<StateType: CodableState> {
  public init() {}

  /// Override point to register your migrations with the store migrator
  open func registerMigrations(migrator: PersistStoreMigrator) {}
}
