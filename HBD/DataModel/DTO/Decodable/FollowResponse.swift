//
//  FollowResponse.swift
//  HBD
//
//  Created by 김수경 on 8/21/24.
//

import Foundation

struct FollowUserResponse: Decodable {
    let nick: String
    let opponentNick: String
    let followingStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case nick
        case opponentNick = "opponent_nick"
        case followingStatus = "following_status"
    }
}
