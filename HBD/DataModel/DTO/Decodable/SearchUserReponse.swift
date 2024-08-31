//
//  SearchUserReponse.swift
//  HBD
//
//  Created by 김수경 on 8/21/24.
//

import Foundation

struct SearchUserReponse: Decodable {
    let data: [SearchUser]
}

struct SearchUser: Decodable {
    let userID: String
    let nick: String
    let profileImage: String?
    let birthDay: String?
    var isFollowing: Bool
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick
        case profileImage
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
        let input = try container.decode(String.self, forKey: .nick)
        let components = input.split(separator: "_")
        self.nick = String(components[0])
        self.birthDay = components.count > 1 ? String(components[1]) : ""
        self.isFollowing = false
    }
    
    init(userID: String, nick: String, profileImage: String?, birthDay: String?, isFollowing: Bool) {
        self.userID = userID
        self.nick = nick
        self.profileImage = profileImage
        self.birthDay = birthDay
        self.isFollowing = isFollowing
    }
    
    
    func converToFollow() -> Follow {
        return Follow(userID: userID, nick: nick, profileImage: profileImage)
    }
}
