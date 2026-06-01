//
//  URLSessionHTTPClientTests.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 01/06/26.
//

import XCTest

// MARK: - Production Code
class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in
            
        }.resume() // tambahkan ini
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_resumDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let task = UrlSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    // MARK: - Helpers
    private class URLSessionSpy: URLSession {
        private var stubs = [URL: URLSessionDataTask]()
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? FakeUrlSessionDataTask()
        }
    }
    
    private class FakeUrlSessionDataTask: URLSessionDataTask {
        override func resume() {} // membuat override resume
    }
    
    private class UrlSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}
