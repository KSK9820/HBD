//
//  ContentUserProfileView.swift
//  HBD
//
//  Created by 김수경 on 8/24/24.
//

import UIKit
import RxSwift
import RxCocoa

final class ContentUserProfileView: UIView {
    
    private let creator: Creator
    private let profileView = ProfileView()
    private let nicknameLabel = UILabel()
    
    private let disposeBag = DisposeBag()
    
    init(postUser: Creator) {
        self.creator = postUser
        super.init(frame: .zero)
        
        configureHierarchy()
        configureLayout()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - Configure UI
    
    private func configureHierarchy() {
        addSubview(profileView)
        addSubview(nicknameLabel)
    }
    
    private func configureLayout() {
        profileView.snp.makeConstraints { make in
            make.size.equalTo(ContentSize.contentUserProfileImage.size)
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
        }
        nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileView.snp.trailing).offset(10)
            make.centerY.equalTo(profileView)
        }
    }
    
    private func configureUI() {
        profileView.setRadius(ContentSize.contentUserProfileImage.radius)
        profileView.setBorder(true)
        nicknameLabel.text = creator.nick
        
        if let profileImage = creator.profileImage {
            NetworkManager.shared.readImage(profileImage)
                .map { result -> Data? in
                    switch result {
                    case .success(let imageData):
                        return imageData
                    case .failure(let error):
                        print(error)
                    }
                    return nil
                }
                .asDriver(onErrorJustReturn: nil)
                .drive(with: self) { owner, value in
                    if let data = value,
                       let profileImage = UIImage(data: data) {
                        owner.profileView.setImage(profileImage)
                    } else {
                        owner.profileView.setImage(UIImage(systemName: "person")!)
                    }
                }
                .disposed(by: disposeBag)
        } else {
            profileView.setImage(UIImage(systemName: "person")!)
        }
    }
    
}
