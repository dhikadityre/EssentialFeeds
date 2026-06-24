//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 24/06/26.
//

import UIKit
import EssentialFeed

final public class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    /// We use convenience init since we don't need any custom init. This way, we don't need to implement the UIViewController's required initialization
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

