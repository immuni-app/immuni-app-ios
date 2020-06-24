// Region.swift
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

/// Regions in Italy
/// - seeAlso: https://it.wikipedia.org/wiki/Regione_(Italia)
public enum Region: String, CaseIterable {
  case abruzzo = "Abruzzo"
  case basilicata = "Basilicata"
  case calabria = "Calabria"
  case campania = "Campania"
  case emiliaRomagna = "Emilia-Romagna"
  case friuliVeneziaGiulia = "Friuli-Venezia Giulia"
  case lazio = "Lazio"
  case liguria = "Liguria"
  case lombardia = "Lombardia"
  case marche = "Marche"
  case molise = "Molise"
  case piemonte = "Piemonte"
  case puglia = "Puglia"
  case sardegna = "Sardegna"
  case sicilia = "Sicilia"
  case toscana = "Toscana"
  case trentinoAltoAdige = "Trentino-Alto Adige"
  case umbria = "Umbria"
  case valleAosta = "Valle d'Aosta"
  case veneto = "Veneto"
  case abroad = "Abroad"

  public func humanReadableName(with abroadName: String) -> String {
    switch self {
    case .abruzzo:
      return "Abruzzo"
    case .basilicata:
      return "Basilicata"
    case .calabria:
      return "Calabria"
    case .campania:
      return "Campania"
    case .emiliaRomagna:
      return "Emilia-Romagna"
    case .friuliVeneziaGiulia:
      return "Friuli-Venezia Giulia"
    case .lazio:
      return "Lazio"
    case .liguria:
      return "Liguria"
    case .lombardia:
      return "Lombardia"
    case .marche:
      return "Marche"
    case .molise:
      return "Molise"
    case .piemonte:
      return "Piemonte"
    case .puglia:
      return "Puglia"
    case .sardegna:
      return "Sardegna"
    case .sicilia:
      return "Sicilia"
    case .toscana:
      return "Toscana"
    case .trentinoAltoAdige:
      return "Trentino-Alto Adige / Südtirol"
    case .umbria:
      return "Umbria"
    case .valleAosta:
      return "Valle d'Aosta"
    case .veneto:
      return "Veneto"
    case .abroad:
      return abroadName
    }
  }

  public var provinces: [Province] {
    switch self {
    case .abruzzo:
      return [
        Province.chieti,
        Province.lAquila,
        Province.pescara,
        Province.teramo
      ]
    case .basilicata:
      return [
        Province.matera,
        Province.potenza
      ]
    case .calabria:
      return [
        Province.catanzaro,
        Province.cosenza,
        Province.crotone,
        Province.reggioCalabria,
        Province.viboValentia
      ]
    case .campania:
      return [
        Province.avellino,
        Province.benevento,
        Province.caserta,
        Province.napoli,
        Province.salerno
      ]
    case .emiliaRomagna:
      return [
        Province.bologna,
        Province.ferrara,
        Province.forliCesena,
        Province.modena,
        Province.parma,
        Province.piacenza,
        Province.ravenna,
        Province.reggioEmilia,
        Province.rimini
      ]
    case .friuliVeneziaGiulia:
      return [
        Province.udine,
        Province.gorizia,
        Province.pordenone,
        Province.trieste
      ]
    case .lazio:
      return [
        Province.frosinone,
        Province.latina,
        Province.rieti,
        Province.roma,
        Province.viterbo
      ]
    case .liguria:
      return [
        Province.genova,
        Province.imperia,
        Province.laSpezia,
        Province.savona
      ]
    case .lombardia:
      return [
        Province.bergamo,
        Province.brescia,
        Province.como,
        Province.cremona,
        Province.lecco,
        Province.lodi,
        Province.mantova,
        Province.milano,
        Province.monzaEBrianza,
        Province.pavia,
        Province.sondrio,
        Province.varese
      ]
    case .marche:
      return [
        Province.ancona,
        Province.ascoliPiceno,
        Province.fermo,
        Province.macerata,
        Province.pesaroEUrbino
      ]
    case .piemonte:
      return [
        Province.alessandria,
        Province.asti,
        Province.biella,
        Province.cuneo,
        Province.novara,
        Province.torino,
        Province.vercelli,
        Province.verbaniaCusioOssola
      ]
    case .molise:
      return [
        Province.campobasso,
        Province.isernia
      ]
    case .puglia:
      return [
        Province.barlettaAndriaTrani,
        Province.bari,
        Province.brindisi,
        Province.lecce,
        Province.foggia,
        Province.taranto
      ]
    case .sardegna:
      return [
        Province.cagliari,
        Province.nuoro,
        Province.oristano,
        Province.sassari,
        Province.sudSardegna
      ]
    case .sicilia:
      return [
        Province.agrigento,
        Province.caltanissetta,
        Province.catania,
        Province.enna,
        Province.messina,
        Province.palermo,
        Province.ragusa,
        Province.siracusa,
        Province.trapani
      ]
    case .toscana:
      return [
        Province.arezzo,
        Province.firenze,
        Province.grosseto,
        Province.livorno,
        Province.lucca,
        Province.massaECarrara,
        Province.pisa,
        Province.pistoia,
        Province.prato,
        Province.siena
      ]
    case .umbria:
      return [
        Province.perugia,
        Province.terni
      ]
    case .trentinoAltoAdige:
      return [
        Province.bolzano,
        Province.trento
      ]
    case .valleAosta:
      return [
        Province.aosta
      ]
    case .veneto:
      return [
        Province.belluno,
        Province.padova,
        Province.rovigo,
        Province.treviso,
        Province.venezia,
        Province.verona,
        Province.vicenza
      ]

    case .abroad:
      return [Province.abroad]
    }
  }

