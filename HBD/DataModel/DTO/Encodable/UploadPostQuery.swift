//
//  Posts.swift
//  HBD
//
//  Created by 김수경 on 8/20/24.
//

import Foundation

struct UploadPostQuery: Encodable {
    let title: String
    let price: Int
    let content: String?
    let content1: String
    let content2: String
    let content3: String
    let content4: String
    let productID: String
    let files: [String]
    
    enum CodingKeys: String, CodingKey {
        case title, price, content, content1, content2, content3, content4, files
        case productID = "product_id"
    }
    
    
}
