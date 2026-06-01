//
//  URLSessionHTTPClientTests.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 01/06/26.
//

import XCTest
import EssentialFeed

// MARK: - Production Code
class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) { // karena kita tidak perlu melakukan mocking pada URLSession, kia bisa gunakan default value `.shared`
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume() // tambahkan ini
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequest()
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        
        URLProtocolStub.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                // XCTAssertEqual(receivedError, error)
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
            
        }
        wait(for: [exp], timeout: 2)
        URLProtocolStub.stopInterceptingRequest()
    }
    
    // MARK: - Helpers
    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        // can init adalah method/function dari class. dan saat ini kita belum memiliki instance-nya.
        // URLLoadingSystem akan membuat instancenya hanya jika kita menghandle requestnya
        override class func canInit(with request: URLRequest) -> Bool {
            // true -> developer wajib menangani requestnya sendiri baik itu sukses atau gagal.
            guard let url = request.url else { return false }
            return URLProtocolStub.stubs[url] != nil // if ada url -> true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        // untuk loading url dan memulai sesuatu
        override func startLoading() {
            guard
                let url = request.url,
                let stub = URLProtocolStub.stubs[url]
            else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
