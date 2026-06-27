//
//  FeedRefreshViewController.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 25/06/26.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private(set) lazy var view: UIRefreshControl = loadView()
    
    private let presenter: FeedPresenter
    
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
    
    func display(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    @objc func refresh() { presenter.loadFeed() }
}
