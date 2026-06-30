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

        // let feedController = FeedViewController.makeWith(
        let feedController = makeFeedViewController(
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
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}

/*
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
*/
