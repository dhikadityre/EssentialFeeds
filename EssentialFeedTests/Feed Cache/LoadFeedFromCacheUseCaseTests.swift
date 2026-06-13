//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 11/06/26.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        /// DRY is a good principle, but not every code that looks a like is duplicate.
        /// Before deleting duplication, investigate if it's just an accident duplication: code that seems the same but conceptually represents something else.
        ///
        /// Mixing diferent concepts makes it harder to reason about seperate parts of the system in isolation,
        /// incresing its complexity.
        ///
        /// This tase may look "duplicate" its not "accident duplication"
        ///
        /// Pada intinya kode ini terlihat duplicate karena memang tujuannya sama.
        /// Namun karena konteks tujuan use case atau bisnisnya berbeda antara "Save" dan "Load, dengan sengaja kita buat duplicatenya.
        /// Tujuannya jika ada kondisi yg perlu merubah kodenya, kita tahu dampaknya ke mana saja.
        /// Alih2 menggabungkannya di 1 file dan ketika error terjadi, kita bngung mengapa demkian.
        let (_, store) = makeSUT()
        
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    /// Memastikan Store me recieve message
    func test_load_requestCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    /// Memastikan Store meretrieve error saat load
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
        /*
        let exp = expectation(description: "Wait for load completion")
        var receivedError: Error?
        sut.load { result in
            switch result {
            case .failure(let error):
                receivedError = error
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }
        // trigger error
        store.completeRetrieval(with: retrievalError)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as? NSError, retrievalError)
         */
    }
    
    /// Memastikan sistem mendeliver Empty Cache - Delivers No Feed Images
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieveWithEmptyCache()
        })
        
        /*
        let exp = expectation(description: "Wait for load completion")
        
        var receivedImages: [FeedImage]?
        sut.load { result in
            switch result {
            case .success(let images):
                receivedImages = images
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        store.completeRetrieveWithEmptyCache()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedImages, [])
        */
    }
    
    /// system validate cache less then 7 days old.
    /// sistem memvalidasi cache jika kurang dari seminggu.
    func test_load_deliversCacheImagesOnLessThenSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenOldTimestamp = fixedCurrentDate
            .adding(days: -7)
            .adding(seconds: 1)
        
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(feed.models), when: {
            store.completeRetrieval(
                with: feed.local,
                timestamp: lessThanSevenOldTimestamp
            )
        })
    }
    
    /// system mendeliver no image saat cache sudah seminggu.
    func test_load_deliversNoImagesOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenOldTimestamp = fixedCurrentDate
            .adding(days: -7)
        
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(
                with: feed.local,
                timestamp: sevenOldTimestamp
            )
        })
    }
    
    /// system mendeliver no image saat cache lebih dari seminggu.
    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenOldTimestamp = fixedCurrentDate
            .adding(days: -7)
            .adding(seconds: -1)
        
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(
                with: feed.local,
                timestamp: sevenOldTimestamp
            )
        })
    }
    
    /// system melakukan delete cache ketika error terjadi
    func test_load_deleteCachesOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCachedFeed])
    }
    
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: LocalFeedLoader,
        store: FeedStoreSpy
    ) {
        let store = FeedStoreSpy()
        
        /// To decouple the application from framework details, we dont let frameworks dictate the usecase interface (ex: adding codable requirement, or core data managed context parameters).
        /// We do so by test-driving the interface the use case needs for its collaborator,
        /// rather then defining the interface upfront to facilitate a spesific framework implementation.
        let sut = LocalFeedLoader(
            store: store,
            currentDate: currentDate
        )
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(
        _ sut: LocalFeedLoader,
        toCompleteWith expectedResult: LocalFeedLoader.RetrieveResult,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImage), .success(expectedImage)):
                XCTAssertEqual(receivedImage, expectedImage)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        // trigger error / success
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any-error", code: 0)
    }
    
    private func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    private func uniqueImageFeed() -> (
        models: [FeedImage],
        local: [LocalFeedImage]
    ) {
        let items = [uniqueImage(), uniqueImage()]
        let localItems = items.map({
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        })
        return (items, localItems)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian)
            .date(
                byAdding: .day,
                value: days,
                to: self
            )!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
