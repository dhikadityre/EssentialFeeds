//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 10/06/26.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        /// Disini kita dapat menjalankan secara sync atau biarkan framework menjalankan secara async
        /// yang pasti adalah `deleteCachedFeed` harus dijalankan terlebih dahulu
        //// store.deleteCachedFeed()
        
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, completion: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.insert(
            items,
            timestamp: currentDate(),
            completion: { [weak self] error in
                guard self != nil else { return }
                completion(error)
            }
        )
    }
}
