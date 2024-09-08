//
//  HeaderContents.swift
//  HBD
//
//  Created by 김수경 on 8/15/24.
//

import Foundation

enum HeaderContents: String {
    case authorization = "Authorization"
    case sesacKey = "SesacKey"
    case contentType = "Content-Type"
    case refresh = "Refresh"
    
    case json = "application/json"
    case multi = "multipart/form-data"
}
