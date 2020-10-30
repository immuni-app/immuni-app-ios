// Serialization.swift
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

/// A protocol that must be adopted by values to want to have a custom visualization within
/// the state explore feature
public protocol Monitorable {
  /// The value that is displayed within the Debug Menu.
  var monitorValue: Any { get }
}

public extension Monitorable {
  var monitorValue: Any { return self }
}

extension Int: Monitorable {}
extension CGFloat: Monitorable {}
extension Double: Monitorable {}

extension String: Monitorable {
  public var monitorValue: Any {
    guard !self.isEmpty else { return " " }
    return self
  }
}

extension Array: Monitorable {
  public var monitorValue: Any {
    guard !self.isEmpty else { return "[]" }
    return self.map {
      MonitorSerialization.convertValueToDictionary($0)
    }
  }
}

extension Dictionary: Monitorable {
  public var monitorValue: Any {
    guard !self.isEmpty else { return "[:]" }
    var monitorDict: [String: Any] = [:]
    for (key, value) in self {
      monitorDict["\(key)"] = MonitorSerialization.convertValueToDictionary(value)
    }
    return monitorDict
  }
}

extension Optional: Monitorable {
  public var monitorValue: Any {
    switch self {
    case .none:
      return "nil"
    case .some(let wrapped):
      return MonitorSerialization.convertValueToDictionary(wrapped)
    }
  }
}

/// Serialize items using reflection
struct MonitorSerialization {
  private init() {}

  static func convertValueToDictionary(_ value: Any) -> Any {
    if let monitorableValue = value as? Monitorable {
      // directly representable
      return monitorableValue.monitorValue
    }

    let mirror = Mirror(reflecting: value)

    guard let displayStyle = mirror.displayStyle else {
      // best effort.. return the stringification
      return String(reflecting: value)
    }

    switch displayStyle {
    case .struct:
      var result: [String: Any] = [:]
      for (key, child) in mirror.children {
        guard let key = key else { continue }
        result[key] = MonitorSerialization.convertValueToDictionary(child)
      }
      return result
    default:
      // best effort.. return the stringification
      return String(reflecting: value)
    }
  }
}