  /// Whether the region is the special "abroad" region
  public var isAbroadRegion: Bool {
    return self == .abroad
  }
}

public enum Province: String, Codable, CaseIterable {
  case agrigento = "AG"
  case alessandria = "AL"
  case ancona = "AN"
  case aosta = "AO"
  case arezzo = "AR"
  case ascoliPiceno = "AP"
  case asti = "AT"
  case avellino = "AV"
  case barlettaAndriaTrani = "BT"
  case bari = "BA"
  case belluno = "BL"
  case benevento = "BN"
  case bergamo = "BG"
  case biella = "BI"
  case bologna = "BO"
  case bolzano = "BZ"
  case brescia = "BS"
  case brindisi = "BR"
  case cagliari = "CA"
  case caltanissetta = "CL"
  case campobasso = "CB"
  case caserta = "CE"
  case catania = "CT"
  case catanzaro = "CZ"
  case chieti = "CH"
  case como = "CO"
  case cosenza = "CS"
  case cremona = "CR"
  case crotone = "KR"
  case cuneo = "CN"
  case enna = "EN"
  case fermo = "FM"
  case ferrara = "FE"
  case firenze = "FI"
  case foggia = "FG"
  case forliCesena = "FC"
  case frosinone = "FR"
  case genova = "GE"
  case gorizia = "GO"
  case grosseto = "GR"
  case imperia = "IM"
  case isernia = "IS"
  case lAquila = "AQ"
  case laSpezia = "SP"
  case latina = "LT"
  case lecce = "LE"
  case lecco = "LC"
  case livorno = "LI"
  case lodi = "LO"
  case lucca = "LU"
  case macerata = "MC"
  case mantova = "MN"
  case massaECarrara = "MS"
  case matera = "MT"
  case messina = "ME"
  case milano = "MI"
  case modena = "MO"
  case monzaEBrianza = "MB"
  case napoli = "NA"
  case novara = "NO"
  case nuoro = "NU"
  case oristano = "OR"
  case padova = "PD"
  case palermo = "PA"
  case parma = "PR"
  case pavia = "PV"
  case perugia = "PG"
  case pesaroEUrbino = "PU"
  case pescara = "PE"
  case piacenza = "PC"
  case pisa = "PI"
  case pistoia = "PT"
  case pordenone = "PN"
  case potenza = "PZ"
  case prato = "PO"
  case ragusa = "RG"
  case ravenna = "RA"
  case reggioCalabria = "RC"
  case reggioEmilia = "RE"
  case rieti = "RI"
  case rimini = "RN"
  case roma = "RM"
  case rovigo = "RO"
  case salerno = "SA"
  case sassari = "SS"
  case savona = "SV"
  case siena = "SI"
  case siracusa = "SR"
  case sondrio = "SO"
  case sudSardegna = "SU"
  case taranto = "TA"
  case teramo = "TE"
  case terni = "TR"
  case torino = "TO"
  case trapani = "TP"
  case trento = "TN"
  case treviso = "TV"
  case trieste = "TS"
  case udine = "UD"
  case varese = "VA"
  case venezia = "VE"
  case verbaniaCusioOssola = "VB"
  case vercelli = "VC"
  case verona = "VR"
  case viboValentia = "VV"
  case vicenza = "VI"
  case viterbo = "VT"

  // special
  case abroad = "EX"
}

public extension Province {
  /// Returns the region for the province
  var region: Region? {
    return Region.allCases.first { region in
      region.provinces.contains(self)
    }
  }

