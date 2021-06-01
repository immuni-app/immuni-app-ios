// DigitalGreenCertificate.swift
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

import ExposureNotification
import Foundation

public struct DigitalGreenCertificate: Codable {
  enum CodingKeys: String, CodingKey {
    case code
    case message
    case result
   
  }

  public let code: String
  public let message: String
  public let result: ResultDigitalGreenCertificate

  // swiftlint:enable force_unwrapping
}
public struct ResultDigitalGreenCertificate: Codable {
  enum CodingKeys: String, CodingKey {
    case qr
    case message
   
  }

  public let qr: String
  public let message: String

  // swiftlint:enable force_unwrapping
}

