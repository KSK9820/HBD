//
//  MainTabBarController.swift
//  HBD
//
//  Created by 김수경 on 8/21/24.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .hbdMain
        tabBar.unselectedItemTintColor = .darkGray
        
        let nav1VC = FollowSearchViewController()
        let nav2VC = MainGiftViewController()
        let nav3VC = MyInformationViewController()
        
        
        let nav1 = UINavigationController(rootViewController: nav1VC)
        nav1.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "magnifyingglass"), tag: 0)
        
        let nav2 = UINavigationController(rootViewController: nav2VC)
        nav2.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "gift"), tag: 1)
        
        let nav3 = UINavigationController(rootViewController: nav3VC)
        nav3.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person"), tag: 1)
        
        setViewControllers([nav1, nav2, nav3], animated: false)
        
        selectedIndex = 1
    }
    
}
