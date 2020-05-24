// PersistStoreTestsUtilities.swift
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

// swiftlint:disable superfluous_disable_command force_try implicitly_unwrapped_optional force_unwrapping force_cast

import CryptoKit
import Foundation
import StorePersistence

extension Dictionary {
  func persistStoreEncrypted(with key: SymmetricKey) -> String {
    let data = try! JSONSerialization.data(withJSONObject: self)
    return data.persistStoreEncrypted(with: key)
  }
}

extension Data {
  func persistStoreEncrypted(with key: SymmetricKey) -> String {
    let box = try! AES.GCM.seal(self, using: key)
    return box.combined!.base64EncodedString()
  }
}

extension String {
  func persistStoreDecrypted(with key: SymmetricKey) -> [String: Any] {
    let data = Data(base64Encoded: self)!
    let box = try! AES.GCM.SealedBox(combined: data)
    let decryptedData = try! AES.GCM.open(box, using: key)
    return try! JSONSerialization.jsonObject(with: decryptedData) as! [String: Any]
  }
}

extension Dictionary {
  func toJSONData() -> Data {
    return try! JSONSerialization.data(withJSONObject: self, options: [])
  }
}

extension Encodable {
  func toJSON() -> RawState {
    let data = self.encoded()
    return try! JSONSerialization.jsonObject(with: data, options: []) as! RawState
  }

  func encoded() -> Data {
    return try! JSONEncoder().encode(self)
  }

  func encodedToString() -> String {
    let encoded = self.encoded()
    return String(data: encoded, encoding: .utf8)!
  }
}

extension Data {
  func toRawState() -> RawState {
    return (try! JSONSerialization.jsonObject(with: self, options: [])) as! [String: Any]
  }
}
