//
//  FollowingCircleCollectionViewCell.swift
//  HBD
//
//  Created by 김수경 on 8/21/24.
//

import UIKit
import SnapKit
import RxSwift

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
        disposeBag = DisposeBag()
    }
    
    
    // MARK: - internal method
    
    func setImage(_ image: UIImage) {
        profileView.setImage(image)
    }
    
    func setName(_ name: String?) {
        nameLabel.text = name
    }
    
    func toggleBorder(_ selected: Bool) {
        profileView.setBorder(selected)
    }
    
    func setRadius() {
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
