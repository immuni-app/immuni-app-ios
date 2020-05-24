// PersistStore.swift
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

import CryptoKit
import Extensions
import Foundation
import Katana

/// Module for the Katana Store that can be used to serialize/deserialize the state,
/// handle migrations in the state shape and take snapshots with each app build.
/// To use it, your State must conform to the `Encodable` protocol. See the Teleporter library for further information.
///
/// To install it, instantiate it in the AppDelegate and add the interceptor and the state initializer to your Katana Store:
/// ```
/// let persistStore = PersistStore<AppState>(
///   storage: UserDefaults.standard,
///   encryptionKey: encryptionKey,
///   currentBuildVersion: number,
///   migrationManager: AppMigrationManager()
/// )
///
/// self.store = Store<AppState>(
///   interceptors: [persistStore.katanaInterceptor],
///   dependencies: DependenciesContainer.self,
///   stateInitializer: persistStore.stateInitializer
/// )
/// ```
public class PersistStore<S: State & Codable> {
  internal let persistStoreInterceptor: PersistStoreInterceptor<S>

  private let storage: PersistStoreInterceptorStorage & MigrationLog
  private let encryptionKey: SymmetricKey
  private let currentBuildVersion: Int
  private let migrationManager: PersistStoreMigrationManager<S>
  private let persistStoreStateInitializer: PersistStoreStateInitializer<S>

  public convenience init(
    storage: PersistStoreInterceptorStorage & MigrationLog,
    encryptionKey: SymmetricKey,
    currentBuildVersion: Int,
    migrationManager: PersistStoreMigrationManager<S> = .init()
  ) {
    let persistStoreInterceptor = PersistStoreInterceptor<S>(
      storage: storage,
      currentBuildVersion: currentBuildVersion
    )

    self.init(
      storage: storage,
      encryptionKey: encryptionKey,
      currentBuildVersion: currentBuildVersion,
      persistStoreInterceptor: persistStoreInterceptor,
      migrationManager: migrationManager
    )
  }

  internal init(
    storage: PersistStoreInterceptorStorage & MigrationLog,
    encryptionKey: SymmetricKey,
    currentBuildVersion: Int,
    persistStoreInterceptor: PersistStoreInterceptor<S>,
    migrationManager: PersistStoreMigrationManager<S> = .init()
  ) {
    self.persistStoreInterceptor = persistStoreInterceptor
    self.storage = storage
    self.encryptionKey = encryptionKey
    self.currentBuildVersion = currentBuildVersion
    self.migrationManager = migrationManager
    self.persistStoreStateInitializer = PersistStoreStateInitializer<S>(
      getLatestStoredState: {
        persistStoreInterceptor.retrievePersistedRawState(encryptionKey: encryptionKey)
      },
      migrationLog: storage,
      migrationManager: migrationManager
    )
  }

  public var katanaInterceptor: StoreInterceptor {
    let interceptor = self.persistStoreInterceptor

    return { context in
      { next in
        { dispatchable in
          try next(dispatchable)

          guard let newState = context.getAnyState() as? S else {
            LibLogger.fatalError("Interceptor found a state with unexpected type")
          }

          guard !(dispatchable is AnySideEffect) else {
            // Side effects cannot change the state
            return
          }

          interceptor.appendPersistOperation(for: newState, encryptionKey: self.encryptionKey)
        }
      }
    }
  }

  public var katanaStateInitializer: PartialStore<S>.StateInitializer<S> {
    return self.persistStoreStateInitializer.stateInitializer
  }
}
