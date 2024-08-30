//
//  PaymentQuery.swift
//  HBD
//
//  Created by 김수경 on 8/30/24.
//

import Foundation

struct PaymentQuery: Encodable {
    let impUID: String
    let postID: String
    
    enum CodingKeys: String, CodingKey {
        case impUID = "imp_uid"
        case postID = "post_id"
    }
}
