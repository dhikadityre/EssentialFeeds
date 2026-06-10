//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 09/06/26.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        /// Disini kita dapat menjalankan secara sync atau biarkan framework menjalankan secara async
        /// yang pasti adalah `deleteCachedFeed` harus dijalankan terlebih dahulu
        //// store.deleteCachedFeed()
        
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            if error == nil {
                store.insert(
                    items,
                    timestamp: self.currentDate(),
                    completion: completion
                )
            } else {
                completion(error)
            }
        }
    }
}

// Extract to Production Code
protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(
        _ items: [FeedItem],
        timestamp: Date,
        completion: @escaping InsertionCompletion
    )
}

final class CacheFeedUseCaseTests: XCTestCase {
    // func test_init_doesNotDeleteTheCacheUponCreation() {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        // XCTAssertEqual(store.deletedCachedFeedCallCount, 0)
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items) { _ in }
        
        // XCTAssertEqual(store.deletedCachedFeedCallCount, 1)
        XCTAssertEqual(store.receivedMessage, [.deleteCachedFeed])
    }
    
    /// tidak melakukan save cache ketika gagal mendelete
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
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
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.deletedCachedFeedCallCount, 1)
        XCTAssertEqual(store.insertCallCount, 1)
    }
    */
    
    /// save cache setelah berhasil mendelete + timestamp
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfullDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        
        /// The current data/time is not a pure function (every time we create a Date, it has a different value the current date/time)
        /// Instead letting the use case produce the current date via impure the `Date.init()` directly,
        /// we can move responsibility to a collaborator (a simple closure in this case),
        /// and inject it as a depedency.
        /// Then, we can `easily` control the current date/time during tests.
        let (sut, store) = makeSUT(currentDate: { timestamp } )
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        
        // XCTAssertEqual(store.insertion.count, 1)
        // XCTAssertEqual(store.insertion.first?.items, items)
        // XCTAssertEqual(store.insertion.first?.timestamp, timestamp)
        XCTAssertEqual(
            store.receivedMessage, [
                .deleteCachedFeed,
                    .insert(
                        items: items,
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
        sut?.save([uniqueItem()]) { error in
            receivedError.append(error)
        }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
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
        let items = [uniqueItem(), uniqueItem()]
        
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
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any-error", code: 0)
    }
    
    /// The Feed Store is a helper class representing the framework side
    /// to help us define the abstract interface the user use case needs for its collaborator,
    /// making sure not to leak framework details into the use case
    /// artinya: Feed Store ini digunakan sebagai contract yg dibutuhkan client tanpa perlu memikirkan akan menggunakan framework nantinya.
    private class FeedStoreSpy: FeedStore {
        // typealias DeletionCompletion = (Error?) -> Void
        // typealias InsertionCompletion = (Error?) -> Void
        
        // var deletedCachedFeedCallCount = 0
        // var insertCallCount = 0
        // var insertion = [(items: [FeedItem], timestamp: Date)]() // tupple untuk insert data
        
        private var deletionCompletion = [DeletionCompletion]()
        private var insertionCompletion = [InsertionCompletion]()
        
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert(items: [FeedItem], timestamp: Date)
        }
        
        private(set) var receivedMessage = [ReceivedMessage]()
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            // deletedCachedFeedCallCount += 1
            deletionCompletion.append(completion)
            receivedMessage.append(.deleteCachedFeed)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletion[index](error)
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletion[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletion[index](nil)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletion[index](nil)
        }
        
        func insert(
            _ items: [FeedItem],
            timestamp: Date,
            completion: @escaping InsertionCompletion
        ) {
            // insertCallCount += 1
            // insertion.append((items, timestamp))
            receivedMessage.append(
                .insert(items: items, timestamp: timestamp)
            )
            insertionCompletion.append(completion)
        }
    }
}
