//
//  FeedStoreSpecs.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 17/06/26.
//

import Foundation

internal protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()

    func test_retrieve_hasNoSideEffectOnEmptyCache()

    /// Insert - To empty cache works (to empty cache stores data)
    /// Retrieve - Empty cache twice returns empty (no side effects)
    func test_retrieve_deliversFoundValueOnNonEmptyCache()

    /*
    /// Non-empty cache twice returns same data (retrieve should have no side-effects)
    func test_retrieve_hasNoSideEffectOnNonEmptyCache()
    */

    /*
    /// Retrieve - Error (if possible to simulate, e.g., invalid data)
    /// To Retrive an Error, we can just add some `invalid data` to the `storeURL` then try to `retrieve` our `models`.
    func test_retrieve_deliversFailureOnRetrievalError()
    */

    func test_retrieve_hasNoSideEffectsOnFailure()

    /*
    /// Insert - Error (if possible to simulate, e.g., no write permission)
    func test_insert_deliversErrorOnInsertionError()

    /// Tadinya digabung
    func test_insert_hasNoSideEffectsOnInsertionError()
    */
    
    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPreviouslyInsertedCacheValues()
    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_hasNoSideEffectsOnEmptyCache()

    func test_delete_deliversNoErrorOnNonEmptyCache()

    func test_delete_emptiesPreviouslyInsertedCache()

    /*
    /// Delete-Error (if possible to simulate, e.g., no write permission)
    func test_delete_deliversErrorOnDeletionError()

    /// Tadinya digabung
    func test_delete_hasNoSideEffectsOnDeletionError()
    */

    ///Expect running in order or serially
    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    /// Retrieve - Error (if possible to simulate, e.g., invalid data)
    /// To Retrive an Error, we can just add some `invalid data` to the `storeURL` then try to `retrieve` our `models`.
    func test_retrieve_deliversFailureOnRetrievalError()
    
    /// Non-empty cache twice returns same data (retrieve should have no side-effects)
    func test_retrieve_hasNoSideEffectOnNonEmptyCache()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    /// Insert - Error (if possible to simulate, e.g., no write permission)
    func test_insert_deliversErrorOnInsertionError()

    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    /// Delete-Error (if possible to simulate, e.g., no write permission)
    func test_delete_deliversErrorOnDeletionError()

    func test_delete_hasNoSideEffectsOnDeletionError()
}
