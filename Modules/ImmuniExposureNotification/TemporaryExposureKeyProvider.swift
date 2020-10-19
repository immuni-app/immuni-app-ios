// TemporaryExposureKeyProvider.swift
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
import Models

/// Provider of files containing `TemporaryExposureKey`s for Exposure Detection
public protocol TemporaryExposureKeyProvider {
  /// Given an optional `latestKnownChunkIndex`, returns all the missing chunk of `TemporaryExposureKeys`, if any
  func getLatestKeyChunks(latestKnownChunkIndex: Int?, country: Country?, isFirstFlow: Bool?)
    -> Promise<[TemporaryExposureKeyChunk]>
  /// Asks the provider to clean up the local resources associated with `TemporaryExposureKeyChunk`s
  func clearLocalResources(for chunks: [TemporaryExposureKeyChunk]) -> Promise<Void>
}

/// Chunk of `TemporaryExposureKeys` described by the `URL`s of some local resources along with an identifying `index`.
public struct TemporaryExposureKeyChunk {
  /// The `URL`s of the local resources related to this chunk of keys
  public let localUrls: [URL]

  /// An identifying index for the chunk.
  public let index: Int

  public init(localUrls: [URL], index: Int) {
    self.localUrls = localUrls
    self.index = index
  }
}
