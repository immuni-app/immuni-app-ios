// ImmuniFileStorage.swift
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
import Hydra
import Persistence
import ZIPFoundation

/// The default implementation of `FileStorage`. It reads the input `data` as a zip archive, expecting it to include two files,
/// as explained in [Apple's documentation]
/// (https://developer.apple.com/documentation/exposurenotification/setting_up_an_exposure_notification_server).
/// The URLs of these files are returned.
/// Note: it takes care of cleaning up all temporary files, but `delete` must still be called with the urls returned by `write`.
public class ImmuniFileStorage: FileStorage {
  private let fileManager: FileManager

  public init(fileManager: FileManager) {
    self.fileManager = fileManager
  }

  public func write(_ data: Data, with fileNameWithoutExtension: String) -> Promise<[URL]> {
    return Promise { resolve, reject, _ in
      let zipFileURL = self.keysFolder().appendingPathComponent("\(fileNameWithoutExtension).zip")
      try data.write(to: zipFileURL, options: .atomic)
      let unzipDirectoryURL = self.keysFolder().appendingPathComponent(fileNameWithoutExtension)
      try self.fileManager.createDirectory(at: unzipDirectoryURL, withIntermediateDirectories: true, attributes: nil)

      defer {
        try? self.fileManager.removeItem(at: unzipDirectoryURL)
        try? self.fileManager.removeItem(at: zipFileURL)
      }

      do {
        try self.fileManager.unzipItem(at: zipFileURL, to: unzipDirectoryURL)
      } catch {
        reject(Error.unzipError)
        return
      }

      let unzippedFiles = try self.fileManager.contentsOfDirectory(at: unzipDirectoryURL, includingPropertiesForKeys: nil)

      guard unzippedFiles.count == 2 else {
        reject(Error.brokenChunk)
        return
      }

      let finalFileURLs = try unzippedFiles
        .map { file -> URL in
          let fileExtension = file.pathExtension
          let destinationFileUrl = self.keysFolder().appendingPathComponent("\(fileNameWithoutExtension).\(fileExtension)")
          try? self.fileManager.removeItem(at: destinationFileUrl)
          try self.fileManager.moveItem(at: file, to: destinationFileUrl)
          return destinationFileUrl
        }

      resolve(finalFileURLs)
    }
  }

  public func delete(_ urls: [URL]) -> Promise<Void> {
    return Promise { resolve, _, _ in
      for url in urls {
        try? self.fileManager.removeItem(at: url)
      }
      resolve(())
    }
  }
}

// MARK: - Helper methods

extension ImmuniFileStorage {
  private func keysFolder() -> URL {
    return self.fileManager.temporaryDirectory
  }
}

extension ImmuniFileStorage {
  enum Error: Swift.Error {
    case unzipError
    case brokenChunk
  }
}
