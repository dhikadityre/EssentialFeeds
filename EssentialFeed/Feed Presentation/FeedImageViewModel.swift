//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 02/07/26.
//

public struct FeedImageViewModels<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        return location != nil
    }
}

