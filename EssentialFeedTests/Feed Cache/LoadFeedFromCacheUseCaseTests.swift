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
        
        sut.load()
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
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
}
