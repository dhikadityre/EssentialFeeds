//
//  FeedUIComposer.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 26/06/26.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(
            forwardingTo: feedController,
            loader: imageLoader
        )
        return feedController
    }
    
    // [FeedImage] -> adapt -> [FeedImageCellController]
    private static func adaptFeedToCellControllers(
        forwardingTo controller: FeedViewController,
        loader: FeedImageDataLoader
    ) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                // FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: loader))
                FeedImageCellController(
                    viewModel: FeedImageViewModel(
                        model: model,
                        imageLoader: loader,
                        imageTransformer: UIImage.init
                    )
                )
            }
        }
    }
}
