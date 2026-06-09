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
    
    func save(_ items: [FeedItem]) {
        /// Disini kita dapat menjalankan secara sync atau biarkan framework menjalankan secara async
        /// yang pasti adalah `deleteCachedFeed` harus dijalankan terlebih dahulu
        //// store.deleteCachedFeed()
        
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

/// The Feed Store is a helper class representing the framework side
/// to help us define the abstract interface the user use case needs for its collaborator,
/// making sure not to leak framework details into the use case
/// artinya: Feed Store ini digunakan sebagai contract yg dibutuhkan client tanpa perlu memikirkan akan menggunakan framework nantinya.
class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    // var deletedCachedFeedCallCount = 0
    // var insertCallCount = 0
    // var insertion = [(items: [FeedItem], timestamp: Date)]() // tupple untuk insert data
    
    private var deletionCompletion = [DeletionCompletion]()
    
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
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletion[index](nil)
    }
    
    func insert(_ items: [FeedItem], timestamp: Date) {
        // insertCallCount += 1
        // insertion.append((items, timestamp))
        receivedMessage.append(
            .insert(items: items, timestamp: timestamp)
        )
    }
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
        
        sut.save(items)
        
        // XCTAssertEqual(store.deletedCachedFeedCallCount, 1)
        XCTAssertEqual(store.receivedMessage, [.deleteCachedFeed])
    }
    
    /// tidak melakukan save cache ketika gagal mendelete
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let error = anyNSError()
        
        sut.save(items)
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
        
        sut.save(items)
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
    
    // MARK: - Helper
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: LocalFeedLoader,
        store: FeedStore
    ) {
        let store = FeedStore()
        
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
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any-error", code: 0)
    }
}
