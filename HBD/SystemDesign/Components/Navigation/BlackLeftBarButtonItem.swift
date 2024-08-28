//
//  BlackLeftBarButtonItem.swift
//  HBD
//
//  Created by 김수경 on 8/26/24.
//

import UIKit

final class BlackLeftBarButtonItem: UIBarButtonItem {

    init(action: Selector? = nil, target: UIViewController) {
        super.init()
        image = UIImage(systemName: "chevron.left")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        style = .plain
        
        self.target = target
        self.action = action
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
