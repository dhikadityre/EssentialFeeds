//
//  UIRefreshControl+Helpers.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 01/07/26.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
