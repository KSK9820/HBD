//
//  LikeQuery.swift
//  HBD
//
//  Created by 김수경 on 8/20/24.
//

import Foundation

struct LikeDTO: Codable {
    let likeStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case likeStatus = "like_status"
    }
}
