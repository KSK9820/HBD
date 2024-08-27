//
//  NaivagionBaseViewController.swift
//  HBD
//
//  Created by 김수경 on 8/26/24.
//

import UIKit

class NaivagionBaseViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackButtonItem()
        addBottomLineToNavigationBar()
    }
 
    
    private func configureBackButtonItem() {
        navigationItem.leftBarButtonItem = BlackLeftBarButtonItem(
            action: #selector(navigationBackButtonItemTapped),
            target: self)
    }
    
    private func addBottomLineToNavigationBar() {
        guard let navigationController else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.white
        navigationController.navigationBar.scrollEdgeAppearance = appearance
    }
    
    @objc func navigationBackButtonItemTapped() { }
}
