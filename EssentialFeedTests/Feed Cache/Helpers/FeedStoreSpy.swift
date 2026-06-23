//
//  FeedStoreSpy.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 11/06/26.
//

import Foundation
import EssentialFeed

/// The Feed Store is a helper class representing the framework side
/// to help us define the abstract interface the user use case needs for its collaborator,
/// making sure not to leak framework details into the use case
/// artinya: Feed Store ini digunakan sebagai contract yg dibutuhkan client tanpa perlu memikirkan akan menggunakan framework nantinya.
class FeedStoreSpy: FeedStore {
    // typealias DeletionCompletion = (Error?) -> Void
    // typealias InsertionCompletion = (Error?) -> Void
    
    // var deletedCachedFeedCallCount = 0
    // var insertCallCount = 0
    // var insertion = [(items: [FeedItem], timestamp: Date)]() // tupple untuk insert data
    
    private var deletionCompletion = [DeletionCompletion]()
    private var insertionCompletion = [InsertionCompletion]()
    private var retrieveCompletion = [RetrieveCompletion]()
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert(feed: [LocalFeedImage], timestamp: Date)
        case retrieve
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
        _ items: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertionCompletion
    ) {
        // insertCallCount += 1
        // insertion.append((items, timestamp))
        receivedMessage.append(
            .insert(feed: items, timestamp: timestamp)
        )
        insertionCompletion.append(completion)
    }
    
    func retrieve(completion: @escaping (RetrieveCompletion)) {
        retrieveCompletion.append(completion)
        receivedMessage.append(.retrieve)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrieveCompletion[index](.failure(error))
    }
    
    func completeRetrieveWithEmptyCache(at index: Int = 0) {
        retrieveCompletion[index](.success(.none))
    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrieveCompletion[index](
            .success(CacheFeed(feed: feed, timestamp: timestamp))
        )
    }
}
