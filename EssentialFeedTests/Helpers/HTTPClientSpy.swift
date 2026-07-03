//
//  HTTPClientSpy.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 03/07/26.
//

import Foundation
import EssentialFeed

final class HTTPClientSpy: HTTPClient {
    private struct Task: HTTPClientTask {
        let callback: () -> Void
        func cancel() { callback() }
    }
    
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    private(set) var cancelledURLs = [URL]()
    
    var requestedURLs: [URL] {
        messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> EssentialFeed.HTTPClientTask {
        messages.append((url, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    // MARK: - Helper
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success((data, response)))
    }
}
