// Data+Utils.swift
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

public extension Data {
  /// Generate a Data instance with a random amount of bytes
  ///
  ///  - parameter length: the amount of bytes to generate
  static func randomData(with length: Int) -> Data {
    var bytes = [Int8](repeating: 0, count: length)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    assert(status == errSecSuccess)

    return Data(bytes: &bytes, count: length)
  }
}

/// Slightly broader extension to allow it to apply also for `SHA256.Digest`
public extension Sequence where Element == UInt8 {
  /// The String representation, as hexadecimal digits, of this byte sequence.
  var hexString: String {
    return self
      .map { byte in String(format: "%02hhx", byte) }
      .joined()
  }
}
