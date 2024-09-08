//
//  ParticipatedProfileView.swift
//  HBD
//
//  Created by 김수경 on 9/7/24.
//

import UIKit

final class ParticipatedProfileView: UIView {
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    private let label = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .gray
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureLayout()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Configure UI
    
    private func configureHierarchy() {
        addSubview(stackView)
        addSubview(label)
    }
    
    private func configureLayout() {
        stackView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }
        label.snp.makeConstraints { make in
            make.leading.equalTo(stackView.snp.trailing).offset(10)
            make.centerY.equalTo(stackView.snp.centerY)
        }
    }
    
    func setImages(_ images: [Data]) {
        for image in images {
            let profileImageView = UIImageView(image: UIImage(data: image)!)
            
            profileImageView.snp.makeConstraints { make in
                make.size.equalTo(25)
            }
            profileImageView.layer.cornerRadius = 12.5
            profileImageView.layer.masksToBounds = true
            
            stackView.addArrangedSubview(profileImageView)
        }
    }
    
    func setLabel(total: Int, now: Int) {
        label.text = "\(now) / \(total) 명 참여중"
    }
}

