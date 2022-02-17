// Configuration.swift
// Copyright (C) 2021 Presidenza del Consiglio dei Ministri.
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

import ExposureNotification
import Foundation

public struct Configuration: Codable {
  enum CodingKeys: String, CodingKey {
    case countries
    case allowedRegionsSelfUpload = "allowed_regions_self_upload"
    case minimumBuildVersion = "minimum_build_version"
    case serviceNotActiveNotificationPeriod = "service_not_active_notification_period"
    case osForceUpdateNotificationPeriod = "onboarding_not_completed_notification_period"
    case requiredUpdateNotificationPeriod = "required_update_notification_period"
    case riskReminderNotificationPeriod = "risk_reminder_notification_period"
    case exposureDetectionPeriod = "exposure_detection_period"
    case exposureConfiguration = "exposure_configuration"
    case exposureInfoMinimumRiskScore = "exposure_info_minimum_risk_score"
    case maximumExposureDetectionWaitingTime = "maximum_exposure_detection_waiting_time"
    case privacyNoticeURL = "pn_url"
    case termsOfUseURL = "tou_url"
    case faqURL = "faq_url"
    case operationalInfoWithExposureSamplingRate = "operational_info_with_exposure_sampling_rate"
    case operationalInfoWithoutExposureSamplingRate = "operational_info_without_exposure_sampling_rate"
    case dummyAnalyticsMeanStochasticDelay = "dummy_analytics_waiting_time"
    case dummyIngestionAverageRequestWaitingTime = "dummy_teks_average_request_waiting_time"
    case dummyIngestionRequestProbabilities = "dummy_teks_request_probabilities"
    case dummyIngestionMeanStochasticDelay = "dummy_teks_average_opportunity_waiting_time"
    case dummyIngestionWindowDuration = "dummy_teks_window_duration"
    case dummyIngestionAverageStartUpDelay = "dummy_teks_average_start_waiting_time"
    case dataUploadMaxSummaryCount = "teks_max_summary_count"
    case dataUploadMaxExposureInfoCount = "teks_max_info_count"
    case ingestionRequestTargetSize = "teks_packet_size"
    case supportEmail = "support_email"
    case supportPhone = "support_phone"
    case supportPhoneOpeningTime = "support_phone_opening_time"
    case supportPhoneClosingTime = "support_phone_closing_time"
    case eudccExpiration = "eudcc_expiration"
    case riskExposure = "risk_exposure"
  }

  /// Countries of interest map
  public let countries: [String: [String: String]]

  // Allowed regions self upload
  public let allowedRegionsSelfUpload: [String]

  /// This is used to enforce a minimum version of the app.
  /// If the currently installed app has a lower version than the one specified
  /// in the settings, the app schedules the reminder notification and
  /// displays the Update (App) screen.
  public let minimumBuildVersion: Int

  /// How often the notification of not active service is sent.
  /// It is expressed in seconds.
  public let serviceNotActiveNotificationPeriod: TimeInterval

  /// How often the notification of Update (OS) is sent.
  /// It is expressed in seconds.
  public let osForceUpdateNotificationPeriod: TimeInterval

  /// How often the notification of a new app update is sent. It is expressed in seconds.
  public let requiredUpdateNotificationPeriod: TimeInterval

  /// How often the notification of the risk state is sent,
  /// if the user hasn’t opened the app after the initial contact notification.
  /// It is expressed in seconds.
  public var riskReminderNotificationPeriod: TimeInterval

  /// How much time should pass between two consecutive exposure
  /// detections It is expressed in seconds.
  public var exposureDetectionPeriod: TimeInterval

  /// Parameters for exposure notifications.
  public let exposureConfiguration: ExposureDetectionConfiguration

  /// The minimum risk score that triggers the app to
  /// fetch the exposure info and notify the user using the SDK-provided
  /// notification.
  public let exposureInfoMinimumRiskScore: Int

  /// Maximum time from the last exposure detection that should
  /// pass before a foreground session should force a new one.
  public let maximumExposureDetectionWaitingTime: TimeInterval

