//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 10/06/26.
//

import Foundation

/*
public enum RetrieveCacheResults {
    case success(CacheFeed)
    case failure(Error)
}
*/

// typealias RetrieveCacheFeedResults = Result<CacheFeed, Error>

/*
public enum CacheFeed {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
}
*/

/*
public struct CacheFeed {
    public let feed: [LocalFeedImage]
    public let timestamp: Date
    
    public init(feed: [LocalFeedImage], timestamp: Date) {
        self.feed = feed
        self.timestamp = timestamp
    }
}
*/

public typealias CacheFeed = (feed: [LocalFeedImage], timestamp: Date)


public protocol FeedStore {
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrievalResult =  Result<CacheFeed?, Error> // Merubah `CacheFeed` jadi optional
    typealias RetrieveCompletion = (RetrievalResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(
        _ feed: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertionCompletion
    )
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping (RetrieveCompletion))
}
