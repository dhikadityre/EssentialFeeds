//
//  FeedImageDataStore.swift.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 05/07/26.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
