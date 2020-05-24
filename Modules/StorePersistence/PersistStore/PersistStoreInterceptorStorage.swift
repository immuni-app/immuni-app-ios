// PersistStoreInterceptorStorage.swift
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

import Extensions
import Foundation

/// Protocol that is used to implement the storage for the `PersistStoreInterceptor`.
/// The library provides a default implementation for `UserDefaults`
public protocol PersistStoreInterceptorStorage {
  /**
   Persist a serialized state using a specific key as a reference

   - parameter state: the serialized state to persist
   - parameter key: an unique key that is used to later retrieve the state
   */
  func persistState(_ state: String, for key: String)

  /**
   Retrieve the persisted serialized state given the key
   - parameter key: the unique key that represents the state
   */
  func getPersistedState(for key: String) -> String?
}
