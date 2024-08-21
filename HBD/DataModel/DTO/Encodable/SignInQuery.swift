//
//  SingInQuery.swift
//  HBD
//
//  Created by 김수경 on 8/18/24.
//

import Foundation

struct SignInQuery: Encodable {
    let email: String
    let password: String
    let nick: String
    let birthDay: String
    let phoneNumber: String?
    let profile: Data?
    
    init(email: String, password: String, nick: String, birthDay: String, phoneNumber: String? = nil, profile: Data? = nil) {
        self.email = email
        self.password = password
        self.nick = nick
        self.birthDay = birthDay
        self.phoneNumber = phoneNumber
        self.profile = profile
    }
    
}
