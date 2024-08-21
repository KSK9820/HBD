//
//  LoginResponse.swift
//  HBD
//
//  Created by 김수경 on 8/18/24.
//

import Foundation

struct LoginResponse: Decodable {
    let userID: String
    let email: String
    let nick: String
    let profileImage: String?
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email, nick, profileImage, accessToken, refreshToken
    }
}