  /// The url of the privacy notice
  /// - note: this dictionary uses string as a key because only strings and ints
  /// are really considered as dictionaries by Codable
  /// https://bugs.swift.org/browse/SR-7788
  public let privacyNoticeURL: [String: URL]

  /// The url of the terms of use
  /// - note: this dictionary uses string as a key because only strings and ints
  /// are really considered as dictionaries by Codable
  /// https://bugs.swift.org/browse/SR-7788
  public let termsOfUseURL: [String: URL]

  /// The urls of the FAQs for the various languages
  /// - note: this dictionary uses string as a key because only strings and ints
  /// are really considered as dictionaries by Codable
  /// https://bugs.swift.org/browse/SR-7788
  public let faqURL: [String: URL]
  /// eudccExpiration - Dictionary with Expiration
  public let eudccExpiration: [String: [String: String]]
  /// riskExposure - Dictionary with riskExposure
  public let riskExposure: [String: String]
  /// Probability with which the app sends analytics data in case of match. Value in the [0, 1] range.
  public let operationalInfoWithExposureSamplingRate: Double

  /// Probability with which the app sends analytics data in case of non match. Value in the [0, 1] range.
  public let operationalInfoWithoutExposureSamplingRate: Double

  /// Mean of the exponential distribution that regulates the execution of dummy analytics requests
  public let dummyAnalyticsMeanStochasticDelay: Double

  /// Average wait time (in seconds) from one dummy ingestion request to the next one.
  public let dummyIngestionAverageRequestWaitingTime: Double

  /// Arrays of probabilities that describes the chance the app has after each dummy ingestion request to send another one.
  /// The i-th element represents the chance of sending a request after the i-th request.
  public let dummyIngestionRequestProbabilities: [Double]

  /// Mean of the exponential distribution that regulates the execution of dummy ingestion requests
  public let dummyIngestionMeanStochasticDelay: Double

  /// Duration of the window of opportunity the app has to send a dummy ingestion request.
  public let dummyIngestionWindowDuration: Double

  /// Average wait time (in seconds) from the start of a foreground session before starting a simulated dummy ingestion sequence.
  public let dummyIngestionAverageStartUpDelay: Double

  /// The maximum number of Exposure Detection Summary in a DataUpload
  public let dataUploadMaxSummaryCount: Int

  /// The maximum number of Exposure Info to include in a DataUpload
  public let dataUploadMaxExposureInfoCount: Int

  /// The target size, in byte, of each ingestion request
  public let ingestionRequestTargetSize: Int

  /// The email to contact support.
  public let supportEmail: String?

  /// The phone number to contact support.
  public let supportPhone: String?

  /// The phone opening time to contact support.
  public let supportPhoneOpeningTime: String?

  /// The phone closing time to contact support.
  public let supportPhoneClosingTime: String?

  /// The FAQ url for the given language. it returns english version if the given
  /// language is not available.
  /// Note that the method may still fail in case of missing english version
  public func faqURL(for language: UserLanguage) -> URL? {
    return self.faqURL[language.rawValue] ?? self.faqURL[UserLanguage.english.rawValue]
  }

  /// eudccExpiration
  public func eudccExpiration(for language: UserLanguage) -> [String: String]? {
    return self.eudccExpiration[language.rawValue] ?? self.eudccExpiration[UserLanguage.english.rawValue]
  }

  /// riskExposure
  public func riskExposure(for language: UserLanguage) -> String? {
    return self.riskExposure[language.rawValue] ?? self.riskExposure[UserLanguage.english.rawValue]
  }

  /// The Terms Of Use url for the given language. it returns english version if the given
  /// language is not available.
  /// Note that the method may still fail in case of missing english version
  public func termsOfUseURL(for language: UserLanguage) -> URL? {
    return self.termsOfUseURL[language.rawValue] ?? self.termsOfUseURL[UserLanguage.english.rawValue]
  }

  /// The Privacy Notice url for the given language. it returns english version if the given
  /// language is not available.
  /// Note that the method may still fail in case of missing english version
  public func privacyNoticeURL(for language: UserLanguage) -> URL? {
    return self.privacyNoticeURL[language.rawValue] ?? self.privacyNoticeURL[UserLanguage.english.rawValue]
  }

