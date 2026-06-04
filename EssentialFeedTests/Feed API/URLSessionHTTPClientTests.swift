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
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValuesRepresentation: Error {} // All nil error
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performGETRequestWithURL() {
        let givenUrl = anyURL()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, givenUrl)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: givenUrl) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
    func test_getFromURL_failsOnRequestError() {
        let error = NSError(domain: "any error", code: 1)
        
        URLProtocolStub.stub(url: anyURL(), data: nil, response: nil, error: error) // penyesuaian berdasarkan table
        
        let exp = expectation(description: "Wait for completion")
        
        makeSUT().get(from: anyURL()) { result in
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
    }
    
    func test_getFromURL_failsOnAllNillValues() {
        URLProtocolStub.stub(url: anyURL(), data: nil, response: nil, error: nil) // penyesuaian berdasarkan table -> cek alll nil
        
        let exp = expectation(description: "Wait for completion")
        
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case .failure:
                break
            default:
                XCTFail("Expected failure with error")
            }
            exp.fulfill()
            
        }
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - Helpers
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private class URLProtocolStub: URLProtocol {
        // private static var stubs = [URL: Stub]()
        private static var stubs: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        // penyesuaian berdasarkan table
        static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
            /*
            stubs[url] = Stub(
                data: data,
                response: response,
                error: error
            )
            */
            stubs = Stub(
                data: data,
                response: response,
                error: error
            )
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            // stubs = [:]
            stubs = nil
            requestObserver = nil
        }
        
        // can init adalah method/function dari class. dan saat ini kita belum memiliki instance-nya.
        // URLLoadingSystem akan membuat instancenya hanya jika kita menghandle requestnya
        override class func canInit(with request: URLRequest) -> Bool {
            /*
            // true -> developer wajib menangani requestnya sendiri baik itu sukses atau gagal.
            guard let url = request.url else { return false }
            return URLProtocolStub.stubs[url] != nil // if ada url -> true
            */
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        // untuk loading url dan memulai sesuatu
        override func startLoading() {
            /*
            guard
                let url = request.url,
                let stub = URLProtocolStub.stubs[url]
            else { return }
            */
            
            if let data = URLProtocolStub.stubs?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stubs?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stubs?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
