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
    // private let cachePolicy: FeedCachePolicy = FeedCachePolicy()
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        /// Disini kita dapat menjalankan secara sync atau biarkan framework menjalankan secara async
        /// yang pasti adalah `deleteCachedFeed` harus dijalankan terlebih dahulu
        //// store.deleteCachedFeed()
        
        /*
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, completion: completion)
            }
        }
        */
        
        store.deleteCachedFeed { [weak self] deletionResult in
            switch deletionResult {
            case .success:
                self?.cache(feed, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(
            feed.toLocal(),
            timestamp: currentDate(),
            completion: { [weak self] error in
                guard self != nil else { return }
                completion(error)
            }
        )
    }
}
   
extension LocalFeedLoader: FeedLoader {
    public typealias RetrieveResult = FeedLoader.Result
    
    public func load(completion: @escaping (RetrieveResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
                /// case .found(feed: let localFeedImage, timestamp: let timestamp):
                /// completion(.success(localFeedImage.toModels()))
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: currentDate()):
                  completion(.success(cache.feed.toModels()))
                /*
                 case .found:
                 // store.deleteCachedFeed { _ in }
                 completion(.success([]))
                 case .empty:
                 completion(.success([]))
                 */
            case .success:
                completion(.success([]))
            case .failure(let error):
                // store.deleteCachedFeed { _ in }
                completion(.failure(error))
            }
        }
    }
}
 
extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    
    public func validateCache(
        completion: @escaping (ValidationResult) -> Void
    ) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                store.deleteCachedFeed(completion: completion)
            
            /// Jika retrieve berhasil menemukan cache, tetapi timestamp-nya `tidak lagi` valid (sudah lebih dari 7 hari), hapus cache tersebut dari store.
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: currentDate()):
                store.deleteCachedFeed(completion: completion)
            
            /// kenapa tidak membuat `default`? ini untuk menjaga kualitas unit test dan mengingatkan kita jika sebuah case gagal akan kesini alih2 membuatnya default.
            case .success(.none), .success:
                completion(.success(()))
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map {
            LocalFeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
            )
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map {
            FeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
            )
        }
    }
}
