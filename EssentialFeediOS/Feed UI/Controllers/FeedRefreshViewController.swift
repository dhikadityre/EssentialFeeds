//
//  FeedRefreshViewController.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 25/06/26.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    // private(set) lazy var view: UIRefreshControl = loadView()
    @IBOutlet private var view: UIRefreshControl?
    
    /*
    private let presenter: FeedPresenter
    
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
    */
    
    var delegate: FeedRefreshViewControllerDelegate?
    
    /*
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    */
    
    func display(viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
    
    /*
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    @objc func refresh() {
        // presenter.loadFeed()
        // loadFeed()
        delegate.didRequestFeedRefresh()
    }
    */
    
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
}
