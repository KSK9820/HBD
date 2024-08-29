//
//  FollowCollectionViewCell.swift
//  HBD
//
//  Created by 김수경 on 8/29/24.
//

import UIKit
import RxSwift

final class FollowCollectionViewCell: UICollectionViewCell {
    
    private let backgroundFollowView = UIView().then {
        $0.applyNeumorphismEffect()
        $0.clipsToBounds = true
        $0.layer.cornerRadius =  8
    }
    private let profileView = ProfileView()
    private let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
    }
    private let birthLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .hbdMain
    }
    private let followButton = UIButton().then {
        $0.layer.cornerRadius = 8
    }
    
    private var disposeBag = DisposeBag()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureLayout()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    
    // MARK: - Configure UI
    
    private func configureHierarchy() {
        contentView.addSubview(backgroundFollowView)
        [profileView, nameLabel, birthLabel, followButton].forEach {
            backgroundFollowView.addSubview($0)
        }
        
    }
    
    private func configureLayout() {
        backgroundFollowView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(12)
        }
        profileView.snp.makeConstraints { make in
            make.size.equalTo(ContentSize.profileImageCell.size)
            make.leading.verticalEdges.equalTo(backgroundFollowView).inset(12)
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileView.snp.leading).offset(20)
            make.top.equalTo(profileView.snp.top)
        }
        birthLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileView.snp.leading).offset(20)
            make.top.equalTo(nameLabel.snp.top).offset(10)
        }
        
        followButton.snp.makeConstraints { make in
            make.centerY.equalTo(backgroundFollowView.snp.centerY)
            make.trailing.equalTo(backgroundFollowView.snp.trailing).offset(-12)
        }
    }
    
    private func configureUI() {
        
    }
    
    
    
    
    func setContents(_ follow: SearchUser) {
        profileView.setImage(UIImage(systemName: "star")!)
        nameLabel.text = follow.nick
        
        followButton.setTitle("팔로우", for: .normal)
    }
}

