//
//  MainSection.swift
//  HBD
//
//  Created by 김수경 on 8/28/24.
//

import Foundation
import RxDataSources

struct MainSection {
    var header: String
    var items: [Item]
}

extension MainSection: SectionModelType {
    typealias Item = MainsectionItem
    
    init(original: MainSection, items: [Item]) {
        self = original
        self.items = items
    }
}

enum MainsectionItem {
    case profileCell(Follow)
    case ownerPostCell(PostModel)
    case otherPostCell(PostModel)
    case completedPostCell(PostModel)
}
