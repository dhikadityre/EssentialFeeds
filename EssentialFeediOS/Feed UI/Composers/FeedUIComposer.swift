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
        // presenter -> feed loader
        // refresh controller -> presenter -> // refresh controller -> presenter -> feed loader
        // feed controller -> refresh controller -> //feed controller -> refresh controller -> (presenter -> refresh controller) (presenter -> feed view) -> feed loader
        let presenter = FeedPresenter(feedLoader: feedLoader)
        
        // let refreshController = FeedRefreshViewController(presenter: presenter)
        let refreshController = FeedRefreshViewController(loadFeed: {
            presenter.loadFeed()
        })
        let feedController = FeedViewController(refreshController: refreshController)
        
        presenter.feedView = FeedViewAdapter(
            controller: feedController,
            imageLoader: imageLoader
        )
        presenter.loadingView = WeakRefVirtualProxy(refreshController)
        return feedController
    }
    
    /*
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
    */
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel) {
        object?.display(
            viewModel: FeedLoadingViewModel(
                isLoading: viewModel.isLoading
            )
        )
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(viewModel: FeedViewModels) {
        controller?.tableModel = viewModel.feed.map { model in
            FeedImageCellController(viewModel:
                FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
        }
    }
}
