//
//  URLProtocolStub.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 03/07/26.
//

import Foundation

public class URLProtocolStub: URLProtocol {
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

    public static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error, requestObserver: nil)
    }

    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
    
    public static func observeRequest(observer: @escaping (URLRequest) -> Void) {
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
    public override class func canInit(with request: URLRequest) -> Bool {
        /*
        // true -> developer wajib menangani requestnya sendiri baik itu sukses atau gagal.
        guard let url = request.url else { return false }
        return URLProtocolStub.stubs[url] != nil // if ada url -> true
        */
        stub?.requestObserver?(request)
        return true
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    // untuk loading url dan memulai sesuatu
    public override func startLoading() {
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
    
    public override func stopLoading() {}
}
