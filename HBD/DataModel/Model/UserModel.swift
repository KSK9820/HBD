//
//  UserModel.swift
//  HBD
//
//  Created by 김수경 on 8/19/24.
//

import Foundation

struct UserModel: Decodable {
    let userID: String
    let email: String
    let nick: String
    let phoneNum: String?
    let birthDay: String
    let profileImage: String?
    let followers: [Follow]
    let following: [Follow]
    let posts: [String]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email, nick, phoneNum, birthDay, profileImage, followers, following, posts
    }
    
}

struct Follow: Decodable {
    let userID: String
    let nick: String
    let profileImage: String?
    let birthDay: String?
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
        let input = try container.decode(String.self, forKey: .nick)
        let components = input.split(separator: "_")
        self.nick = String(components[0])
        self.birthDay = String(components[1])
    }
    
    init(userID: String, nick: String, profileImage: String?) {
        self.userID = userID
        self.profileImage = profileImage
        let input = nick.split(separator: "_").map { String($0) }
        self.nick = input[0]
        self.birthDay = input.count > 1 ? input[1] : nil
    }
    
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage, birthDay
    }
}
