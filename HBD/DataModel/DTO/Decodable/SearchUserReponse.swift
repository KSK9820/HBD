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
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick
        case profileImage
    }
}
