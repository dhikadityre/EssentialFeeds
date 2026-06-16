//
//  CodableFeedStoreTests.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 14/06/26.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ localFeedImage: LocalFeedImage) {
            self.id = localFeedImage.id
            self.description = localFeedImage.description
            self.location = localFeedImage.location
            self.url = localFeedImage.url
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(
                id: id,
                description: description,
                location: location,
                url: url
            )
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping (FeedStore.RetrieveCompletion)) {
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: self.storeURL) else {
                return completion(.empty)
            }
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func insert(
        _ feed: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping FeedStore.InsertionCompletion
    ) {
        /*
         /// Menggunakan encoder dan menyelesaikan completion secara async
        DispatchQueue.global().async {
            let encoder = JSONEncoder()
            let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
            let encoded = try! encoder.encode(cache)
            try! encoded.write(to: self.storeURL)
            completion(nil)
        }
        */
         
        DispatchQueue.global().async {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: self.storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}

class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        /*
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
         */
        
        // THEN
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        /*
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving result twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
        */
        
        /*
        /// Kita dapat melakukan ini langsung
        expect(sut, toRetrieve: .empty)
        expect(sut, toRetrieve: .empty)
        */
        expect(sut, toRetrieveTwice: .empty)
    }
    
    
    /// Insert - To empty cache works (to empty cache stores data)
    /// Retrieve - Empty cache twice returns empty (no side effects)
    // func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
    func test_retrieve_deliversFoundValueOnNonEmptyCache() {
        // GIVEN
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        // WHEN
        /*
        let exp = expectation(description: "Wait for cache retrieval")
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
            
            /// Move retrieve setelah wait menggunakan `expect()`
            /*
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .found(retrievedFeed, retrievedTimestamp):
                    XCTAssertEqual(retrievedFeed, feed)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                    
                default:
                    XCTFail("Expected found result with feed \(feed) and timestamp \(timestamp), got \(retrieveResult) instead")
                }
                
                exp.fulfill()
            }
            */
        }
        wait(for: [exp], timeout: 1.0)
        */
        insert((feed, timestamp: timestamp), to: sut)
        
        // THEN
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    /// Non-empty cache twice returns same data (retrieve should have no side-effects)
    func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
        // GIVEN
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        // WHEN
        /*
        let exp = expectation(description: "Wait for cache retrieval")
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            
            sut.retrieve { firstResult in
                sut.retrieve { secondResult in
                    switch (firstResult, secondResult) {
                    case let (.found(firstResult), .found(secondResult)):
                        XCTAssertEqual(firstResult.feed, feed)
                        XCTAssertEqual(firstResult.timestamp, timestamp)
                        
                        XCTAssertEqual(secondResult.feed, feed)
                        XCTAssertEqual(secondResult.timestamp, timestamp)
                    default:
                        XCTFail("Expected retrieving twice from non empty cache deliver same found result with feed \(feed) and timestamp \(timestamp), got \(firstResult) and \(secondResult) instead")
                    }
                }
                
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
        */
        
        /*
        let exp = expectation(description: "Wait for cache insertion")
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
         */
        
        insert((feed, timestamp: timestamp), to: sut)
        
        
        // THEN
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    /// Retrieve - Error (if possible to simulate, e.g., invalid data)
    /// To Retrive an Error, we can just add some `invalid data` to the `storeURL` then try to `retrieve` our `models`.
    func test_retrieve_deliversFailureOnRetrievalError() {
        // GIVEN
        let storeURL = testSpesificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        // WHEN
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        // THEN
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        // GIVEN
        let storeURL = testSpesificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        // WHEN
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        // THEN
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    
    /// Insert - To non-empty cache overrides previous value
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
        
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    /// Insert - Error (if possible to simulate, e.g., no write permission)
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
        expect(sut, toRetrieve: .empty)
    }
    
    // MARK: - Helper
    private func makeSUT(
        storeURL: URL? = nil,
        file: StaticString = #file, line: UInt = #line
    ) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ??  testSpesificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            // XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    private func expect(
        _ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCacheResults,
        file: StaticString = #file, line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                 (.failure, .failure):
                break
                
            case let (.found(expected), .found(retrieved)):
                XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
                XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(
        _ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCacheResults,
        file: StaticString = #file, line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpesificStoreURL())
    }
    
    private func testSpesificStoreURL() -> URL {
        FileManager.default.urls(
//             for: .documentDirectory,
            for: .cachesDirectory,
            in: .userDomainMask
        )
        .first!.appendingPathComponent("\(type(of: self)).store") /// dengan  type-of-self, kita mendapatkan nama store yg kita inginkan, yaitu sessuai dgn naming class.
        // .first!.appendingPathComponent("image-feed.store") /// ketika melakukan ini, ada potensi url kita digunakan di tempat lain padahal kita hanya menggunakannya untuk sepesifik kebutuhan test di `CodableFeedStoreTests`.
        // .first!.appendingPathComponent("CodableFeedStoreTests.store") /// membutanya seperti ini masih tidak relevan karena bisa saja nama class di refactor dan kita melwati proses pergantian nama.
    }
}

