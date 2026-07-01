//
//  FeedPresenterTests.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 01/07/26.
//

import XCTest

final class FeedPresenter {
    init(view: Any) {
        
    }
}

class FeedPresenterTests: XCTestCase {
    /// Direkomendasikan untuk memulai dari `Degenerate`, `Behavior Trivial`, dan Simple.
    /// Di case ini, kita mensimplekan bahwa `FeedPresenter` tidak menjalankan apapun di `constructor`
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view Messages")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file, line: UInt = #line
    ) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
}
