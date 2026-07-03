//
//  URLSessionHTTPClientTests.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 01/06/26.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    /*
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    */
    
    override func tearDown() {
        super.tearDown()
        // URLProtocolStub.stopInterceptingRequest()
        URLProtocolStub.removeStub()
    }
    
    func test_getFromURL_performGETRequestWithURL() {
        let givenUrl = anyURL()
        
        var receivedRequest = [URLRequest]()
        URLProtocolStub.observeRequest { request in
            receivedRequest.append(request)
        }
        
        let exp = expectation(description: "Wait for request completion")
        makeSUT().get(from: givenUrl) { _ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedRequest.count, 1)
        XCTAssertEqual(receivedRequest.first?.url, givenUrl)
        XCTAssertEqual(receivedRequest.first?.httpMethod, "GET")
    }
    
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = NSError(domain: "any error", code: 1)
        
        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError))
        
//        XCTAssertEqual(resultError?.domain, requestError.domain)
//        XCTAssertEqual(resultError?.code, requestError.code)
        XCTAssertEqual((receivedError as NSError?)?.domain, requestError.domain)
        XCTAssertEqual((receivedError as NSError?)?.code, requestError.code)
        
        /*
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
        */
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        /*
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        // XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
        */
        
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
        
        /*
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
        */
        
    }
    
    func test_getFromURL_suceedsOnHTTPURLResponseWithData() {
        let anyData = anyData()
        let anyHTTPURLResponse = anyHTTPURLResponse()
        
        /*
        URLProtocolStub.stub(
            url: anyURL(),
            data: anyData,
            response: anyHTTPURLResponse,
            error: nil
        )
         */
        
        let result = resultValues((data: anyData, response: anyHTTPURLResponse, error: nil))
        XCTAssertEqual(result?.data, anyData)
        XCTAssertEqual(result?.httpUrlResponse.url, anyHTTPURLResponse.url)
        XCTAssertEqual(result?.httpUrlResponse.statusCode, anyHTTPURLResponse.statusCode)
        /*
        let exp = expectation(description: "wait for completion")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .success(data, httpUrlResponse):
                XCTAssertEqual(data, anyData)
                XCTAssertEqual(httpUrlResponse.url, anyHTTPURLResponse.url)
                XCTAssertEqual(httpUrlResponse.statusCode, anyHTTPURLResponse.statusCode)
            default:
                XCTFail("Expected success, got \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
         */
    }
    
    func test_getFromURL_suceedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let anyHTTPURLResponse = anyHTTPURLResponse()
        
        // let result = resultValues(data: nil, response: anyHTTPURLResponse, error: nil)
        let result = resultValues((data: nil, response: anyHTTPURLResponse, error: nil))
        let emptyData = Data()
        
        XCTAssertEqual(result?.data, emptyData)
        XCTAssertEqual(result?.httpUrlResponse.url, anyHTTPURLResponse.url)
        XCTAssertEqual(result?.httpUrlResponse.statusCode, anyHTTPURLResponse.statusCode)
        
        /*
        URLProtocolStub.stub(
            url: anyURL(),
            data: nil,
            response: anyHTTPURLResponse,
            error: nil
        )
        
        let exp = expectation(description: "wait for completion")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .success(data, httpUrlResponse):
                let emptyData = Data()
                
                XCTAssertEqual(data, emptyData)
                XCTAssertEqual(httpUrlResponse.url, anyHTTPURLResponse.url)
                XCTAssertEqual(httpUrlResponse.statusCode, anyHTTPURLResponse.statusCode)
            default:
                XCTFail("Expected success, got \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        */
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        /*
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        
        let task = makeSUT().get(from: url) { result in
            switch result {
            case let .failure(error as NSError) where error.code == URLError.cancelled.rawValue:
                break
            
            default:
                XCTFail("Expected cancelled result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        task.cancel()
        wait(for: [exp], timeout: 1.0)
        */
        
        let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?

        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
    // MARK: - Helpers
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> HTTPClient {
        // let sut = URLSessionHTTPClient()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyData() -> Data {
        Data("any-data".utf8)
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(
            url: anyURL(),
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(
            url: anyURL(),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    private func resultErrorFor(
        // data: Data?, response: URLResponse?, error: Error?,
        _ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in },
        file: StaticString = #file, line: UInt = #line
    ) -> Error? {
        /*
        URLProtocolStub.stub(url: anyURL(), data: data, response: response, error: error) // penyesuaian berdasarkan table
        
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receivedError: Error?
        sut.get(from: anyURL()) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
            
        }
        wait(for: [exp], timeout: 2)
        return receivedError
        */
        
        /*
        let result = resultFor(
            data: data, response: response, error: error,
            file: file, line: line
        )
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure with error \(error), got \(result) instead", file: file, line: line)
            return nil
        }
        */
        
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultValues(
        _ values: (data: Data?, response: URLResponse?, error: Error?)?,
        file: StaticString = #file, line: UInt = #line
    ) -> (data: Data, httpUrlResponse: HTTPURLResponse)? {
        /*
        URLProtocolStub.stub(url: anyURL(), data: data, response: response, error: error) // penyesuaian berdasarkan table
        
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receiveResult: (data: Data, httpUrlResponse: HTTPURLResponse)?
        sut.get(from: anyURL()) { result in
            switch result {
            case let .success(data, httpURLResponse):
                receiveResult = (data, httpURLResponse)
            default:
                XCTFail("Expected success, got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
            
        }
        wait(for: [exp], timeout: 2)
        return receiveResult
        */
        
        /*
        let result = resultFor(
            data: data, response: response, error: error,
            file: file, line: line
        )
        */
        let result = resultFor(values, file: file, line: line)
        switch result {
        case let .success(data, httpUrlResponse):
            return (data, httpUrlResponse)
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(
        // data: Data?, response: URLResponse?, error: Error?,
        _ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in },
        file: StaticString = #file, line: UInt = #line
    ) -> HTTPClient.Result? {
        // URLProtocolStub.stub(url: anyURL(), data: data, response: response, error: error) // penyesuaian berdasarkan table
        values.map { URLProtocolStub.stub(data: $0.data, response: $0.response, error: $0.error) }
        
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receiveResult: HTTPClient.Result?
        /*
        sut.get(from: anyURL()) { result in
            receiveResult = result
            exp.fulfill()
        }
        */
        taskHandler(sut.get(from: anyURL()) { result in
            receiveResult = result
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1)
        return receiveResult
    }
    
    private class URLProtocolStub: URLProtocol {
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
            let requestObserver: ((URLRequest) -> Void)?
        }
        
        private static var _stub: Stub?
        private static var stub: Stub? {
            get { return queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }

        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error, requestObserver: nil)
        }

        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
        }
        
        /*
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
        }
        */
        
        static func removeStub() {
            stub = nil
        }
        
        // can init adalah method/function dari class. dan saat ini kita belum memiliki instance-nya.
        // URLLoadingSystem akan membuat instancenya hanya jika kita menghandle requestnya
        override class func canInit(with request: URLRequest) -> Bool {
            /*
            // true -> developer wajib menangani requestnya sendiri baik itu sukses atau gagal.
            guard let url = request.url else { return false }
            return URLProtocolStub.stubs[url] != nil // if ada url -> true
            */
            stub?.requestObserver?(request)
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
            
            guard let stub = URLProtocolStub.stub else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
