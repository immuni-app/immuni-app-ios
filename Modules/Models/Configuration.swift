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
        "vaccine_booster": "Zertifizierung gültig für 180 Tage (6 Monate) ab dem Datum der letzten Verabreichung, vorbehaltlich behördlicher Änderungen"
      ],
      "en": [
        "molecular_test": "Certification valid for 72 hours from the time of collection",
        "rapid_test": "Certification valid for 48 hours from the time of collection",
        "vaccine_first_dose": "Certification valid from the 15th day from the date of administration and up to the maximum time foreseen for the next dose",
        "vaccine_fully_completed": "Certification valid for 180 days (6 months) from the date of the last administration, subject to regulatory changes",
        "healing_certificate": "Certification valid in the European Union until the end of validity date and valid in Italy 180 days (6 months) from the start of validity date, subject to regulatory changes",
        "vaccine_booster": "Certification valid for 180 days (6 months) from the date of the last administration, subject to regulatory changes"
      ],
      "es": [
        "molecular_test": "Certificación válida por 72 horas desde el momento de la recogida.",
        "rapid_test": "Certificación válida por 48 horas desde el momento de la recogida.",
        "vaccine_first_dose": "Certificación válida desde el día 15 desde la fecha de administración y hasta el tiempo máximo previsto para la siguiente dosis",
        "vaccine_fully_completed": "Certificación válida por 180 días (6 meses) a partir de la fecha de la última administración, sujeta a cambios regulatorios",
        "healing_certificate": "Certificación válida en la Unión Europea hasta el final de la fecha de validez y válida en Italia 180 días (6 meses) desde el inicio de la fecha de validez, sujeta a cambios regulatorios",
        "vaccine_booster": "Certificación válida por 180 días (6 meses) a partir de la fecha de la última administración, sujeta a cambios regulatorios"
      ],
      "fr": [
        "molecular_test": "Attestation valable 72h à compter de la collecte",
        "rapid_test": "Attestation valable 48h à compter de la collecte",
        "vaccine_first_dose": "Certification valable à partir du 15ème jour à compter de la date d'administration et jusqu'à l'heure maximale prévue pour la prochaine dose",
        "vaccine_fully_completed": "Certification valable 180 jours (6 mois) à compter de la date de la dernière administration, sous réserve de modifications réglementaires",
        "healing_certificate": "Certification valable dans l'Union européenne jusqu'à la date de fin de validité et valable en Italie 180 jours (6 mois) à compter de la date de début de validité, sous réserve de modifications réglementaires",
        "vaccine_booster": "Certification valable 180 jours (6 mois) à compter de la date de la dernière administration, sous réserve de modifications réglementaires"
      ],
      "it": [
        "molecular_test": "Certificazione valida 72 ore dall'ora del prelievo",
        "rapid_test": "Certificazione valida 48 ore dall'ora del prelievo",
        "vaccine_first_dose": "Certificazione valida dal 15° giorno dalla data di somministrazione e fino al tempo massimo previsto per la dose successiva",
        "vaccine_fully_completed": "Certificazione valida 180 giorni (6 mesi) dalla data dell'ultima somministrazione, salvo modifiche normative",
        "healing_certificate": "Certificazione valida in Unione Europea fino alla data di fine validità e valida in Italia 180 giorni (6 mesi) dalla data di inizio validità, salvo modifiche normative",
        "vaccine_booster": "Certificazione valida 180 giorni (6 mesi) dalla data dell'ultima somministrazione, salvo modifiche normative"
      ]
    ]
    return values
  }
}
