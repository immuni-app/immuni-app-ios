// NetworkManager.swift
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
import Hydra
import Models

/// The NetworkManager is the executor of the requests.
/// It is important to note that the NetworkManager should not contain any additional information related to the final request
/// that is performed. An instance of HTTPRequest should contain all the information about a network call.
public class NetworkManager {
  private var dependencies: Dependencies?

  public init() {}

  public func start(with dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  /// Performs a request
  ///
  /// - parameter request:           the request to perform
  /// - parameter queue:             the queue in which the completion will be invoked. By default Alamofire uses the main thread
  @discardableResult
  public func request<R: HTTPRequest>(
    _ request: R,
    _ queue: DispatchQueue = DispatchQueue.global()
  ) -> Promise<R.ResponseSerializer.SerializedObject> {
    return self.unwrappedDependencies.requestExecutor.execute(request, queue)
  }
}

// MARK: - App Configuration Service requests

extension NetworkManager {
  /// Returns the most updated configuration for an app with the given `buildNumber`
  public func getConfiguration(for buildNumber: Int) -> Promise<Configuration> {
    return self.request(ConfigurationRequest(buildNumber: buildNumber))
  }

  /// Returns the most updated FAQs for the given language code.
  /// - parameter baseURL: the server's base url
  /// - parameter path: the FAQ's path
  public func getFAQ(baseURL: URL, path: String) -> Promise<[FAQ]> {
    return self.request(FAQRequest(baseURL: baseURL, path: path)).then { $0.faqs }
  }
}

// MARK: - Reporting Service requests

extension NetworkManager {
  /// Returns the current manifest for the chunk of TEKs exposed by the backend
  public func getKeysIndex() -> Promise<KeysIndex> {
    return self.request(KeysIndexRequest())
  }

  /// Downloads the chunks of TEKs for the given `indexes` and returns them as an array of `Data`, each corresponding to a given
  /// index in the input parameter.
  public func downloadChunks(with indexes: [Int]) -> Promise<[Data]> {
    let requestPromises = indexes
      .map { DownloadKeyChunkIndexRequest(chunkNumber: $0) }
      .map { self.request($0) }

    return all(requestPromises)
  }
}

// MARK: - Ingestion service requests

extension NetworkManager {
  /// Validates a given `OTP` with the backend
  public func validateOTP(_ otp: OTP, requestSize: Int) -> Promise<Void> {
    return self
      .request(OTPValidationRequest(
        otp: otp,
        now: self.unwrappedDependencies.now,
        targetSize: requestSize
      )).safeVoid
  }

  /// Uploads data to the backend as a consequence of a positive COVID diagnosis. The request is authenticated with a previously
  /// validated OTP.
  public func uploadData(body: DataUploadRequest.Body, otp: OTP, requestSize: Int) -> Promise<Void> {
    return self.request(DataUploadRequest(
      body: body,
      otp: otp,
      now: self.unwrappedDependencies.now,
      targetSize: requestSize
    )).safeVoid
  }

  /// Sends a dummy request to the backend.
  public func sendDummyIngestionRequest(requestSize: Int) -> Promise<Void> {
    return self.request(DummyIngestionRequest(now: self.unwrappedDependencies.now, targetSize: requestSize)).safeVoid
  }
}

// MARK: - Analytics Service requests

extension NetworkManager {
  /// Sends a request to validate an analytics token with the backend
  public func validateAnalyticsToken(
    analyticsToken: String,
    deviceToken: Data
  ) -> Promise<ValidateAnalyticsTokenRequest.ValidationResponse> {
    return self.request(ValidateAnalyticsTokenRequest(analyticsToken: analyticsToken, deviceToken: deviceToken))
  }

  /// Sends a request to the Analytics server, following a cycle of Exposure Detection.
  public func sendAnalytics(body: AnalyticsRequest.Body, isDummy: Bool) -> Promise<Void> {
    return self.request(AnalyticsRequest(body: body, isDummy: isDummy)).safeVoid
  }
}

// MARK: - Supporting types

public extension NetworkManager {
  private var unwrappedDependencies: Dependencies {
    return self.dependencies ?? LibLogger.fatalError("start(with:) not called")
  }

  struct Dependencies {
    public let requestExecutor: RequestExecutor
    public let now: () -> Date

    public init(requestExecutor: RequestExecutor, now: @escaping () -> Date) {
      self.requestExecutor = requestExecutor
      self.now = now
    }
  }
}

public extension NetworkManager {
  /// All network-related errors that the `NetworkManager` can throw
  enum Error: Int, Swift.Error {
    /// Error in connecting to the backend
    case connectionError = 1
    /// Base exception for any API unexpected behaviour.
    case unknownError = 1000
    /// Raised when a request is badly formed or the body is not compliant with the endpoint defined schema.
    case badRequest = 1001
    /// Raised when a user is attempting to upload data with an unauthorised OTP code.
    case unauthorizedOTP = 1101
    /// Exception raised when the requested batch is not found.
    case batchNotFound = 1300
    /// Exception raised when there are no batches.
    case noBatchesFound = 1301
    /// Raised when the OTP has already been auhorized.
    case otpAlreadyAuthorized = 1400
  }
}
