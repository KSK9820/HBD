//
//  PostsResponse.swift
//  HBD
//
//  Created by 김수경 on 8/20/24.
//

import Foundation

struct PostsResponse: Decodable {
    let data: [PostResponse]
    let nextCursor: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}
