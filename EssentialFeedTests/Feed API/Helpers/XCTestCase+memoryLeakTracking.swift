//
//  XCTestCase+memoryLeakTracking.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 04/06/26.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance,
                "Instance should have been dealocated. Potential memory leak.",
                file: file,
                line: line
            )
        }
    }
}
