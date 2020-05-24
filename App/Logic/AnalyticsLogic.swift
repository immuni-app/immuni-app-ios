// AnalyticsLogic.swift
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

import Hydra
import ImmuniExposureNotification
import Katana
import Models
import Networking
import Tempura

extension Logic {
  enum Analytics {}
}

extension Logic.Analytics {
  /// Performs the analytics logic and sends the analytics to the server if needed.
  ///
  /// -seeAlso: Traffic-Analysis Mitigation document
  struct SendOperationalInfoIfNeeded: AppSideEffect {
    let outcome: ExposureDetectionOutcome

    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      switch self.outcome {
      case .error, .noDetectionNecessary:
        return
      case .partialDetection:
        try context.awaitDispatch(SendOperationalInfoWithoutExposureIfNeeded())

      case .fullDetection:
        try context.awaitDispatch(SendOperationalInfoWithExposureIfNeeded())
      }
    }
  }
}

// MARK: Operational Info with exposure

extension Logic.Analytics {
  /// Attempts to send an analytic event if the logic allows for it
  struct SendOperationalInfoWithExposureIfNeeded: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let currentDay = context.dependencies.now().utcCalendarDay
      let state = context.getState()
      let lastSent = state.analytics.eventWithExposureLastSent

      guard let province = state.user.province else {
        // no province, just skip the flow
        return
      }

      // we can send this event only if the month is different from the
      // `last sent` one
      guard currentDay.month != lastSent.month else {
        // return if the month is the same. Note that the
        // device's clock may be changed to alter this sequence,
        // but the backend will rate limit the event nonetheless
        return
      }

      // the month is "immediately used" regardless of the checks done below
      try context.awaitDispatch(UpdateEventWithExposureLastSent(day: currentDay))

      let randomNumber = context.dependencies.uniformDistributionGenerator.randomNumberBetweenZeroAndOne()
      let samplingRate = state.configuration.operationalInfoWithExposureSamplingRate

      guard randomNumber < samplingRate else {
        // skip the analytic event
        return
      }

      let deviceToken = try await(context.dependencies.tokenGenerator.generateToken())

      let body = AnalyticsRequest.Body(
        province: province,
        exposureNotificationStatus: state.environment.exposureNotificationAuthorizationStatus,
        pushNotificationStatus: state.environment.pushNotificationAuthorizationStatus,
        riskyExposureDetected: true,
        deviceToken: deviceToken.base64EncodedString()
      )

      // send the request and wait for the response to prevent the background
      // task from being killed. However, we don't need to manage the response
      _ = try? await(context.dependencies.networkManager.request(AnalyticsRequest(body: body)))
    }
  }
}

// MARK: Operational Info without exposure

extension Logic.Analytics {
  /// Attempts to send an analytic event if the logic allows for it
  struct SendOperationalInfoWithoutExposureIfNeeded: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let now = context.dependencies.now()
      let currentDay = now.utcCalendarDay
      let state = context.getState()
      let lastSent = state.analytics.eventWithExposureLastSent

      guard let province = state.user.province else {
        // no province, just skip the flow
        return
      }

      // we can send this event only if the month is different from the
      // `last sent` one
      guard currentDay.month != lastSent.month else {
        // return if the month is the same. Note that the
        // device's clock may be changed to alter this sequence,
        // but the backend will rate limit the event nonetheless
        return
      }

      guard state.analytics.eventWithoutExposureWindow.contains(now) else {
        // the opportunity window is not open
        return
      }

      // the month is "immediately used" regardless of the checks done below
      try context.awaitDispatch(UpdateEventWithoutExposureLastSent(day: currentDay))

      let randomNumber = context.dependencies.uniformDistributionGenerator.randomNumberBetweenZeroAndOne()
      let samplingRate = state.configuration.operationalInfoWithoutExposureSamplingRate

      guard randomNumber < samplingRate else {
        // skip the analytic event
        return
      }

      let deviceToken = try await(context.dependencies.tokenGenerator.generateToken())

      let body = AnalyticsRequest.Body(
        province: province,
        exposureNotificationStatus: state.environment.exposureNotificationAuthorizationStatus,
        pushNotificationStatus: state.environment.pushNotificationAuthorizationStatus,
        riskyExposureDetected: false,
        deviceToken: deviceToken.base64EncodedString()
      )

      // send the request and wait for the response to prevent the background
      // task from being killed. However, we don't need to manage the response
      _ = try? await(context.dependencies.networkManager.request(AnalyticsRequest(body: body)))
    }
  }

  /// Updates the event without exposure opportunity window if required
  struct UpdateOpportunityWindowIfNeeded: AppSideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) throws {
      let state = context.getState()
      let now = context.dependencies.now()
      let currentMonth = now.utcCalendarMonth

      guard state.analytics.eventWithoutExposureWindow.month < currentMonth else {
        // the opportunity window refers to this month (or a future month, which
        // occurs just in case of changing the device's clock). We don't need to
        // perform any operation
        return
      }

      // we need to update the opportunity window
      let numDays = currentMonth.numberOfDays
      let maxShift = Double(numDays - 1) * AnalyticsState.OpportunityWindow.secondsInDay
      let shift = context.dependencies.uniformDistributionGenerator.random(in: 0 ..< maxShift)
      let opportunityWindow = AnalyticsState.OpportunityWindow(month: currentMonth, shift: shift)
      try context.awaitDispatch(UpdateEventWithoutExposureOppurtunityWindow(window: opportunityWindow))
    }
  }
}

// MARK: State Updaters

extension Logic.Analytics {
  /// Updates the date in which an analytic event with exposure has been sent
  struct UpdateEventWithExposureLastSent: AppStateUpdater {
    let day: CalendarDay

    func updateState(_ state: inout AppState) {
      state.analytics.eventWithExposureLastSent = self.day
    }
  }

  /// Updates the date in which an analytic event without exposure has been sent
  struct UpdateEventWithoutExposureLastSent: AppStateUpdater {
    let day: CalendarDay

    func updateState(_ state: inout AppState) {
      state.analytics.eventWithoutExposureLastSent = self.day
    }
  }

  /// Updates the opportunity window for the event without exposure
  struct UpdateEventWithoutExposureOppurtunityWindow: AppStateUpdater {
    let window: AnalyticsState.OpportunityWindow

    func updateState(_ state: inout AppState) {
      state.analytics.eventWithoutExposureWindow = self.window
    }
  }
}
