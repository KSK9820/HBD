//
//  FriendModelDTO.swift
//  HBD
//
//  Created by 김수경 on 8/20/24.
//

import Foundation

struct UserProfileResponse: Decodable {
    let userID: String
    let nick: String
    let profileImage: String?
    let followers: [Follow]
    let following: [Follow]
    let posts: [String]
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage, followers, following, posts
    }
}
