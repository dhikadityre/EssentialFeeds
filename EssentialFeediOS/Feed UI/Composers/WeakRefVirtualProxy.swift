//
//  WeakRefVirtualProxy.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 30/06/26.
//

import UIKit
import EssentialFeed

final class WeakRefVirtualProxy<T: AnyObject> {
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

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModels<UIImage>) {
        object?.display(model)
    }
}
