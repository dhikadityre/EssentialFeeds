//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

// contract
/*
public enum LoadFeedResult {
	case success([FeedImage])
	case failure(Error)
}
*/
// public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}
