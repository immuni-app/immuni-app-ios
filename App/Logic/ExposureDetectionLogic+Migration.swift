//
//  ExposureDetectionLogic+Migration.swift
//  Immuni
//
//  Created by LorDisturbia on 30/10/2020.
//

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