  /// Public initializer to allow testing
  public init(
    countries: [String: [String: String]] = .defaultCountries,
    allowedRegionsSelfUpload: [String] = [
      "Abruzzo",
      "Basilicata",
      "Calabria",
      "Campania",
      "Emilia-Romagna",
      "Friuli-Venezia Giulia",
      "Lazio",
      "Liguria",
      "Lombardia",
      "Marche",
      "Molise",
      "Piemonte",
      "Puglia",
      "Sardegna",
      "Sicilia",
      "Toscana",
      "Trentino-Alto Adige",
      "Umbria",
      "Valle d'Aosta",
      "Veneto"
    ],
    minimumBuildVersion: Int = 1,
    serviceNotActiveNotificationPeriod: TimeInterval = 86400,
    osForceUpdateNotificationPeriod: TimeInterval = 86400,
    requiredUpdateNotificationPeriod: TimeInterval = 86400,
    riskReminderNotificationPeriod: TimeInterval = 86400,
    exposureDetectionPeriod: TimeInterval = 14400,
    exposureConfiguration: ExposureDetectionConfiguration = .init(),
    exposureInfoMinimumRiskScore: Int = 12,
    maximumExposureDetectionWaitingTime: TimeInterval = 86400,
    privacyNoticeURL: [String: URL] = .defaultPrivacyNoticeURL,
    termsOfUseURL: [String: URL] = .defaultTermsOfUseURL,
    faqURL: [String: URL] = .defaultFAQURL,
    eudccExpiration: [String: [String: String]] = .defaultEudcc,
    riskExposure: [String: String] = .defaultRiskExposure,
    operationalInfoWithExposureSamplingRate: Double = 1,
    operationalInfoWithoutExposureSamplingRate: Double = 0.6,
    dummyAnalyticsWaitingTime: Double = 2_592_000,
    dummyIngestionAverageRequestWaitingTime: Double = 10,
    dummyIngestionRequestProbabilities: [Double] = [0.95, 0.1],
    dummyIngestionMeanStochasticDelay: Double = 5_184_000,
    dummyIngestionWindowDuration: Double = 1_209_600,
    dummyIngestionAverageStartUpDelay: Double = 15,
    dataUploadMaxSummaryCount: Int = 84,
    dataUploadMaxExposureInfoCount: Int = 600,
    ingestionRequestTargetSize: Int = 110_000,
    supportEmail: String? = "cittadini@immuni.italia.it",
    supportPhone: String? = "800912491",
    supportPhoneOpeningTime: String? = "7",
    supportPhoneClosingTime: String? = "22"
  ) {
    self.countries = countries
    self.allowedRegionsSelfUpload = allowedRegionsSelfUpload
    self.minimumBuildVersion = minimumBuildVersion
    self.serviceNotActiveNotificationPeriod = serviceNotActiveNotificationPeriod
    self.osForceUpdateNotificationPeriod = osForceUpdateNotificationPeriod
    self.requiredUpdateNotificationPeriod = requiredUpdateNotificationPeriod
    self.riskReminderNotificationPeriod = riskReminderNotificationPeriod
    self.exposureDetectionPeriod = exposureDetectionPeriod
    self.exposureConfiguration = exposureConfiguration
    self.exposureInfoMinimumRiskScore = exposureInfoMinimumRiskScore
    self.maximumExposureDetectionWaitingTime = maximumExposureDetectionWaitingTime
    self.privacyNoticeURL = privacyNoticeURL
    self.termsOfUseURL = termsOfUseURL
    self.faqURL = faqURL
    self.eudccExpiration = eudccExpiration
    self.riskExposure = riskExposure
    self.operationalInfoWithExposureSamplingRate = operationalInfoWithExposureSamplingRate
    self.operationalInfoWithoutExposureSamplingRate = operationalInfoWithoutExposureSamplingRate
    self.dummyAnalyticsMeanStochasticDelay = dummyAnalyticsWaitingTime
    self.dummyIngestionAverageRequestWaitingTime = dummyIngestionAverageRequestWaitingTime
    self.dummyIngestionRequestProbabilities = dummyIngestionRequestProbabilities
    self.dummyIngestionMeanStochasticDelay = dummyIngestionMeanStochasticDelay
    self.dummyIngestionWindowDuration = dummyIngestionWindowDuration
    self.dummyIngestionAverageStartUpDelay = dummyIngestionAverageStartUpDelay
    self.dataUploadMaxSummaryCount = dataUploadMaxSummaryCount
    self.dataUploadMaxExposureInfoCount = dataUploadMaxExposureInfoCount
    self.ingestionRequestTargetSize = ingestionRequestTargetSize
    self.supportEmail = supportEmail
    self.supportPhone = supportPhone
    self.supportPhoneOpeningTime = supportPhoneOpeningTime
    self.supportPhoneClosingTime = supportPhoneClosingTime
  }

