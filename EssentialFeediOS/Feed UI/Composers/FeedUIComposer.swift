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
        // let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let presentationAdapter = FeedLoaderPresentationAdapter(
            feedLoader: MainQueueDispatchDecorator(
                decoratee: feedLoader
            )
        )

        let feedController = FeedViewController.makeWith(
            delegate: presentationAdapter,
            title: FeedPresenter.title
        )
        
        let feedView = FeedViewAdapter(
            controller: feedController,
            // imageLoader: imageLoader
            imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)
        )
        let presenter = FeedPresenter(
            feedView: feedView,
            // loadingView: WeakRefVirtualProxy(refreshController!)
            loadingView: WeakRefVirtualProxy(feedController)
        )
        
        
        presentationAdapter.presenter = presenter
        return feedController
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
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
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init
            )
            
            return view
        }
    }
}

// private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModels<UIImage>) {
        object?.display(model)
    }
}
