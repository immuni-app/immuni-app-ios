// UIControl+TargetActionable.swift
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
import UIKit

class Trampoline: NSObject {
  @objc func action(sender: UIControl) {}
}

class ActionTrampoline<T>: Trampoline {
  var act: (T) -> Void

  init(action: @escaping (T) -> Void) {
    self.act = action
  }

  override func action(sender: UIControl) {
    guard let typedSender = sender as? T else {
      LibLogger.fatalError("\(sender) cannot be typed to \(T.self)")
    }

    self.act(typedSender)
  }
}

extension UIControl.Event {
  var number: NSNumber {
    return Int(self.rawValue) as NSNumber
  }
}

public protocol TargetActionable {
  associatedtype ActionArgument
  mutating func on(_ event: UIControl.Event, _ action: @escaping (ActionArgument) -> Void)
}

extension TargetActionable {
  private var actionTrampolines: NSMutableDictionary? {
    get {
      if let actionTrampolines = objc_getAssociatedObject(self, &actionTrampolinesKey) as? NSMutableDictionary {
        return actionTrampolines
      }
      return nil
    }

    set {
      if let newValue = newValue {
        objc_setAssociatedObject(
          self,
          &actionTrampolinesKey,
          newValue as NSMutableDictionary?,
          .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
      }
    }
  }
}

private var actionTrampolinesKey = "targetactionable_action_trampolines_key"

public extension TargetActionable where Self: UIControl {
  mutating func on(_ event: UIControl.Event, _ action: @escaping (Self) -> Void) {
    if let oldTrampoline = self.actionTrampolines?[event.number] as? Trampoline {
      self.removeTarget(oldTrampoline, action: #selector(oldTrampoline.action), for: event)
    }
    if self.actionTrampolines == nil {
      self.actionTrampolines = NSMutableDictionary()
    }
    let trampoline = ActionTrampoline(action: action)
    self.addTarget(trampoline, action: #selector(trampoline.action), for: event)
    self.actionTrampolines?[event.number] = trampoline
  }
}

private let tapHandlerKey = UnsafeMutablePointer<Int8>.allocate(capacity: 1)

public protocol TapActionable {
  associatedtype ActionArgument
  func onTap(_ action: @escaping (ActionArgument) -> Void)
}

public extension TapActionable where Self: UIBarButtonItem {
  func onTap(_ action: @escaping (Self) -> Void) {
    let trampoline = ActionTrampoline(action: action)

    self.target = trampoline
    self.action = #selector(trampoline.action)

    // just needed to retain the trampoline to keep it alive
    objc_setAssociatedObject(self, tapHandlerKey, trampoline, .OBJC_ASSOCIATION_RETAIN)
  }
}

extension UIControl: TargetActionable {}
extension UIBarButtonItem: TapActionable {}