  var humanReadableName: String {
    switch self {
    case .agrigento:
      return "Agrigento"
    case .alessandria:
      return "Alessandria"
    case .ancona:
      return "Ancona"
    case .aosta:
      return "Aosta"
    case .arezzo:
      return "Arezzo"
    case .ascoliPiceno:
      return "Ascoli Piceno"
    case .asti:
      return "Asti"
    case .avellino:
      return "Avellino"
    case .bari:
      return "Bari"
    case .belluno:
      return "Belluno"
    case .benevento:
      return "Benevento"
    case .bergamo:
      return "Bergamo"
    case .biella:
      return "Biella"
    case .bologna:
      return "Bologna"
    case .bolzano:
      return "Bolzano / Bozen"
    case .brescia:
      return "Brescia"
    case .brindisi:
      return "Brindisi"
    case .cagliari:
      return "Cagliari"
    case .caltanissetta:
      return "Caltanissetta"
    case .campobasso:
      return "Campobasso"
    case .caserta:
      return "Caserta"
    case .catania:
      return "Catania"
    case .catanzaro:
      return "Catanzaro"
    case .chieti:
      return "Chieti"
    case .como:
      return "Como"
    case .cosenza:
      return "Cosenza"
    case .cremona:
      return "Cremona"
    case .crotone:
      return "Crotone"
    case .cuneo:
      return "Cuneo"
    case .enna:
      return "Enna"
    case .fermo:
      return "Fermo"
    case .ferrara:
      return "Ferrara"
    case .firenze:
      return "Firenze"
    case .foggia:
      return "Foggia"
    case .forliCesena:
      return "Forlì Cesena"
    case .frosinone:
      return "Frosinone"
    case .genova:
      return "Genova"
    case .gorizia:
      return "Gorizia"
    case .grosseto:
      return "Grosseto"
    case .imperia:
      return "Imperia"
    case .isernia:
      return "Isernia"
    case .lAquila:
      return "L\'Aquila"
    case .laSpezia:
      return "La Spezia"
    case .latina:
      return "Latina"
    case .lecce:
      return "Lecce"
    case .lecco:
      return "Lecco"
    case .livorno:
      return "Livorno"
    case .lodi:
      return "Lodi"
    case .lucca:
      return "Lucca"
    case .macerata:
      return "Macerata"
    case .mantova:
      return "Mantova"
    case .massaECarrara:
      return "Massa-Carrara"
    case .matera:
      return "Matera"
    case .messina:
      return "Messina"
    case .milano:
      return "Milano"
    case .modena:
      return "Modena"
    case .monzaEBrianza:
      return "Monza e Brianza"
    case .napoli:
      return "Napoli"
    case .novara:
      return "Novara"
    case .nuoro:
      return "Nuoro"
    case .oristano:
      return "Oristano"
    case .padova:
      return "Padova"
    case .palermo:
      return "Palermo"
    case .parma:
      return "Parma"
    case .pavia:
      return "Pavia"
    case .perugia:
      return "Perugia"
    case .pesaroEUrbino:
      return "Pesaro e Urbino"
    case .pescara:
      return "Pescara"
    case .piacenza:
      return "Piacenza"
    case .pisa:
      return "Pisa"
    case .pistoia:
      return "Pistoia"
    case .pordenone:
      return "Pordenone"
    case .potenza:
      return "Potenza"
    case .prato:
      return "Prato"
    case .ragusa:
      return "Ragusa"
    case .ravenna:
      return "Ravenna"
    case .reggioCalabria:
      return "Reggio Calabria"
    case .reggioEmilia:
      return "Reggio Emilia"
    case .rieti:
      return "Rieti"
    case .rimini:
      return "Rimini"
    case .roma:
      return "Roma"
    case .rovigo:
      return "Rovigo"
    case .salerno:
      return "Salerno"
    case .sassari:
      return "Sassari"
    case .savona:
      return "Savona"
    case .siena:
      return "Siena"
    case .siracusa:
      return "Siracusa"
    case .sondrio:
      return "Sondrio"
    case .taranto:
      return "Taranto"
    case .teramo:
      return "Teramo"
    case .terni:
      return "Terni"
    case .torino:
      return "Torino"
    case .trapani:
      return "Trapani"
    case .trento:
      return "Trento"
    case .treviso:
      return "Treviso"
    case .trieste:
      return "Trieste"
    case .udine:
      return "Udine"
    case .varese:
      return "Varese"
    case .venezia:
      return "Venezia"
    case .verbaniaCusioOssola:
      return "Verbano-Cusio-Ossola"
    case .vercelli:
      return "Vercelli"
    case .verona:
      return "Verona"
    case .viboValentia:
      return "Vibo Valentia"
    case .vicenza:
      return "Vicenza"
    case .viterbo:
      return "Viterbo"
    case .barlettaAndriaTrani:
      return "Barletta-Andria-Trani"
    case .sudSardegna:
      return "Sud Sardegna"
    case .abroad:
      return ""
    }
  }
}

extension Region: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs == .abroad {
      return false
    }

    return lhs.rawValue < rhs.rawValue
  }
}

extension Province: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    return lhs.humanReadableName < rhs.humanReadableName
  }
}
