// Logger+FileLogHandler.swift
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
import Logging

public struct FileLogHandler: LogHandler {
  public static var logFileUrl: URL {
    guard let userDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      fatalError("Can't find user document directory")
    }

    return userDir.appendingPathComponent("log.txt")
  }

  private static var fileHandle: FileHandle {
    do {
      let fileHandle = try FileHandle(forWritingTo: self.logFileUrl)
      try fileHandle.seekToEnd()
      return fileHandle
    } catch {
      fatalError("Can't obtain file handle")
    }
  }

  private static var formattedDate: () -> String = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd@HH:mm:ss.SSSS"

    return {
      formatter.string(from: Date())
    }
  }()

  init() {
    Self.prepareLogFile()
  }

  public func log(
    level: Logger.Level,
    message: Logger.Message,
    metadata: Logger.Metadata?,
    file: String,
    function: String,
    line: UInt
  ) {
    let string = "\(Self.formattedDate()) \(level): \(message)\n"

    guard let data = string.data(using: .utf8) else {
      return
    }

    Self.fileHandle.write(data)
  }

  public static func clear() {
    do {
      try "".write(to: Self.logFileUrl, atomically: true, encoding: .utf8)
    } catch {
      fatalError("Can't reset log")
    }
  }

  private static func prepareLogFile() {
    guard !FileManager.default.fileExists(atPath: self.logFileUrl.path) else {
      // File exists already
      return
    }

    let isSuccessful = FileManager.default.createFile(atPath: self.logFileUrl.path, contents: nil, attributes: nil)

    guard isSuccessful else {
      fatalError("Can't create file")
    }
  }
}

// MARK: - LogHandler conformance

extension FileLogHandler {
  public var metadata: Logger.Metadata {
    get { .init() }
    set {}
  }

  public var logLevel: Logger.Level {
    get { .debug }
    set {}
  }

  public subscript(metadataKey _: String) -> Logger.Metadata.Value? {
    get { return nil }
    set(newValue) {}
  }
}
