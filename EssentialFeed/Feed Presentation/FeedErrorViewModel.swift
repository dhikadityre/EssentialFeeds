//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 02/07/26.
//

public struct FeedErrorViewModel {
    public let message: String?
    
    public static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    public static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
