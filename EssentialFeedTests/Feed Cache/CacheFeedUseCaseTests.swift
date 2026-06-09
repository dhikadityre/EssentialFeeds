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
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

/// The Feed Store is a helper class representing the framework side
/// to help us define the abstract interface the user use case needs for its collaborator,
/// making sure not to leak framework details into the use case
/// artinya: Feed Store ini digunakan sebagai contract yg dibutuhkan client tanpa perlu memikirkan akan menggunakan framework nantinya.
class FeedStore {
    var deletedCachedFeedCallCount = 0
    
    func deleteCachedFeed() {
        deletedCachedFeedCallCount += 1
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteTheCacheUponCreation() {
        let store = FeedStore()
        /// To decouple the application from framework details, we dont let frameworks dictate the usecase interface (ex: adding codable requirement, or core data managed context parameters).
        /// We do so by test-driving the interface the use case needs for its collaborator,
        /// rather then defining the interface upfront to facilitate a spesific framework implementation.
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deletedCachedFeedCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deletedCachedFeedCallCount, 1)
    }
    
    // MARK: - Helper
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}
