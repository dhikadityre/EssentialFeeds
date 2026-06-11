//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 09/06/26.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {
    // func test_init_doesNotDeleteTheCacheUponCreation() {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        // XCTAssertEqual(store.deletedCachedFeedCallCount, 0)
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueImage(), uniqueImage()]
        
        sut.save(items) { _ in }
        
        // XCTAssertEqual(store.deletedCachedFeedCallCount, 1)
        XCTAssertEqual(store.receivedMessage, [.deleteCachedFeed])
    }
    
    /// tidak melakukan save cache ketika gagal mendelete
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueImage(), uniqueImage()]
        let error = anyNSError()
        
        sut.save(items) { _ in }
        store.completeDeletion(with: error)
        
        // XCTAssertEqual(store.deletedCachedFeedCallCount, 1)
        XCTAssertEqual(store.receivedMessage, [.deleteCachedFeed])
    }
    
    /*
    /// save cache setelah berhasil mendelete
    func test_save_requestNewCacheInsertionOnSuccessfullDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueImage(), uniqueImage()]
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.deletedCachedFeedCallCount, 1)
        XCTAssertEqual(store.insertCallCount, 1)
    }
    */
    
    /// save cache setelah berhasil mendelete + timestamp
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfullDeletion() {
        let timestamp = Date()
        let feed = uniqueImageFeed()
        
        /// The current data/time is not a pure function (every time we create a Date, it has a different value the current date/time)
        /// Instead letting the use case produce the current date via impure the `Date.init()` directly,
        /// we can move responsibility to a collaborator (a simple closure in this case),
        /// and inject it as a depedency.
        /// Then, we can `easily` control the current date/time during tests.
        let (sut, store) = makeSUT(currentDate: { timestamp } )
        
        sut.save(feed.models) { _ in }
        store.completeDeletionSuccessfully()
        
        // XCTAssertEqual(store.insertion.count, 1)
        // XCTAssertEqual(store.insertion.first?.items, items)
        // XCTAssertEqual(store.insertion.first?.timestamp, timestamp)
        XCTAssertEqual(
            store.receivedMessage, [
                .deleteCachedFeed,
                    .insert(
                        feed: feed.local,
                        timestamp: timestamp
                    )
            ]
        )
    }
    
    /// Kondisi Error pada saat melakukan `delete` data
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    /// Kondisi Error pada saat melakukan `insert` data
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    /// Kondisi sukses `delete`cache data dan sukses `save` cache
    func test_save_succeedsOnSucceesfullCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    /// Dalam proses menyimpan namun instance tidak di alocation kan.
    /// expect -> completion block tidak di trigger
    /// Delete
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDealocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedError = [Error?]()
        sut?.save(uniqueImageFeed().models) { error in
            receivedError.append(error)
        }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedError.isEmpty)
    }
    
    /// testing  completion insert dealocated
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDealocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedError = [Error?]()
        sut?.save(uniqueImageFeed().models) { error in
            receivedError.append(error)
        }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedError.isEmpty)
    }
    
    // MARK: - Helper
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: LocalFeedLoader,
        store: FeedStoreSpy
    ) {
        let store = FeedStoreSpy()
        
        /// To decouple the application from framework details, we dont let frameworks dictate the usecase interface (ex: adding codable requirement, or core data managed context parameters).
        /// We do so by test-driving the interface the use case needs for its collaborator,
        /// rather then defining the interface upfront to facilitate a spesific framework implementation.
        let sut = LocalFeedLoader(
            store: store,
            currentDate: currentDate
        )
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(
        _ sut: LocalFeedLoader,
        toCompleteWithError expectedError: NSError?,
        when action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let items = uniqueImageFeed().models
        
        let exp = expectation(description: "Wait for save completion")
        var receivedError: Error?
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as? NSError, expectedError, file: file, line: line)
    }
    
    private func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    private func uniqueImageFeed() -> (
        models: [FeedImage],
        local: [LocalFeedImage]
    ) {
        let items = [uniqueImage(), uniqueImage()]
        let localItems = items.map({
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        })
        return (items, localItems)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any-error", code: 0)
    }
}
