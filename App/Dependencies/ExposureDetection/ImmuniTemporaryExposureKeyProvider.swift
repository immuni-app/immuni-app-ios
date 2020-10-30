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
  /// This number represents the maximum amount of chunks that the EN APIs
  /// can manage in a 24-hour period as per documentation.
  /// We need to limit the amount ot chunks we download to prevent hitting
  /// this rate limit.
  ///
  /// - seeAlso: https://developer.apple.com/documentation/exposurenotification/setting_up_an_exposure_notification_server
  static let keyDailyRateLimit = 15
  private var keyDailyRateLimitCounter: Int

  private let networkManager: NetworkManager
  private let fileStorage: FileStorage

  public init(networkManager: NetworkManager, fileStorage: FileStorage) {
    self.networkManager = networkManager
    self.fileStorage = fileStorage
    self.keyDailyRateLimitCounter = 0
  }

  func getLatestKeyChunks(
    latestKnownChunkIndex: Int?,
    country: Country?,
    isFirstFlow: Bool?
  ) -> Promise<[TemporaryExposureKeyChunk]> {
    // swiftlint:disable:next unused_optional_binding
    if let _ = isFirstFlow {
      self.keyDailyRateLimitCounter = Self.keyDailyRateLimit
    }
    return self.getMissingChunksIndexes(
      latestKnownChunkIndex: latestKnownChunkIndex,
      country: country
    )
    .recover { error in
      guard case NetworkManager.Error.noBatchesFound = error else {
        // Unrecoverable error
        throw error
      }

      // No batches at all found on backend. Equivalent to no new batches.
      return .init(resolved: [])
    }
    .then { self.downloadChunks(with: $0, country: country) }
  }

  func clearLocalResources(for chunks: [TemporaryExposureKeyChunk]) -> Promise<Void> {
    return self.fileStorage
      .delete(chunks.flatMap { $0.localUrls })
  }

  func getMissingChunksIndexes(latestKnownChunkIndex: Int?, country: Country?) -> Promise<[Int]> {
    self.networkManager.getKeysIndex(country: country)
      .then { (keysIndex: KeysIndex) -> [Int] in

        let latestKnown = latestKnownChunkIndex ?? -1

        guard
          keysIndex.newest > latestKnown,
          keysIndex.newest >= keysIndex.oldest
        else {
          // no chunks to download
          return []
        }

        // note the +1. It is added to prevent to download the previous "latest"
        // chunk twice
        let firstKeyToDownload = max(latestKnown + 1, keysIndex.oldest)

        // The EN cannot process more than a certain amount of keys per day. If the server returns a
        // number of chunks that is greater than the local limit, just take the latest X.
        // This choice has been done because:
        // - This should happen just during the first EN check
        // - It is better to prioritize recent contacts
        //
        // Note that the subsequent runs within 24 hours will fail anyway, but the manager should handle
        // them and retry as soon as possible. Assuming we don't publish more than 15 chunks per day
        // (which we won't) the algorithm is stable

        let indexCount = (firstKeyToDownload ... keysIndex.newest).suffix(Self.keyDailyRateLimit).count
        if #available(iOS 13.6, *) {
          return (firstKeyToDownload ... keysIndex.newest).suffix(Self.keyDailyRateLimit)
        } else {
          if self.keyDailyRateLimitCounter - indexCount >= 0 {
            let indexDailyRate = self.keyDailyRateLimitCounter
            self.keyDailyRateLimitCounter = self.keyDailyRateLimitCounter - indexCount
            return (firstKeyToDownload ... keysIndex.newest).suffix(indexDailyRate)
          } else {
            let indexDailyRate = self.keyDailyRateLimitCounter
            self.keyDailyRateLimitCounter = 0
            return (firstKeyToDownload ... keysIndex.newest).suffix(indexDailyRate)
          }
        }
      }
  }

  private func downloadChunks(with indexes: [Int], country: Country?) -> Promise<[TemporaryExposureKeyChunk]> {
    self.networkManager.downloadChunks(with: indexes, country: country)
      .then { chunksData in
        assert(chunksData.count == indexes.count)

        let chunksWithIndexes = zip(chunksData, indexes)

        let fileWritePromises = chunksWithIndexes
          .map { chunkData, index in
            self.fileStorage.write(chunkData, with: Self.fileName(for: index, country: country))
              .then { localUrls in TemporaryExposureKeyChunk(localUrls: localUrls, index: index) }
          }

        return all(fileWritePromises)
      }
  }

  private static func fileName(for index: Int, country: Country?) -> String {
    guard let country = country else {
      return String(format: "tek_%06d", index)
    }
    return String(format: "%@_tek_%06d", country.countryId, index)
  }
}
