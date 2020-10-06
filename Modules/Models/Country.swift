// Country.swift
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
public enum Country: String, Codable, CaseIterable {
    
    case italia = "IT"
    case francia = "FR"
    case spagna = "ES"
    case germania = "DE"
    case russia = "RU"
    case austria = "AT"
    case svizzera = "CH"
    case portogallo = "PT"
    case olanda = "NL"
    case belgio = "BE"
    case albania = "AL"
    case grecia = "GR"
    case croazia = "HR"
    case ungheria = "HU"
    
    public var humanReadableName: String {
        switch self {
        case .italia:
            return "Italia"
        case .francia:
            return "Francia"
        case .spagna:
            return "Spagna"
        case .germania:
            return "Germania"
        case .russia:
            return "Russia"
        case .austria:
            return "Austria"
        case .svizzera:
            return "Svizzera"
        case .portogallo:
            return "Portogallo"
        case .olanda:
            return "Olanda"
        case .belgio:
            return "Belgio"
        case .albania:
            return "Albania"
        case .grecia:
            return "Grecia"
        case .croazia:
            return "Croazia"
        case .ungheria:
            return "Ungheria"
        }
    }
}



extension Country: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public struct CountrySelection: Equatable, Codable {
    
    public var country: Country
    public var selectionDate: Date
    
    public init(country: Country, selectionDate: Date){
        self.country = country
        self.selectionDate = selectionDate
    }
    
    public init(country: Country){
        self.country = country
        self.selectionDate = Date()
    }
    
    public static func ==(lhs: CountrySelection, rhs: CountrySelection) -> Bool {
           return lhs.country == rhs.country
       }
}
