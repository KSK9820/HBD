//
//  ContentUserProfileView.swift
//  HBD
//
//  Created by 김수경 on 8/24/24.
//

import UIKit

final class ContentUserProfileView: UIView {
    
//    private let profileImageURL: String
    
    private let profileView = ProfileView()
    private let nicknameLabel = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        configureHierarchy()
        configureLayout()
        configureUI()
    }
    
    // MARK: - Configure UI
    
    private func configureHierarchy() {
        addSubview(profileView)
        addSubview(nicknameLabel)
    }
    
    private func configureLayout() {
        profileView.snp.makeConstraints { make in
            make.size.equalTo(ContentSize.contentUserProfileImage.size)
            make.leading.equalTo(10)
            make.centerY.equalToSuperview()
        }
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.top)
            make.leading.equalTo(profileView.snp.trailing).offset(10)
        }
    }
    
    private func configureUI() {
        profileView.setImage(UIImage(systemName: "star")!)
        profileView.setRadius(ContentSize.contentUserProfileImage.radius)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
