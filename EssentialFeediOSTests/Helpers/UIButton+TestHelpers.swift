//
//  UIButton+TestHelpers.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 26/06/26.
//

import UIKit

private extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
