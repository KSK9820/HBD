//
//  GiftCollectionViewCell.swift
//  HBD
//
//  Created by 김수경 on 8/24/24.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import WebKit
import Toast

final class GiftCollectionViewCell: UICollectionViewCell {
    
    private var disposeBag = DisposeBag()
    
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
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
    }
    private let participatedView = ParticipatedProfileView()
    private let priceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .medium)
    }
    private let dueDayLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.font = .systemFont(ofSize: 12)
    }
    private let joinButton = UIButton().then {
        $0.applyNeumorphismEffect(cornerRadius: 8, backgroundColor: .hbdMain)
        $0.setTitleColor(.white, for: .normal)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureLayout()
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    
    func setContent(_ content: PostModel) {
        let viewModel = GiftCollectionViewCellViewModel(content)
        let paymentResult = PublishSubject<Bool>()
        
        let input = GiftCollectionViewCellViewModel.Input(paymentResult: paymentResult)
        let output = viewModel.transform(input)
            
        output.giftImageData
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, data in
                if let data = data {
                    owner.giftImageView.image = UIImage(data: data)
                } else {
                    owner.giftImageView.image = UIImage(systemName: "gift")
                }
            }
            .disposed(by: disposeBag)
        
        
        joinButton.rx.tap
            .subscribe(with: self) { owner, _ in
                if let navigationController = self.findNavigationController() {
                    PaymentManager.shared.pay(price: viewModel.personalPrice, itemName: viewModel.title, nav: navigationController, postID: content.postID)
                        .subscribe { response in
                            paymentResult.onNext(response)
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        output.joinResponse
            .subscribe(with: self) { owner, like in
                if like {
                    owner.setPaid()
                    owner.makeToast("결제 성공하였습니다!")
                }
            }
            .disposed(by: disposeBag)
        
        output.participatedProfile
            .subscribe(with: self) { owner, images in
                owner.participatedView.setImages(images)
                owner.participatedView.setLabel(total: content.recruitment, now: images.count)
            }
            .disposed(by: disposeBag)
        
        titleLabel.text = viewModel.title
        priceLabel.text = viewModel.totalPrice
        dueDayLabel.text = viewModel.deadLine
        
        if viewModel.recruitmentNumber == viewModel.particiapatedPerson.count {
            setDone()
        } else if viewModel.participated {
            setPaid()
        } else {
            setNotJoin(viewModel.personalPrice)
        }
        
    }
    
    private func setDone() {
        joinButton.setTitle("참여 마감", for: .normal)
        joinButton.setTitleColor(.white, for: .normal)
        joinButton.backgroundColor = .hbdMain
    }
    
    private func setNotJoin(_ price: String) {
        joinButton.setTitle(price, for: .normal)
        joinButton.setTitleColor(.white, for: .normal)
        joinButton.backgroundColor = .hbdMain
    }
    
    private func setPaid() {
        joinButton.setTitle("결제 완료", for: .normal)
        joinButton.setTitleColor(.gray, for: .normal)
        joinButton.backgroundColor = .hbdPink
        joinButton.isEnabled = false
    }
    
    
    // MARK: - Configure UI
    
    private func configureHierarchy() {
        contentView.addSubview(giftView)
        giftView.addSubview(imageBackgroundView)
        imageBackgroundView.addSubview(giftImageView)
        
        [titleLabel, joinButton, priceLabel, participatedView, dueDayLabel].forEach {
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
        
        dueDayLabel.snp.makeConstraints { make in
            make.top.equalTo(imageBackgroundView.snp.bottom).offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageBackgroundView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(12)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        participatedView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(priceLabel.snp.bottom).offset(8)
        }
        
        joinButton.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(12)
            make.size.equalTo(ContentSize.joinButton.size)
        }
    }
}
