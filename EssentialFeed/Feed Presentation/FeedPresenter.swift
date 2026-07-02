//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 02/07/26.
//

import Foundation

public protocol FeedView {
    func display(viewModel: FeedViewModels)
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

public final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    public init(
        feedView: FeedView,
        loadingView: FeedLoadingView,
        errorView: FeedErrorView
    ) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public static var title: String {
        return NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view"
        )
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }

    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: FeedViewModels(feed: feed))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
