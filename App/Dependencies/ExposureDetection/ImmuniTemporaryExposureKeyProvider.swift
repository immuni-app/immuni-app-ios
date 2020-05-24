// ImmuniTemporaryExposureKeyProvider.swift
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
import Hydra
import ImmuniExposureNotification
import Models
import Networking
import Persistence

/// Concrete implementation of `TemporaryExposureKeyProvider` that uses a `NetworkManager` to retrieve the chunks and a
/// `FileStorage` to persist them
class ImmuniTemporaryExposureKeyProvider: TemporaryExposureKeyProvider {
  private let networkManager: NetworkManager
  private let fileStorage: FileStorage

  public init(networkManager: NetworkManager, fileStorage: FileStorage) {
    self.networkManager = networkManager
    self.fileStorage = fileStorage
  }

  func getLatestKeyChunks(latestKnownChunkIndex: Int?) -> Promise<[TemporaryExposureKeyChunk]> {
    return self.getMissingChunksIndexes(latestKnownChunkIndex: latestKnownChunkIndex)
      .recover { error in
        guard case NetworkManager.Error.noBatchesFound = error else {
          // Unrecoverable error
          throw error
        }

        // No batches at all found on backend. Equivalent to no new batches.
        return .init(resolved: [])
      }
      .then { self.downloadChunks(with: $0) }
  }

  func clearLocalResources(for chunks: [TemporaryExposureKeyChunk]) -> Promise<Void> {
    return self.fileStorage
      .delete(chunks.flatMap { $0.localUrls })
  }

  private func getMissingChunksIndexes(latestKnownChunkIndex: Int?) -> Promise<[Int]> {
    self.networkManager.getKeysIndex()
      .then { (keysIndex: KeysIndex) -> [Int] in
        guard let latestKnownChunkIndex = latestKnownChunkIndex else {
          return Array(keysIndex.oldest ... keysIndex.newest)
        }

        guard keysIndex.newest > latestKnownChunkIndex else {
          return []
        }

        return Array(keysIndex.oldest.bounded(min: latestKnownChunkIndex) ... keysIndex.newest)
      }
  }

  private func downloadChunks(with indexes: [Int]) -> Promise<[TemporaryExposureKeyChunk]> {
    self.networkManager.downloadChunks(with: indexes)
      .then { chunksData in
        assert(chunksData.count == indexes.count)

        let chunksWithIndexes = zip(chunksData, indexes)

        let fileWritePromises = chunksWithIndexes
          .map { chunkData, index in
            self.fileStorage.write(chunkData, with: Self.fileName(for: index))
              .then { localUrls in TemporaryExposureKeyChunk(localUrls: localUrls, index: index) }
          }

        return all(fileWritePromises)
      }
  }

  private static func fileName(for index: Int) -> String {
    return String(format: "tek_%06d", index)
  }
}
