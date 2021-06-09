// HomeVM.swift
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
import Foundation
import Models
import Tempura

struct HomeVM: ViewModelWithState {
  enum HeaderKind: Equatable {
    case risk
    case positive
  }

  enum InfoKind: Equatable {
    case protection
    case app
  }
  enum DoTodayKind: Equatable {
    case updateCountry
    case dataUpload
    case greenCertificate
    }

  enum CellType: Equatable {
    case header(kind: HeaderKind)
    case serviceActiveCard(isServiceActive: Bool)
    case infoHeader
    case doTodayHeader
    case info(kind: InfoKind)
    case doToday(kind: DoTodayKind)
    case deactivateButton(isEnabled: Bool)
  }

  /// The array of cells in the collection.
  let cellTypes: [CellType]

  var hasHeaderCard: Bool {
    return self.cellTypes.contains(where: { if case .header = $0 { return true } else { return false } })
  }

  func shouldReloadCollection(oldModel: HomeVM?) -> Bool {
    guard let oldModel = oldModel else {
      return true
    }

    return self.cellTypes != oldModel.cellTypes
  }

  func cellType(for indexPath: IndexPath) -> CellType? {
    return self.cellTypes[safe: indexPath.item]
  }

  func cellModel(for indexPath: IndexPath) -> ViewModel? {
    guard let cellType = self.cellType(for: indexPath) else {
      return nil
    }
    switch cellType {
    case .header(let kind):
      return HomeHeaderCardCellVM(kind: kind)
    case .serviceActiveCard(let isServiceActive):
      return HomeServiceActiveCellVM(isServiceActive: isServiceActive, hasHeaderCard: self.hasHeaderCard)
    case .infoHeader:
      return HomeInfoHeaderCellVM()
    case .info(let kind):
      return HomeInfoCellVM(kind: kind)
    case .deactivateButton(let isEnabled):
      return HomeDeactivateServiceCellVM(isEnabled: isEnabled)
    case .doTodayHeader:
        return HomeDoTodayHeaderCellVM()
    case .doToday(kind: let kind):
        return HomeDoTodayCellVM(kind: kind)
    }
  }
}

extension HomeVM {
  init(state: AppState) {
    self.init(isServiceActive: state.isServiceActive, covidStatus: state.user.covidStatus)
  }

  init(isServiceActive: Bool, covidStatus: CovidStatus) {
    var cells: [CellType] = [
      .serviceActiveCard(isServiceActive: isServiceActive),
      .doTodayHeader,
      .doToday(kind: .greenCertificate),
      .doToday(kind: .dataUpload),
      .doToday(kind: .updateCountry),
      .infoHeader,
      .info(kind: .app)
    ]

    switch covidStatus {
    case .neutral:
      cells.append(.info(kind: .protection))
    case .risk:
      cells.insert(.header(kind: .risk), at: 0)
    case .positive:
      cells.insert(.header(kind: .positive), at: 0)
    }
    
    cells.append(.deactivateButton(isEnabled: isServiceActive))

    self.cellTypes = cells
  }
}

private extension AppState {
  var isServiceActive: Bool {
    if !self.environment.exposureNotificationAuthorizationStatus.canPerformDetection {
      return false
    }

    if !self.environment.pushNotificationAuthorizationStatus.allowsSendingNotifications {
      return false
    }

    return true
  }
}
