// LifecycleLogicTests.swift
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
@testable import Immuni
import ImmuniExposureNotification
import Katana
import Models
import Tempura
import XCTest

final class LifecycleLogicTests: XCTestCase {}

// MARK: Configuration / FAQs fetching

extension LifecycleLogicTests {
  func testOnStartDoesntFetchConfiguration() throws {
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.OnStart().sideEffect(context)

    let containsConfigSideEffect = dispatchInterceptor.dispatchedItems
      .contains { $0 is Logic.Configuration.DownloadAndUpdateConfiguration }
    XCTAssertFalse(containsConfigSideEffect)
  }

  func testWillEnterForegroundDoesntFetchConfiguration() throws {
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.WillEnterForeground().sideEffect(context)

    let containsConfigSideEffect = dispatchInterceptor.dispatchedItems
      .contains { $0 is Logic.Configuration.DownloadAndUpdateConfiguration }
    XCTAssertFalse(containsConfigSideEffect)
  }

  func testDidBecomeActiveDoesntFetchConfiguration() throws {
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.DidBecomeActive().sideEffect(context)

    let containsConfigSideEffect = dispatchInterceptor.dispatchedItems
      .contains { $0 is Logic.Configuration.DownloadAndUpdateConfiguration }
    XCTAssertFalse(containsConfigSideEffect)
  }

  func testHandleExposureDetectionBackgroundTaskFetchConfiguration() throws {
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.HandleExposureDetectionBackgroundTask(task: MockBackgroundTask()).sideEffect(context)

    let containsConfigSideEffect = dispatchInterceptor.dispatchedItems
      .contains { $0 is Logic.Configuration.DownloadAndUpdateConfiguration }
    XCTAssert(containsConfigSideEffect)
  }
}

// MARK: - First start setup

extension LifecycleLogicTests {
  func testOnStartCallsPerformFirstLaunchSetupIfNeeded() throws {
    let state = AppState()

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: { state }, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.OnStart().sideEffect(context)

    try XCTAssertContainsType(dispatchInterceptor.dispatchedItems, Logic.Lifecycle.PerformFirstLaunchSetupIfNeeded.self)
  }

  func testPerformsFirstTimeSetupAtFirstLaunch() throws {
    let state = AppState()

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: { state }, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.PerformFirstLaunchSetupIfNeeded().sideEffect(context)

    XCTAssert(!dispatchInterceptor.dispatchedItems.isEmpty)
  }

  func testDoesNotPerformsFirstTimeSetupAgain() throws {
    var state = AppState()
    state.toggles.isFirstLaunchSetupPerformed = true

    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(getAppState: { state }, dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.PerformFirstLaunchSetupIfNeeded().sideEffect(context)

    XCTAssert(dispatchInterceptor.dispatchedItems.isEmpty)
  }

  // MARK: - Migration

  func testOnStart_invokesPerformMigrationsIfNecessary() throws {
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.OnStart().sideEffect(context)

    try XCTAssertContainsType(dispatchInterceptor.dispatchedItems, Logic.Lifecycle.PerformMigrationsIfNecessary.self)
  }

  func testWillEnterForeground_invokesPerformMigrationsIfNecessary() throws {
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.WillEnterForeground().sideEffect(context)

    try XCTAssertContainsType(dispatchInterceptor.dispatchedItems, Logic.Lifecycle.PerformMigrationsIfNecessary.self)
  }

  func testHandleBackgroundTask_invokesPerformMigrationsIfNecessary() throws {
    let dispatchInterceptor = DispatchInterceptor()
    let dependencies = AppDependencies.mocked(dispatch: dispatchInterceptor.dispatchFunction)
    let context = AppSideEffectContext(dependencies: dependencies)

    try Logic.Lifecycle.HandleExposureDetectionBackgroundTask(task: MockBackgroundTask()).sideEffect(context)

    try XCTAssertContainsType(dispatchInterceptor.dispatchedItems, Logic.Lifecycle.PerformMigrationsIfNecessary.self)
  }
}
