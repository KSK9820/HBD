//
//  DetailGiftViewModel.swift
//  HBD
//
//  Created by 김수경 on 8/26/24.
//

import Foundation

final class DetailGiftViewModel {
    
    private var content: PostModel
    
    init(content: PostModel) {
        self.content = content
    }
    
    var userInformation: Creator {
        content.creator
    }
    
    
    var link: URLRequest? {
        if let link = content.link {
            return URLRequest(url: link)
        }
        return nil
    }

}