  // swiftlint:enable force_unwrapping
}

public extension Configuration {
  struct ExposureDetectionConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
      case attenuationThresholds = "attenuation_thresholds"
      case attenuationBucketScores = "attenuation_bucket_scores"
      case attenuationWeight = "attenuation_weight"
      case daysSinceLastExposureBucketScores = "days_since_last_exposure_bucket_scores"
      case daysSinceLastExposureWeight = "days_since_last_exposure_weight"
      case durationBucketScores = "duration_bucket_scores"
      case durationWeight = "duration_weight"
      case transmissionRiskBucketScores = "transmission_risk_bucket_scores"
      case transmissionRiskWeight = "transmission_risk_weight"
      case minimumRiskScore = "minimum_risk_score"
    }

    /// The thresholds of dBm that dictates how attenuations are divided into buckets in `ExposureInfo.attenuationDurations`
    public let attenuationThresholds: [Int]

    /// Scores that indicate Bluetooth signal strength.
    public let attenuationBucketScores: [UInt8]

    /// The weight applied to a Bluetooth signal strength score.
    public let attenuationWeight: Double

    /// Scores that indicate the days since the user’s last exposure.
    public let daysSinceLastExposureBucketScores: [UInt8]

    /// The weight assigned to a score applied to the days since the user’s exposure.
    public let daysSinceLastExposureWeight: Double

    /// Scores that indicate the duration of a user’s exposure.
    public let durationBucketScores: [UInt8]

    /// The weight assigned to a score applied to the duration of the user’s exposure.
    public let durationWeight: Double

    /// Scores for the user’s estimated risk of transmission.
    public let transmissionRiskBucketScores: [UInt8]

    /// The weight assigned to a score applied to the user’s risk of transmission.
    public let transmissionRiskWeight: Double

    /// The user’s minimum risk score.
    public let minimumRiskScore: UInt8

    /// Public initializer to allow testing
    public init(
      attenuationThresholds: [Int] = [50, 70],
      attenuationBucketScores: [UInt8] = [0, 0, 3, 3, 3, 3, 3, 3],
      attenuationWeight: Double = 1,
      daysSinceLastExposureBucketScores: [UInt8] = [1, 1, 1, 1, 1, 1, 1, 1],
      daysSinceLastExposureWeight: Double = 1,
      durationBucketScores: [UInt8] = [0, 0, 0, 0, 5, 5, 5, 5],
      durationWeight: Double = 1,
      transmissionRiskBucketScores: [UInt8] = [1, 1, 1, 1, 1, 1, 1, 1],
      transmissionRiskWeight: Double = 1,
      minimumRiskScore: UInt8 = 1
    ) {
      self.attenuationThresholds = attenuationThresholds
      self.attenuationBucketScores = attenuationBucketScores
      self.attenuationWeight = attenuationWeight
      self.daysSinceLastExposureBucketScores = daysSinceLastExposureBucketScores
      self.daysSinceLastExposureWeight = daysSinceLastExposureWeight
      self.durationBucketScores = durationBucketScores
      self.durationWeight = durationWeight
      self.transmissionRiskBucketScores = transmissionRiskBucketScores
      self.transmissionRiskWeight = transmissionRiskWeight
      self.minimumRiskScore = minimumRiskScore
    }
  }
}

