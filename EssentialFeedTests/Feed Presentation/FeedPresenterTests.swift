//
//  FeedPresenterTests.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 01/07/26.
//

import XCTest
import EssentialFeed

struct FeedViewModels {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(viewModel: FeedViewModels)
}

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel { // copas
        return FeedErrorViewModel(message: message)
    }
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    init(
        feedView: FeedView,
        loadingView: FeedLoadingView,
        errorView: FeedErrorView
    ) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    static var title: String {
        return NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view"
        )
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }

    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: FeedViewModels(feed: feed))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}

class FeedPresenterTests: XCTestCase {
    /// Direkomendasikan untuk memulai dari `Degenerate`, `Behavior Trivial`, dan Simple.
    /// Di case ini, kita mensimplekan bahwa `FeedPresenter` tidak menjalankan apapun di `constructor`
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        _ = FeedPresenter(
            feedView: view,
            loadingView: view,
            errorView: view
        )
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view Messages")
    }
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessageAndStartLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(
            view.messages, [
                .display(errorMessage: .none),
                .display(isLoading: true)
            ]
        )
    }
    
    func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
        let (sut, view) = makeSUT()
        let feed = uniqueImageFeed().models
        
        sut.didFinishLoadingFeed(with: feed)
        
        XCTAssertEqual(view.messages, [
            .display(feed: feed),
            .display(isLoading: false)
        ])
    }
    
    func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
            .display(isLoading: false)
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file, line: UInt = #line
    ) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(
            feedView: view,
            loadingView: view,
            errorView: view
        )
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self) // !!! Menggunakan Bundle yang sama dengan `FeedPresenter`
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
    
    private class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(viewModel: FeedViewModels) {
            messages.insert(.display(feed: viewModel.feed))
        }
    }
}
