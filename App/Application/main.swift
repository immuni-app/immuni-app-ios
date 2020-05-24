// main.swift
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

import UIKit

/// This variable contains the App Delegate class to load. Since `UnitTestsAppDelegate` is part of the unit test
/// target, the system won't be able to load it and the standard `AppDelegate` class is loaded insted.
/// In the test target, instead, the empty App Delegate (`UnitTestsAppDelegate`) is loaded. This prevents
/// The Katana dependencies from starting.
let appDelegateClass: AnyClass = NSClassFromString("UnitTestsAppDelegate") ?? AppDelegate.self

UIApplicationMain(
  CommandLine.argc,
  CommandLine.unsafeArgv,
  nil,
  NSStringFromClass(appDelegateClass)
)