public extension Dictionary where Key == String, Value == URL {
  /// default values for FAQs
  static var defaultFAQURL: [String: URL] {
    let values = UserLanguage.allCases.map { lang in
      // swiftlint:disable:next force_unwrapping
      (lang.rawValue, URL(string: "https://get.immuni.gov.it/docs/faq-\(lang.rawValue).json")!)
    }

    return Dictionary(uniqueKeysWithValues: values)
  }

  /// default values for privacy notifice
  static var defaultPrivacyNoticeURL: [String: URL] {
    let values = UserLanguage.allCases.map { lang in
      // swiftlint:disable:next force_unwrapping
      (lang.rawValue, URL(string: "https://www.immuni.italia.it/app-pn.html")!)
    }

    return Dictionary(uniqueKeysWithValues: values)
  }

  /// default values for privacy notifice
  static var defaultTermsOfUseURL: [String: URL] {
    let values = UserLanguage.allCases.map { lang in
      // swiftlint:disable:next force_unwrapping
      (lang.rawValue, URL(string: "https://www.immuni.italia.it/app-tou.html")!)
    }

    return Dictionary(uniqueKeysWithValues: values)
  }
}

public extension Dictionary where Key == String, Value == [String: String] {
  /// default values for countries
  static var defaultCountries: [String: [String: String]] {
    let values = [
      "it": [
        "AT": "AUSTRIA",
        "HR": "CROAZIA",
        "DK": "DANIMARCA",
        "EE": "ESTONIA",
        "DE": "GERMANIA",
        "IE": "IRLANDA",
        "LV": "LETTONIA",
        "NL": "PAESI BASSI",
        "PL": "POLONIA",
        "CZ": "REPUBBLICA CECA",
        "ES": "SPAGNA"
      ],
      "de": [
        "AT": "ÖSTERREICH",
        "HR": "KROATIEN",
        "DK": "DÄNEMARK",
        "EE": "ESTONIA",
        "DE": "DEUTSCHLAND",
        "IE": "IRLAND",
        "LV": "LETTLAND",
        "NL": "NIEDERLANDE",
        "PL": "POLEN",
        "CZ": "TSCHECHISCHE REPUBLIK",
        "ES": "SPANIEN"
      ],
      "en": [
        "AT": "AUSTRIA",
        "HR": "CROATIA",
        "DK": "DENMARK",
        "EE": "ESTONIA",
        "DE": "GERMANY",
        "IE": "IRELAND",
        "LV": "LATVIA",
        "NL": "NETHERLANDS",
        "PL": "POLAND",
        "CZ": "CZECH REPUBLIC",
        "ES": "SPAIN"
      ],
      "fr": [
        "AT": "AUTRICHE",
        "HR": "CROATIE",
        "DK": "DANEMARK",
        "EE": "ESTONIE",
        "DE": "ALLEMAGNE",
        "IE": "IRLANDE",
        "LV": "LETTONIE",
        "NL": "PAYS-BAS",
        "PL": "POLOGNE",
        "CZ": "RÉPUBLIQUE TCHÈQUE",
        "ES": "ESPAGNE"
      ],
      "es": [
        "AT": "AUSTRIA",
        "HR": "CROACIA",
        "DK": "DINAMARCA",
        "EE": "ESTONIA",
        "DE": "ALEMANIA",
        "IE": "IRLANDA",
        "LV": "LETONIA",
        "NL": "PAÍSES BAJOS",
        "PL": "POLONIA",
        "CZ": "REPÚBLICA CHECA",
        "ES": "ESPAÑA"
      ]
    ]
    return values
  }

