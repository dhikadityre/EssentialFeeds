//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 14/06/26.
//

import Foundation

/// The `LocalFeedLoader` should encapsulate application spesific logic only, and communicate with models to perform business logic.
/// Rules and Policies (ex: validation logic) are better suited in a Domain Model that is Application Agnostic
/// So it can be reused accross application
internal final class FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    
    private init() {}
    
    private static var maxCacheInDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard
            let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheInDays, to: timestamp) // calendar dapet dari variable.
        else { return false }
        return date < maxCacheAge
    }
}
