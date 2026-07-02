//
//  FeedPresenterTests.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 01/07/26.
//

import XCTest

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}


protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private let errorView: FeedErrorView
    
    init(errorView: FeedErrorView) {
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
    }
}

class FeedPresenterTests: XCTestCase {
    /// Direkomendasikan untuk memulai dari `Degenerate`, `Behavior Trivial`, dan Simple.
    /// Di case ini, kita mensimplekan bahwa `FeedPresenter` tidak menjalankan apapun di `constructor`
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        _ = FeedPresenter(errorView: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view Messages")
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessage() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file, line: UInt = #line
    ) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedErrorView {
        enum Message: Equatable {
            case display(errorMessage: String?)
        }
        
        private(set) var messages = [Message]()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}
