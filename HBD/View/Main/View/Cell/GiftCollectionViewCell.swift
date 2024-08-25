//
//  GiftCollectionViewCell.swift
//  HBD
//
//  Created by 김수경 on 8/24/24.
//

import UIKit
import RxSwift
import Alamofire
import Kingfisher

final class GiftCollectionViewCell: UICollectionViewCell {
    
    private let disposeBag = DisposeBag()
    
    private let giftView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.applyNeumorphismEffect(cornerRadius: 24)
    }
    private let imageBackgroundView = UIView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    private let giftImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .medium)
    }
    private let priceLabel = UILabel()
    private let dueDayLabel = UILabel()
    private let joinButton = UIButton().then {
        $0.applyNeumorphismEffect(bgColor: .hbdMain, cornerRadius: 8)
        $0.setTitleColor(.white, for: .normal)
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
        contentView.addSubview(giftView)
        giftView.addSubview(imageBackgroundView)
        imageBackgroundView.addSubview(giftImageView)
        
        [titleLabel, joinButton, priceLabel, dueDayLabel].forEach {
            giftView.addSubview($0)
        }
        
    }

    private func configureLayout() {
        giftView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(contentView).inset(16)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-12)
        }
        
        imageBackgroundView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(giftView)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        
        giftImageView.snp.makeConstraints { make in
            make.edges.equalTo(imageBackgroundView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageBackgroundView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(12)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(joinButton.snp.top)
        }
        
        dueDayLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalTo(joinButton.snp.bottom)
        }
        
        joinButton.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(12)
            make.size.equalTo(ContentSize.joinButton.size)
        }
    }
    
    func setContent(_ content: PostModel) {
        let viewModel = GiftCollectionViewCellViewModel(content)
        
        giftImageView.kf.setImage(with: viewModel.imageURL, options: [.requestModifier(viewModel.headerModifier)])
        titleLabel.text = viewModel.title
        priceLabel.text = viewModel.totalPrice
        dueDayLabel.text = viewModel.deadLine
        joinButton.setTitle(viewModel.buttonPrice, for: .normal)
    }
    
    
}
