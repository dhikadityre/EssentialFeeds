//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 28/01/25.
//

import Foundation

internal final class FeedItemMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL // ubah menjadi `image` seusai response json
    }
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard
            response.statusCode == OK_200,
            let root = try? JSONDecoder().decode(Root.self, from: data)
        else { throw RemoteFeedLoader.Error.invalidData } // menambahkan `RemoteFeedLoader.Error`
        // let items = root.items.map { $0.item }
        // return .success(items)
        return root.items
    }
}
