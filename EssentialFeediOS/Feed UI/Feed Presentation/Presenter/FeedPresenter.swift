//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 27/06/26.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

struct FeedViewModels {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(viewModel: FeedViewModels)
}

struct FeedErrorViewModel {
    let message: String
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    static var title: String {
        return NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view"
        )
    }
    
    private var feedLoadError: String {
        return NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
             tableName: "Feed",
             bundle: Bundle(for: FeedPresenter.self),
             comment: "Error message displayed when we can't load the image feed from the server"
        )
    }
    
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView

    init(
        feedView: FeedView,
        loadingView: FeedLoadingView,
        errorView: FeedErrorView
    ) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: FeedViewModels(feed: feed))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
        
    func didFinishLoadingFeed(with error: Error) {
        errorView.display(FeedErrorViewModel(message: feedLoadError))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
