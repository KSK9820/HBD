//
//  PostResponse.swift
//  HBD
//
//  Created by 김수경 on 8/20/24.
//

import Foundation

struct PostResponse: Decodable {
    let postID: String
    let productID: String
    let title: String
    let price: Int
    let content: String
    let content1: String 
    let content2: String
    let content3: String
    let content4: String
    let content5: String?
    let createdAt: String
    let creator: Creator
    let files: [String]
    let likes: [String]
    let likes2: [String]
    
    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case productID = "product_id"
        case title, price, content, content1, content2, content3, content4, content5, createdAt, creator, files, likes, likes2
    }
    
    func convertToPostModel() -> PostModel {
        let completed = content4 == "true" ? true : false
        let url = URL(string: content1)
        return PostModel(postID: postID,
                         productID: productID,
                         title: title,
                         price: price,
                         content: content,
                         link: url,
                         recruitment: Int(content2)!,
                         recruitDeadline: Date(),
                         recruitDone: completed,
                         creator: creator,
                         files: files,
                         likes: likes, likes2: likes2)
    }
}

struct Creator: Decodable {
    let userID: String
    let nick: String
    let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage
    }
}
