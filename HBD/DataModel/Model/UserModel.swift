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

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage
    }
}
