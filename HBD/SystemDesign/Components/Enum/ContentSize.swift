//
//  ContentSize.swift
//  HBD
//
//  Created by 김수경 on 8/22/24.
//

import UIKit

enum ContentSize {
    static var screenWidth: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.screen.bounds.size.width
        }
        return UIScreen.main.bounds.size.width
    }
    static var screenHeight: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.screen.bounds.size.height
        }
        return UIScreen.main.bounds.size.height
    }
    
    case profileImageCell
    case contentUserProfileImage
    case joinButton
    case informationImage
    case floatingButton
    case unit
}

extension ContentSize {
    var size: CGSize {
        switch self {
        case .profileImageCell:
            return CGSize(width: ContentSize.screenWidth * 0.2, height: ContentSize.screenWidth * 0.2 + 20)
        case .contentUserProfileImage:
            return CGSize(width: ContentSize.screenWidth * 0.1, height: ContentSize.screenWidth * 0.1)
        case .joinButton:
            return CGSize(width: ContentSize.screenWidth * 0.3, height: ContentSize.screenWidth * 0.1)
        case .informationImage:
            return CGSize(width: ContentSize.screenWidth * 0.3, height: ContentSize.screenWidth * 0.3)
        case .floatingButton:
            return CGSize(width: ContentSize.screenWidth * 0.15, height: ContentSize.screenWidth * 0.15)
        case .unit:
            return CGSize(width: ContentSize.screenWidth * 0.1, height: ContentSize.screenHeight * 0.1)
        }
    }
    var radius: CGFloat {
        switch self {
        case .profileImageCell:
            return ContentSize.screenWidth * 0.1
        case .contentUserProfileImage:
            return ContentSize.screenWidth * 0.05
        case .joinButton, .informationImage:
            return 8
        case .floatingButton:
            return ContentSize.floatingButton.size.width / 2
        default:
            return 0
        }
    }
}
