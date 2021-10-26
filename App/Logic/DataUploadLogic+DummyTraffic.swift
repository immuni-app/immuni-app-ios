// DataUploadLogic+DummyTraffic.swift
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
import Hydra
import Katana
import Models
import Networking

extension Logic.DataUpload {
  /// Updates the dummy ingestion traffic opportunity window taking the parameters from the Configuration and the RNGs.
  struct UpdateDummyTrafficOpportunityWindowIfExpired: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      let now = context.dependencies.now()

      guard now > state.ingestion.dummyTrafficOpportunityWindow.windowEnd else {
        // Window not started or finished yet.
        return
      }

      try context.awaitDispatch(UpdateDummyTrafficOpportunityWindow())
    }
  }

  /// Updates the dummy ingestion traffic opportunity window taking the parameters from the Configuration and the RNGs.
  struct UpdateDummyTrafficOpportunityWindow: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      let dummyTrafficStochasticDelay = context.dependencies.exponentialDistributionGenerator
        .exponentialRandom(with: state.configuration.dummyIngestionMeanStochasticDelay)

      try context.awaitDispatch(
        SetDummyTrafficOpportunityWindow(
          dummyTrafficStochasticDelay: dummyTrafficStochasticDelay,
          dummyTrafficOpportunityWindowDuration: state.configuration.dummyIngestionWindowDuration,
          now: context.dependencies.now()
        )
      )
    }
  }

  /// Schedules a sequence of dummy ingestion requests for some random point in the future.
  /// -seeAlso: https://github.com/immuni-app/immuni-documentation/blob/master/Traffic%20Analysis%20Mitigation.md
  struct ScheduleDummyIngestionSequenceIfNecessary: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()

      guard !state.ingestion.dummyTrafficSequenceScheduledInSession else {
        // There is already another sequence schedule for this session.
        return
      }

      // Reset the flag in case this is a new session
      try context.awaitDispatch(SetDummyTrafficSequenceCancelled(value: false))

      guard state.ingestion.dummyTrafficOpportunityWindow.contains(context.dependencies.now()) else {
        // Not within the opportunity window. Nothing to do.
        return
      }

      // Prevent other ingestion sequences from being scheduled in this session
      try context.awaitDispatch(SetDummyIngestionSequenceScheduledForThisSession(value: true))

      let startDelay = context.dependencies.exponentialDistributionGenerator
        .exponentialRandom(with: state.configuration.dummyIngestionAverageStartUpDelay)

      // Dispatch a delayed action and return
      context.anyDispatch(StartIngestionSequenceIfNotCancelled().deferred(of: startDelay))
    }
  }

  /// Attempts a simulated sequence of ingestion requests, unless it was cancelled for outside in the meanwhile.
  /// -seeAlso: https://github.com/immuni-app/immuni-documentation/blob/master/Traffic%20Analysis%20Mitigation.md
  struct StartIngestionSequenceIfNotCancelled: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      // Update the opportunity window
      try context.awaitDispatch(UpdateDummyTrafficOpportunityWindow())

      var executions = 0
      while true {
        // Fetch the state at every run because it might have been updated in the meanwhile
        let state = context.getState()

        guard !state.ingestion.isDummyTrafficSequenceCancelled else {
          // The user signaled the intent of starting a genuine upload.
          break
        }

        let requestSize = state.configuration.ingestionRequestTargetSize
        try? Hydra.await(context.dependencies.networkManager.sendDummyIngestionRequest(requestSize: requestSize))

        let diceRoll = context.dependencies.uniformDistributionGenerator.randomNumberBetweenZeroAndOne()
        let threshold = state.configuration.dummyIngestionRequestProbabilities[safe: executions]
          ?? state.configuration.dummyIngestionRequestProbabilities.last
          ?? AppLogger.fatalError("No probabilities defined")

        guard diceRoll < threshold else {
          // The generated probability was above the threshold.
          break
        }

        let interRequestDelay = context.dependencies.exponentialDistributionGenerator
          .exponentialRandom(with: state.configuration.dummyIngestionAverageRequestWaitingTime)

        // Await for a random time
        try Hydra.await(Promise<Void>.deferring(of: interRequestDelay))
        executions += 1
      }

      // Allow the scheduling of another session.
      try context.awaitDispatch(SetDummyIngestionSequenceScheduledForThisSession(value: false))
    }
  }
}

// MARK: - StateUpdaters

extension Logic.DataUpload {
  /// Sets the opportunity window for the dummy ingestion traffic
  struct SetDummyTrafficOpportunityWindow: AppStateUpdater {
    let dummyTrafficStochasticDelay: Double
    let dummyTrafficOpportunityWindowDuration: Double
    let now: Date

    func updateState(_ state: inout AppState) {
      let windowStart = self.now.addingTimeInterval(self.dummyTrafficStochasticDelay)
      let windowDuration = self.dummyTrafficOpportunityWindowDuration
      state.ingestion.dummyTrafficOpportunityWindow = .init(windowStart: windowStart, windowDuration: windowDuration)
    }
  }

  /// Marks a dummy traffic sequence as cancelled
  struct SetDummyTrafficSequenceCancelled: AppStateUpdater {
    let value: Bool

    func updateState(_ state: inout AppState) {
      state.ingestion.isDummyTrafficSequenceCancelled = self.value
    }
  }

  /// Signals that a dummy traffic sequence is already scheduled for this session
  struct SetDummyIngestionSequenceScheduledForThisSession: AppStateUpdater {
    let value: Bool

    func updateState(_ state: inout AppState) {
      state.ingestion.dummyTrafficSequenceScheduledInSession = self.value
    }
  }

  /// Handles the end of a foreground session
  struct MarkForegroundSessionFinished: AppStateUpdater {
    func updateState(_ state: inout AppState) {
      state.ingestion.dummyTrafficSequenceScheduledInSession = false
      state.ingestion.isDummyTrafficSequenceCancelled = true
    }
  }
}
