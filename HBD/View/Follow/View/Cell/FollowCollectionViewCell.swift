//
//  FollowCollectionViewCell.swift
//  HBD
//
//  Created by 김수경 on 8/29/24.
//

import UIKit
import RxSwift
import RxCocoa

final class FollowCollectionViewCell: UICollectionViewCell {
    
    private let viewModel = FollowCollectionViewModel()
    
    private let backgroundFollowView = UIView().then {
        $0.applyNeumorphismEffect()
        $0.layer.cornerRadius =  8
        $0.layer.borderColor = UIColor.hbdMain.cgColor
        $0.layer.borderWidth = 1
        $0.backgroundColor = .white
    }
    private let profileView = ProfileView().then {
        $0.setRadius(ContentSize.profileImageCell.radius - 10)
    }
    private let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
    }
    private let birthLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .hbdMain
    }
    private let followButton = UIButton().then {
        $0.layer.cornerRadius = 8
        $0.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
    
    private var disposeBag = DisposeBag()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
        nameLabel.text = nil
        birthLabel.text = nil
        profileView.setImage(nil)
        viewModel.initUser()
    }
    
    func bind() {
        let followUser = PublishSubject<String>()
        let unfollowUser = PublishSubject<String>()
        
        let input = FollowCollectionViewModel.Input(follow: followUser, unfollow: unfollowUser)
        let output = viewModel.transform(input)
        
        followButton.rx.tap
            .subscribe(with: self) { owner, _ in
                guard let following = owner.viewModel.isFollowing else { return }
                guard let userID = owner.viewModel.userID else { return }
                
                if following {
                    followUser.onNext(userID)
                } else {
                    unfollowUser.onNext(userID)
                }
            }
            .disposed(by: disposeBag)
            
        output.followResult
            .subscribe(with: self) { owner, value in
                if value {
                    owner.viewModel.setFollowing(true)
                    owner.setFollowingStatus()
                }
            }
            .disposed(by: disposeBag)
            
        output.unfollowResult
            .subscribe(with: self) { owner, value in
                if value {
                    owner.viewModel.setFollowing(false)
                    owner.setFollowingStatus()
                }
            }
            .disposed(by: disposeBag)
    }
    
    func setContents(_ user: SearchUser) {
        bind() 
        viewModel.setUser(user)
        nameLabel.text = user.nick
        setFollowingStatus()
        
        if let birthDay = user.birthDay {
            birthLabel.text = birthDay
        }
        if let profileImage = user.profileImage {
            NetworkManager.shared.readImage(profileImage)
                .compactMap { response -> UIImage? in
                    switch response {
                    case .success(let data):
                        return UIImage(data: data)
                    case .failure(_):
                        return nil
                    }
                }
                .asDriver(onErrorJustReturn: UIImage(systemName: "person.fill")!.withTintColor(.red))
                .drive(with: self) { owner, image in
                    owner.profileView.setImage(image)
                }
                .disposed(by: disposeBag)
        } else {
            let image = UIImage(systemName: "person.fill")!.withTintColor(.red)
            profileView.setImage(image)
        }
    }
    
    private func setFollowingStatus() {
        guard let isFollowing = viewModel.isFollowing else { return }
        if isFollowing {
            followButton.setTitle("언팔로우", for: .normal)
            followButton.backgroundColor = .hbdGreen
            followButton.setTitleColor(.white, for: .normal)
        } else {
            followButton.setTitle("팔로우", for: .normal)
            followButton.backgroundColor = .hbdMain
            followButton.setTitleColor(.white, for: .normal)
        }
    }
    
    func setHideButton() {
        followButton.isHidden = true
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
            make.horizontalEdges.equalToSuperview().inset(20)
            make.verticalEdges.equalToSuperview().inset(10)
        }
        profileView.snp.makeConstraints { make in
            make.leading.equalTo(backgroundFollowView).offset(12)
            make.centerY.equalTo(backgroundFollowView.snp.centerY)
            make.size.equalTo(ContentSize.profileImageCell.size.width - 20)
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileView.snp.trailing).offset(20)
            make.bottom.equalTo(backgroundFollowView.snp.centerY).offset(-4)
        }
        birthLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileView.snp.trailing).offset(20)
            make.top.equalTo(backgroundFollowView.snp.centerY).offset(4)
        }
        followButton.snp.makeConstraints { make in
            make.centerY.equalTo(backgroundFollowView.snp.centerY)
            make.trailing.equalTo(backgroundFollowView.snp.trailing).offset(-12)
        }
    }
    
}


