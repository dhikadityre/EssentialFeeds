//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 09/06/26.
//

import XCTest

class LocalFeedLoader {
    init(store: FeedStore) {}
}

/// The Feed Store is a helper class representing the framework side
/// to help us define the abstract interface the user use case needs for its collaborator,
/// making sure not to leak framework details into the use case
/// artinya: Feed Store ini digunakan sebagai contract yg dibutuhkan client tanpa perlu memikirkan akan menggunakan framework nantinya.
class FeedStore {
    var deletedCachedFeedCallCount = 0
}

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteTheCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deletedCachedFeedCallCount, 0)
    }
}
