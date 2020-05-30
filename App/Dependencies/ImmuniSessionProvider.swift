// ImmuniSessionProvider.swift
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

import Alamofire
import Extensions
import Foundation
import Networking

/// Implementation of `SessionProvider`
struct ImmuniSessionProvider: SessionProvider {
  /// Hosts that the application has to contact in a production
  /// environment
  static var productionHosts: [String] = [
    "get.immuni.gov.it",
    "upload.immuni.gov.it",
    "analytics.immuni.gov.it"
  ]

  /// The application's bundle
  let bundle: Bundle

  init(bundle: Bundle) {
    self.bundle = bundle
  }

  func getSession() -> Session {
    #if DEBUG
      return .default
    #else
      let trustEvaluator = ImmuniTrustEvaluator(using: self.bundle)
      let evaluators = Self.productionHosts.map { ($0, trustEvaluator) }
      let trustManager = ServerTrustManager(
        allHostsMustBeEvaluated: true,
        evaluators: Dictionary(uniqueKeysWithValues: evaluators)
      )

      return Session(serverTrustManager: trustManager)
    #endif
  }
}

/// A trust evaluator that only allows connections coming from the certificates
/// signed with Actalis root certificate
struct ImmuniTrustEvaluator: ServerTrustEvaluating {
  let certificates: [SecCertificate]

  init(using bundle: Bundle) {
    self.certificates = bundle.af.certificates
  }

  func evaluate(_ trust: SecTrust, forHost host: String) throws {
    // performs default system evaluation
    try trust.af.performDefaultValidation(forHost: host)

    // set local certificates and local certificates only
    try trust.af.setAnchorCertificates(self.certificates)

    // validate
    try trust.af.evaluate()
  }
}
