//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 10/06/26.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(
        _ items: [FeedItem],
        timestamp: Date,
        completion: @escaping InsertionCompletion
    )
}
