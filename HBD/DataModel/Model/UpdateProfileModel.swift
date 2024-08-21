//
//  UpdateProfileModel.swift
//  HBD
//
//  Created by 김수경 on 8/19/24.
//

import Foundation

struct UpdateProfileModel: Encodable {
    let nick: String?
    let phoneNum: String?
    let profile: Data?
    
    init(nick: String? = nil, phoneNum: String? = nil, profile: Data? = nil) {
        self.nick = nick
        self.phoneNum = phoneNum
        self.profile = profile
    }
}
