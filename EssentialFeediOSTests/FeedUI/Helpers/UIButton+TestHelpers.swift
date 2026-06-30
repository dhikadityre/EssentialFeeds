//
//  UIButton+TestHelpers.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 26/06/26.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
