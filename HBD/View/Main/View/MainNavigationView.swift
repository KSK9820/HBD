//
//  MainNavigationView.swift
//  HBD
//
//  Created by 김수경 on 9/6/24.
//

import UIKit

final class MainNavigationView: UIView {
    private let giftImage = UIImageView().then {
        $0.image = UIImage(systemName: "gift.fill")
        $0.tintColor = .hbdMain
        
    }
    private let title = UILabel().then {
        $0.text = "HBD"
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textColor = .hbdMain
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Configure UI
    
    private func configureHierarchy() {
        addSubview(giftImage)
        addSubview(title)
    }
    
    private func configureLayout() {
        giftImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(30)
        }
        title.snp.makeConstraints { make in
            make.leading.equalTo(giftImage.snp.trailing)
            make.bottom.equalTo(giftImage.snp.bottom)
        }
    }
    
}

