//
//  UITableView+Dequeueing.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 29/06/26.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
