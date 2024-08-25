//
//  ProfileView.swift
//  HBD
//
//  Created by 김수경 on 8/21/24.
//

import UIKit
import SnapKit

final class ProfileView: UIView {
    
    private lazy var imageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.image = UIImage(systemName: "star")
        $0.contentMode = .scaleAspectFill
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - internal method
    
    func setRadius(_ radius: CGFloat) {
        imageView.layer.cornerRadius = radius
    }
    
    func setBorder(_ selected: Bool) {
        imageView.layer.borderColor = selected ? UIColor.hbdMain.cgColor : nil
        imageView.layer.borderWidth = selected ? 4 : 0 
    }
    
    func setImage(_ image: UIImage) {
        imageView.image = image
    }
    

    // MARK: - Configure UI
    
    private func configureHierarchy() {
        addSubview(imageView)
    }
    
    private func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
        
}
