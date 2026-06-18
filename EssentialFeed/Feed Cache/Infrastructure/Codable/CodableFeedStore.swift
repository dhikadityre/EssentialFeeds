//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 18/06/26.
//

import Foundation

public final class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ localFeedImage: LocalFeedImage) {
            self.id = localFeedImage.id
            self.description = localFeedImage.description
            self.location = localFeedImage.location
            self.url = localFeedImage.url
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(
                id: id,
                description: description,
                location: location,
                url: url
            )
        }
    }
    
    private let storeURL: URL
    private let queue = DispatchQueue(
        label: "\(CodableFeedStore.self) Queue",
        qos: .userInitiated,
        attributes: .concurrent
    )
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping (RetrieveCompletion)) {
        let storeURL = self.storeURL // Menyimpan copy of value storeURL
        queue.async {
            // guard let data = try? Data(contentsOf: self.storeURL) else {
            guard let data = try? Data(contentsOf: storeURL) else { // Melakukan passing value `storeURL` alih2 reference `self`
                return completion(.empty)
            }
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(
        _ feed: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertionCompletion
    ) {
        /*
         /// Menggunakan encoder dan menyelesaikan completion secara async
        DispatchQueue.global().async {
            let encoder = JSONEncoder()
            let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
            let encoded = try! encoder.encode(cache)
            try! encoded.write(to: self.storeURL)
            completion(nil)
        }
        */
         
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: self.storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
        // completion(nil)
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
