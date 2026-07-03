//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 03/07/26.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