  static var defaultEudcc: [String: [String: String]] {
    let values = [
      "de": [
        "molecular_test": "Bescheinigung gültig für 72 Stunden ab dem Zeitpunkt der Abholung",
        "rapid_test": "Bescheinigung gültig für 48 Stunden ab dem Zeitpunkt der Abholung",
        "vaccine_first_dose": "Bescheinigung gültig ab dem 15. Tag ab dem Tag der Verabreichung und bis zur maximalen Zeit, die für die nächste Dosis vorgesehen ist",
        "vaccine_fully_completed": "Zertifizierung gültig für 180 Tage (6 Monate) ab dem Datum der letzten Verabreichung, vorbehaltlich behördlicher Änderungen",
        "healing_certificate": "Zertifizierung gültig in der Europäischen Union bis Gültigkeitsende und gültig in Italien 180 Tage (6 Monate) ab Gültigkeitsbeginn, vorbehaltlich behördlicher Änderungen",
        "vaccine_booster": "Zertifizierung gültig für 180 Tage (6 Monate) ab dem Datum der letzten Verabreichung, vorbehaltlich behördlicher Änderungen",
        "cbis": "Zertifizierung gültig in der Europäischen Union bis Gültigkeitsende und gültig in Italien 540 Tage (18 Monate) ab Gültigkeitsbeginn, vorbehaltlich behördlicher Änderungen"
      ],
      "en": [
        "molecular_test": "Certification valid for 72 hours from the time of collection",
        "rapid_test": "Certification valid for 48 hours from the time of collection",
        "vaccine_first_dose": "Certification valid from the 15th day from the date of administration and up to the maximum time foreseen for the next dose",
        "vaccine_fully_completed": "Certification valid for 180 days (6 months) from the date of the last administration, subject to regulatory changes",
        "healing_certificate": "Certification valid in the European Union until the end of validity date and valid in Italy 180 days (6 months) from the start of validity date, subject to regulatory changes",
        "vaccine_booster": "Certification valid for 180 days (6 months) from the date of the last administration, subject to regulatory changes",
        "cbis": "Certification valid in the European Union until the end of validity date and valid in Italy 540 days (18 months) from the start of validity date, subject to regulatory changes"
      ],
      "es": [
        "molecular_test": "Certificación válida por 72 horas desde el momento de la recogida.",
        "rapid_test": "Certificación válida por 48 horas desde el momento de la recogida.",
        "vaccine_first_dose": "Certificación válida desde el día 15 desde la fecha de administración y hasta el tiempo máximo previsto para la siguiente dosis",
        "vaccine_fully_completed": "Certificación válida por 180 días (6 meses) a partir de la fecha de la última administración, sujeta a cambios regulatorios",
        "healing_certificate": "Certificación válida en la Unión Europea hasta el final de la fecha de validez y válida en Italia 180 días (6 meses) desde el inicio de la fecha de validez, sujeta a cambios regulatorios",
        "vaccine_booster": "Certificación válida por 180 días (6 meses) a partir de la fecha de la última administración, sujeta a cambios regulatorios",
        "cbis": "Certificación válida en la Unión Europea hasta el final de la fecha de validez y válida en Italia 540 días (18 meses) desde el inicio de la fecha de validez, sujeta a cambios regulatorios"
      ],
      "fr": [
        "molecular_test": "Attestation valable 72h à compter de la collecte",
        "rapid_test": "Attestation valable 48h à compter de la collecte",
        "vaccine_first_dose": "Certification valable à partir du 15ème jour à compter de la date d'administration et jusqu'à l'heure maximale prévue pour la prochaine dose",
        "vaccine_fully_completed": "Certification valable 180 jours (6 mois) à compter de la date de la dernière administration, sous réserve de modifications réglementaires",
        "healing_certificate": "Certification valable dans l'Union européenne jusqu'à la date de fin de validité et valable en Italie 180 jours (6 mois) à compter de la date de début de validité, sous réserve de modifications réglementaires",
        "vaccine_booster": "Certification valable 180 jours (6 mois) à compter de la date de la dernière administration, sous réserve de modifications réglementaires",
        "cbis": "Certification valable dans l'Union européenne jusqu'à la date de fin de validité et valable en Italie 540 jours (18 mois) à compter de la date de début de validité, sous réserve de modifications réglementaires"
      ],
      "it": [
        "molecular_test": "Certificazione valida 72 ore dall'ora del prelievo",
        "rapid_test": "Certificazione valida 48 ore dall'ora del prelievo",
        "vaccine_first_dose": "Certificazione valida dal 15° giorno dalla data di somministrazione e fino al tempo massimo previsto per la dose successiva",
        "vaccine_fully_completed": "Certificazione valida 180 giorni (6 mesi) dalla data dell'ultima somministrazione, salvo modifiche normative",
        "healing_certificate": "Certificazione valida in Unione Europea fino alla data di fine validità e valida in Italia 180 giorni (6 mesi) dalla data di inizio validità, salvo modifiche normative",
        "vaccine_booster": "Certificazione valida 180 giorni (6 mesi) dalla data dell'ultima somministrazione, salvo modifiche normative",
        "cbis": "Certificazione valida in Unione Europea fino alla data di fine validità e valida in Italia 540 giorni (18 mesi) dalla data di inizio validità, salvo modifiche normative"
      ]
    ]
    return values
  }
}

