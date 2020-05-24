// CovidStatus+Transition.swift
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
import Katana
import Models

extension CovidStatus {
  /// Number of days an alert should stay valid
  static let alertPeriodDays = 14

  /// TimeInterval an alert should stay valid
  static var alertPeriod: TimeInterval {
    return TimeInterval(CovidStatus.alertPeriodDays * 24 * 60 * 60)
  }

  /// This method implements the transitions between COVID-19 statuses.
  /// It takes as an input an event that occurred within the applicaiton, and returns the new state.
  /// Note that the returned value may be identical to `self`, as no transition has occurred.
  func transitioned(becauseOf event: CovidEvent) -> Self {
    switch self {
    case .neutral:
      return self.neutralTransitioned(becauseOf: event)

    case .risk(let lastContact):
      return self.riskTransitioned(becauseOf: event, currentLastContact: lastContact)

    case .positive(let date):
      return self.positiveTransitioned(becauseOf: event, lastUploadDate: date)
    }
  }
}

// MARK: Transition Handling

private extension CovidStatus {
  /// Implements the transitions logic, assuming `self` is neutral
  func neutralTransitioned(becauseOf event: CovidEvent) -> Self {
    switch event {
    case .contactDetected(let date):
      return .risk(lastContact: date)

    case .dataUpload(let date):
      return .positive(lastUpload: date)

    case .userEvent(.alertDismissal):
      return .neutral

    case .userEvent(.recoverConfirmed):
      return .neutral
    }
  }

  /// Implements the transitions logic, assuming `self` is risk
  func riskTransitioned(becauseOf event: CovidEvent, currentLastContact: CalendarDay) -> Self {
    switch event {
    case .contactDetected(let date):
      return .risk(lastContact: max(currentLastContact, date))

    case .dataUpload(let date):
      return .positive(lastUpload: date)

    case .userEvent(.alertDismissal):
      return .neutral

    case .userEvent(.recoverConfirmed):
      // note: this should never happens as recover is for positive only
      return .risk(lastContact: currentLastContact)
    }
  }

  /// Implements the transitions logic, assuming `positive` is casual
  func positiveTransitioned(becauseOf event: CovidEvent, lastUploadDate: CalendarDay) -> Self {
    switch event {
    case .contactDetected:
      return .positive(lastUpload: lastUploadDate)

    case .dataUpload(let date):
      return .positive(lastUpload: date)

    case .userEvent(.alertDismissal):
      return .positive(lastUpload: lastUploadDate)

    case .userEvent(.recoverConfirmed):
      return .neutral
    }
  }
}

// MARK: Events Handling

extension CovidStatus {
  var enteringDispatchables: [Dispatchable] {
    switch self {
    case .risk:
      return [Logic.CovidStatus.UserHasEnteredRiskState()]

    case .neutral:
      return [Logic.CovidStatus.UserHasEnteredNeutralState()]

    case .positive:
      return [Logic.CovidStatus.UserHasEnteredPositiveState()]
    }
  }

  var leavingDispatchable: [Dispatchable] {
    switch self {
    case .risk:
      return [Logic.CovidStatus.UserHasLeftRiskState()]

    case .neutral:
      return [Logic.CovidStatus.UserHasLeftNeutralState()]

    case .positive:
      return [Logic.CovidStatus.UserHasLeftPositiveState()]
    }
  }
}
