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
    private let calendar = Calendar(identifier: .gregorian)
    
    public typealias SaveResult = Error?
    public typealias RetrieveResult = LoadFeedResult
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        /// Disini kita dapat menjalankan secara sync atau biarkan framework menjalankan secara async
        /// yang pasti adalah `deleteCachedFeed` harus dijalankan terlebih dahulu
        //// store.deleteCachedFeed()
        
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, completion: completion)
            }
        }
    }
    
    public func load(completion: @escaping (RetrieveResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            /// case .found(feed: let localFeedImage, timestamp: let timestamp):
                /// completion(.success(localFeedImage.toModels()))
            case let .found(feed, timestamp) where validate(timestamp):
                completion(.success(feed.toModels()))
            case .found:                
                store.deleteCachedFeed { _ in }
                completion(.success([]))
            case .empty:
                completion(.success([]))
            case .failure(let error):
                // store.deleteCachedFeed { _ in }
                completion(.failure(error))
            }
        }
    }
    
    public func validateCache() {
        store.retrieve { [unowned self] result in
            switch result {
            case .failure:
                store.deleteCachedFeed { _ in }
            default:
                break
            }
        }
    }
    
    private var maxCacheInDays: Int {
        return 7
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard
            let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheInDays, to: timestamp) // calendar dapet dari variable.
        else { return false }
        return currentDate() < maxCacheAge
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