public extension Dictionary where Key == String, Value == String {
  
  static var defaultRiskExposure: [String: String] {
      let values = [
        "de": "Für Sie ist keine Quarantäne vorgesehen und die Selbstüberwachungsmaßnahme für 5 Tage wird angewendet. \n\nBeim ersten Auftreten von Symptomen einen schnellen oder molekularen Antigentest zum Nachweis von Sars-Cov-2 durchführen und, falls noch symptomatisch, am fünften Tag nach dem Datum des letzten engen Kontakts mit positiv auf Covid 19 positiv getesteten Personen . Tragen Sie Geräte FFP2-Atemschutz für mindestens 10 Tage nach dem letzten Kontakt mit dem Fall. \n\nWenn Sie keine Symptome haben und nicht geimpft sind oder die Grundimmunisierung nicht abgeschlossen haben (Sie haben nur eine der beiden Impfdosen erhalten) oder wenn Sie die Grundimmunisierung weniger als 14 Tage abgeschlossen haben oder asymptomatisch sind und die Grundimmunisierung abgeschlossen haben oder sich seit mehr als 120 Tagen ohne Auffrischimpfung von einer früheren SARS-CoV-2-Infektion erholt haben, bleiben Sie bei Haus für die Dauer der Quarantäne von 5 Tagen ab dem letzten Kontakt mit dem positiven Fall. Nach dieser Zeit müssen Sie einen schnellen oder molekularen Antigentest durchführen. Bei negativem Ergebnis endet die Quarantäne, aber Sie müssen für die nächsten fünf Tage FFP2-Schutzausrüstung tragen. \n\nSollten während der Quarantänezeit Symptome auftreten, die auf eine mögliche Sars-Cov-2-Infektion hindeuten, wird ein sofortiger diagnostischer Test empfohlen.",
        "en": "You are not quarantine is foreseen and the self-surveillance measure lasting 5 days is applied. \n\nAt the first appearance of symptoms carry out a rapid or molecular antigen test for the detection of Sars-Cov-2 and, if still symptomatic, on the fifth day following the date of the last close contact with subjects confirmed positive for Covid 19. Wear devices FFP2 respiratory protection for at least 10 days from the last exposure to the case. \n\nIf you have no symptoms and are not vaccinated or have not completed the primary vaccination course (you have received only one of the two vaccine doses) or if you have completed the primary vaccination course for less than 14 days, or are asymptomatic and have completed the primary vaccination course or have recovered from a previous SARS-CoV-2 infection for more than 120 days without receiving the booster dose, stay at house for the duration of the quarantine of 5 days from the last contact with the positive case. After this time, you need to do a rapid or molecular antigen test. If the result is negative, the quarantine ends but you must wear FFP2 protective equipment for the next five days. \n\nIf during the quarantine period you experience symptoms suggestive of possible Sars-Cov-2 infection, immediate execution of the a diagnostic test.",
        "es": "No está prevista la cuarentena y se aplica la medida de autovigilancia de 5 días. \n\nA la primera aparición de síntomas realizar una prueba rápida o de antígeno molecular para la detección de Sars-Cov-2 y, si continúa sintomático, al quinto día siguiente a la fecha del último contacto cercano con sujetos confirmados positivos para Covid 19 .Usar dispositivos de protección respiratoria FFP2 durante al menos 10 días desde la última exposición al caso.\n\nSi no tiene síntomas y no está vacunado o no ha completado el ciclo de vacunación primaria (ha recibido solo una de las dos dosis de vacuna) o si completó el ciclo de vacunación primaria durante menos de 14 días, o está asintomático y completó el ciclo de vacunación primaria o se recuperó de una infección previa por SARS-CoV-2 durante más de 120 días sin recibir la dosis de refuerzo, quédese en casa mientras dure la cuarentena de 5 días a partir del último contacto con el caso positivo. Pasado este tiempo, es necesario realizar una prueba rápida o de antígeno molecular. Si el resultado es negativo, finaliza la cuarentena pero debe llevar equipo de protección FFP2 durante los cinco días siguientes.\n\nSi durante el periodo de cuarentena presenta síntomas sugestivos de posible infección por Sars-Cov-2, realización inmediata de una prueba diagnóstica.",
        "fr": "Vous n'êtes pas en quarantaine est prévue et la mesure d'auto-surveillance d'une durée de 5 jours est appliquée. \n\nÀ la première apparition des symptômes effectuer un test antigénique rapide ou moléculaire pour la détection du Sars-Cov-2 et, si toujours symptomatique, le cinquième jour suivant la date du dernier contact rapproché avec des sujets confirmés positifs au Covid 19 Porter des appareils de protection respiratoire FFP2 pendant au moins 10 jours à compter de la dernière exposition au cas.\n\nSi vous ne présentez aucun symptôme et n'êtes pas vacciné ou n'avez pas terminé la primovaccination (vous n'avez reçu qu'une seule des deux doses de vaccin) ou si vous avez terminé la primo-vaccination depuis moins de 14 jours, ou si vous êtes asymptomatique et avez terminé la primo-vaccination ou vous êtes remis d'une précédente infection par le SRAS-CoV-2 depuis plus de 120 jours sans avoir reçu la dose de rappel, restez à maison pendant la durée de la quarantaine de 5 jours à compter du dernier contact avec le cas positif. Passé ce délai, vous devez effectuer un test d'antigène rapide ou moléculaire. Si le résultat est négatif, la quarantaine prend fin mais vous devez porter un équipement de protection FFP2 pendant les cinq prochains jours.\n\nSi pendant la période de quarantaine vous présentez des symptômes évocateurs d'une éventuelle infection au Sars-Cov-2, exécution immédiate d'un test de diagnostic.",
        "it": "Se non hai sintomi e hai ricevuto la dose booster oppure hai completato il ciclo vaccinale primario nei 120 giorni precedenti, oppure sei guarito da infezione da SARS-CoV-2 nei 120 giorni precedenti, oppure sei guarito dopo il completamento del ciclo primario, non è prevista la quarantena e si applica la misura dell’autosorveglianza della durata di 5 giorni. \n\nAlla prima comparsa di sintomi effettua un test antigenico rapido o molecolare per la rilevazione di Sars-Cov-2 e, se ancora sintomatico, al quinto giorno successivo alla data dell’ultimo contatto stretto con soggetti confermati positivi al Covid 19. Indossa dispositivi di protezione delle vie respiratorie di tipo FFP2 per almeno 10 giorni dall’ultima esposizione al caso.\n\nSe non hai sintomi e non sei vaccinato o non hai completato il ciclo vaccinale primario (hai ricevuto una sola dose di vaccino delle due previste) o se hai completato il ciclo vaccinale primario da meno di 14 giorni, oppure sei asintomatico e hai completato il ciclo vaccinale primario o sei guarito da precedente infezione da SARS-CoV-2 da più di 120 giorni senza aver ricevuto la dose di richiamo, rimani a casa per la durata della quarantena di 5 giorni dall’ultimo contatto con il caso positivo. Dopo tale periodo devi effettuare un test antigenico rapido o molecolare. Se il risultato è negativo, la quarantena cessa ma per i cinque giorni successivi devi indossare i dispositivi di protezione FFP2.\n\nSe durante il periodo di quarantena manifesti sintomi suggestivi di possibile infezione da Sars-Cov-2 è raccomandata l’esecuzione immediata di un test diagnostico."
      ]
      return values
    }

}
