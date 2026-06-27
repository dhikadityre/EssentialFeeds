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
    // let currentDate: Date // akan lebih mudah perubahan jika kita buat struct
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

final class FeedPresenter {
    /*
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    */
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    /*
    func loadFeed() {
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: true))
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(viewModel: FeedViewModels(feed: feed))
            }
        }
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    */
    
    func didStartLoadingFeed() {
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView?.display(viewModel: FeedViewModels(feed: feed))
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
        
    func didFinishLoadingFeed(with error: Error) {
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
