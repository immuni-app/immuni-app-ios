// ImmuniTemporaryExposureKeyProviderTests.swift
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

@testable import Immuni
import XCTest
import Persistence
import Hydra
import Models
import Networking

final class ImmuniTemporaryExposureKeyProviderTests: XCTestCase {
  func testReturnCorrectValues() throws {
    let mockedExecutor = MockRequestExecutor(mockedResult: .success(KeysIndex(oldest: 50, newest: 60)))
    let networkManager = NetworkManager()
    networkManager.start(with: .init(requestExecutor: mockedExecutor, now: { Date() }))

    let keyProvider = ImmuniTemporaryExposureKeyProvider(networkManager: networkManager, fileStorage: MockFileStorage())

    let promise = keyProvider.getMissingChunksIndexes(latestKnownChunkIndex: nil)

    expectToEventually(promise.isPending == false)

    let chunks = try XCTUnwrap(promise.result)

    XCTAssertEqual(chunks.first, 50)
    XCTAssertEqual(chunks.last, 60)
  }

  func testReturnCorrectValuesWithKnownChunk() throws {
    let mockedExecutor = MockRequestExecutor(mockedResult: .success(KeysIndex(oldest: 50, newest: 60)))
    let networkManager = NetworkManager()
    networkManager.start(with: .init(requestExecutor: mockedExecutor, now: { Date() }))

    let keyProvider = ImmuniTemporaryExposureKeyProvider(networkManager: networkManager, fileStorage: MockFileStorage())

    let promise = keyProvider.getMissingChunksIndexes(latestKnownChunkIndex: 55)

    expectToEventually(promise.isPending == false)

    let chunks = try XCTUnwrap(promise.result)

    XCTAssertEqual(chunks.first, 56)
    XCTAssertEqual(chunks.last, 60)
  }

  func testReturnCorrectValuesOnRateLimit() throws {
    let mockedExecutor = MockRequestExecutor(mockedResult: .success(KeysIndex(oldest: 50, newest: 80)))
    let networkManager = NetworkManager()
    networkManager.start(with: .init(requestExecutor: mockedExecutor, now: { Date() }))

    let keyProvider = ImmuniTemporaryExposureKeyProvider(networkManager: networkManager, fileStorage: MockFileStorage())

    let promise = keyProvider.getMissingChunksIndexes(latestKnownChunkIndex: 55)

    expectToEventually(promise.isPending == false)

    let chunks = try XCTUnwrap(promise.result)

    XCTAssertEqual(chunks.first, 66) // 80 minus the Apple rate limit
    XCTAssertEqual(chunks.last, 80)
  }

  func testReturnCorrectValuesOnNoChunks() throws {
    let mockedExecutor = MockRequestExecutor(mockedResult: .success(KeysIndex(oldest: 50, newest: 80)))
    let networkManager = NetworkManager()
    networkManager.start(with: .init(requestExecutor: mockedExecutor, now: { Date() }))

    let keyProvider = ImmuniTemporaryExposureKeyProvider(networkManager: networkManager, fileStorage: MockFileStorage())

    let promise = keyProvider.getMissingChunksIndexes(latestKnownChunkIndex: 80)

    expectToEventually(promise.isPending == false)

    let chunks = try XCTUnwrap(promise.result)
    
    XCTAssertEqual(chunks.count, 0)
  }
}

private struct MockFileStorage: FileStorage {
  func write(_ data: Data, with fileNameWithoutExtension: String) -> Promise<[URL]> {
    return Promise(resolved: [])
  }

  func delete(_ urls: [URL]) -> Promise<Void> {
    return Promise(resolved: ())
  }
}
