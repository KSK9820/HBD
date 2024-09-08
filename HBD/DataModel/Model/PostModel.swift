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
    let personalPrice: Int
    let content: String
    let link: URL?
    let recruitment: Int
    let recruitDeadline: Date
    let totalPrice: Int
    let creator: Creator
    let files: [String]
    let likes: [String]
    let likes2: [String]
}
