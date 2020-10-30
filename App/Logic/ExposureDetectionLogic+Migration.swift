// ExposureDetectionLogic+Migration.swift
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
import Models

extension Logic.ExposureDetection {
  /// Computes the correct `CovidStatus` of the user
  struct ClearRiskStatusIfWronglyAttributed: AppStateUpdater {
    func updateState(_ state: inout AppState) {
      guard !state.toggles.isWronglyAttributedRiskStatusBeenChecked else {
        // Migration already performed
        return
      }

      state.toggles.isWronglyAttributedRiskStatusBeenChecked = true
      state.user.covidStatus = Self.correctUserStatus(
        currentStatus: state.user.covidStatus,
        recentPositiveExposureResults: state.exposureDetection.recentPositiveExposureResults,
        closeContactRiskThreshold: state.configuration.exposureInfoMinimumRiskScore
      )
    }

    /// Given the array of recent positive exposure results, computes the correct `CovidStatus` of the user, clearing any wrongly
    /// attributed risk status resulting from non-close contact or contacts happened more than 14 days ago.
    static func correctUserStatus(
      currentStatus: CovidStatus,
      recentPositiveExposureResults: [ExposureDetectionState.PositiveExposureResult],
      closeContactRiskThreshold: Int
    ) -> CovidStatus {
      guard case .risk = currentStatus else {
        // User is either neutral or positive. Nothing to do: their status is correct.
        return currentStatus
      }

      // Extract the date of the most recent close contact directly from the state
      let maybeMostRecentCloseContact = recentPositiveExposureResults
        .flatMap(\.data.exposureInfo)
        .mostRecentRiskyContactDay(closeContactRiskThreshold: closeContactRiskThreshold)

      guard let mostRecentCloseContact = maybeMostRecentCloseContact else {
        // There are no close contacts in the last 14 days.
        // There is no way to know if the previously detected contact was a close contact or a false positive, but since enough
        // time has passed, it is safe to assume that the state of the user can be reverted to neutral.
        return .neutral
      }

      // There is a real close contact in the last 14 days. Use it to update the state of the user
      return .risk(lastContact: mostRecentCloseContact)
    }
  }
}
