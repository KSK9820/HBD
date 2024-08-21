//
//  PostModel.swift
//  HBD
//
//  Created by 김수경 on 8/20/24.
//

import Foundation

struct PostModel {
    let postID: String
    let productID: String
    let title: String
    let price: Int
    let content: String
    let link: String    // URL으로 변경 필요
    let recruitment: Int
    let recruitDeadline: Date
    let recruitDone: Bool
    let creator: Creator
    let files: [String]
    let likes: [String]
    let likes2: [String]
}
