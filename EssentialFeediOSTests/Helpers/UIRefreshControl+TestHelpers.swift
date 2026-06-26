//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 26/06/26.
//

import UIKit

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
