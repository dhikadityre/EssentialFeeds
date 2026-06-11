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
    
    /// The Feed Store is a helper class representing the framework side
    /// to help us define the abstract interface the user use case needs for its collaborator,
    /// making sure not to leak framework details into the use case
    /// artinya: Feed Store ini digunakan sebagai contract yg dibutuhkan client tanpa perlu memikirkan akan menggunakan framework nantinya.
    private class FeedStoreSpy: FeedStore {
        // typealias DeletionCompletion = (Error?) -> Void
        // typealias InsertionCompletion = (Error?) -> Void
        
        // var deletedCachedFeedCallCount = 0
        // var insertCallCount = 0
        // var insertion = [(items: [FeedItem], timestamp: Date)]() // tupple untuk insert data
        
        private var deletionCompletion = [DeletionCompletion]()
        private var insertionCompletion = [InsertionCompletion]()
        
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert(feed: [LocalFeedImage], timestamp: Date)
        }
        
        private(set) var receivedMessage = [ReceivedMessage]()
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            // deletedCachedFeedCallCount += 1
            deletionCompletion.append(completion)
            receivedMessage.append(.deleteCachedFeed)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletion[index](error)
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletion[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletion[index](nil)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletion[index](nil)
        }
        
        func insert(
            _ items: [LocalFeedImage],
            timestamp: Date,
            completion: @escaping InsertionCompletion
        ) {
            // insertCallCount += 1
            // insertion.append((items, timestamp))
            receivedMessage.append(
                .insert(feed: items, timestamp: timestamp)
            )
            insertionCompletion.append(completion)
        }
    }
}
