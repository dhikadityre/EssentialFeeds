//
//  CodableFeedStoreTests.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 14/06/26.
//

import XCTest
import EssentialFeed

typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs

class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
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
        // expect(sut, toRetrieve: .empty)
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
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
        
        // expect(sut, toRetrieveTwice: .empty)
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    
    /// Insert - To empty cache works (to empty cache stores data)
    /// Retrieve - Empty cache twice returns empty (no side effects)
    // func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
    func test_retrieve_deliversFoundValueOnNonEmptyCache() {
        // GIVEN
        let sut = makeSUT()
        
        /*
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
        */
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    /// Non-empty cache twice returns same data (retrieve should have no side-effects)
    func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
        // GIVEN
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
        /*
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
        */
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
        // expect(sut, toRetrieve: .failure(anyNSError()))
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        // GIVEN
        let storeURL = testSpesificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        // WHEN
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        // THEN
        // expect(sut, toRetrieveTwice: .failure(anyNSError()))
        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }
    
    
    /*
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
     */
    
    /// Insert - Error (if possible to simulate, e.g., no write permission)
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        /*
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
        expect(sut, toRetrieve: .empty)
        */
        
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }
    
    /*
    /// Delete - Empty cache does nothing (cache stays empty and does not fail)
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        
        /*
         let exp = expectation(description: "Wait for cache deletion")
        sut.deleteCachedFeed { deletionError in
            XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        */
        
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
        expect(sut, toRetrieve: .empty)
    }
    */
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        /*
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .empty)
        */
        
        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    
    /*
    /// Delete-Inserted data leaves cache empty
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        
        /*
        let exp = expectation(description: "Wait for cache deletion")
        sut.deleteCachedFeed { deletionError in
            XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        */
        
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
        expect(sut, toRetrieve: .empty)
    }
    */
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.empty))
    }
    
    /// Delete-Error (if possible to simulate, e.g., no write permission)
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        /*
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
        // expect(sut, toRetrieve: .empty)
        */
        
        // assertThatDeleteDeliversErrorOnDeletionError(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        /*
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
        */
        // assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    ///Expect running in order or serially
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        // Run Side Effect Delete
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order")
    }
    
    // MARK: - Helper
    private func makeSUT(
        storeURL: URL? = nil,
        file: StaticString = #file, line: UInt = #line
    ) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ??  testSpesificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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
        /*
        FileManager.default.urls(
            // for: .documentDirectory,
            for: .cachesDirectory,
            in: .userDomainMask
        )
        .first!.appendingPathComponent("\(type(of: self)).store") /// dengan  type-of-self, kita mendapatkan nama store yg kita inginkan, yaitu sessuai dgn naming class.
        // .first!.appendingPathComponent("image-feed.store") /// ketika melakukan ini, ada potensi url kita digunakan di tempat lain padahal kita hanya menggunakannya untuk sepesifik kebutuhan test di `CodableFeedStoreTests`.
        // .first!.appendingPathComponent("CodableFeedStoreTests.store") /// membutanya seperti ini masih tidak relevan karena bisa saja nama class di refactor dan kita melwati proses pergantian nama.
        */
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}

