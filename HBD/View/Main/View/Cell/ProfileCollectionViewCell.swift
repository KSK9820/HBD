//
//  FollowingCircleCollectionViewCell.swift
//  HBD
//
//  Created by 김수경 on 8/21/24.
//

import UIKit
import SnapKit
import RxSwift
import Then

final class ProfileCollectionViewCell: UICollectionViewCell {
    
    private let profileView = ProfileView().then {
        $0.setRadius(ContentSize.profileImageCell.radius)
        $0.applyNeumorphismEffect(cornerRadius: ContentSize.profileImageCell.radius)
    }
    private let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .light)
        $0.textColor = .gray
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
        profileView.setImage(UIImage(systemName: "star")!)
        disposeBag = DisposeBag()
    }
    
    
    func setContent(_ user: Follow) {
        nameLabel.text = user.nick
        
        if let profileImage = user.profileImage {
            NetworkManager.shared.readImage(profileImage)
                .map { result -> Data? in
                    switch result {
                    case .success(let imageData):
                        return imageData
                    case .failure(let error):
                        print(error)
                        return nil
                    }
                }
                .asDriver(onErrorJustReturn: nil)
                .drive(with: self) { owner, data in
                    if let data {
                        if let profileImage = UIImage(data: data) {
                            owner.profileView.setImage(profileImage)
                        }
                    } else {
                        owner.profileView.setImage(UIImage(systemName: "person")!)
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    func toggleBorder(_ selected: Bool) {
        profileView.setBorder(selected)
    }
    
    private func setRadius() {
        profileView.setRadius(ContentSize.profileImageCell.radius)
    }
    
    // MARK: - Configure UI
        
    private func configureHierarchy() {
        contentView.addSubview(profileView)
        contentView.addSubview(nameLabel)
    }
    
    private func configureLayout() {
        profileView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.size.equalTo(ContentSize.profileImageCell.size.width)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom).offset(4)
            make.bottom.equalToSuperview()
            make.centerX.equalTo(profileView.snp.centerX)
        }
    }

}
