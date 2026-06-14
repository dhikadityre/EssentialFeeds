//
//  SharedTestHelpers.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 14/06/26.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any-error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
