//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 01/07/26.
//

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
