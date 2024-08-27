//
//  GiftInformationView.swift
//  HBD
//
//  Created by 김수경 on 8/27/24.
//

import UIKit
import RxSwift
import RxCocoa


final class GiftInformationView: UIView {
    
    private let viewModel: GiftInformationViewModel
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: GiftInformationViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        configureHierarchy()
        configureLayout()
        configureUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private let informationView = UIView().then {
        $0.applyNeumorphismEffect()
        $0.backgroundColor = .hbdMelon
        $0.layer.cornerRadius = 16
    }
    private let HStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 20
        $0.distribution = .fillProportionally
    }
    private let giftImageView = UIImageView().then {
        $0.applyNeumorphismEffect()
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .hbdMelon
    }
    
    private let vStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.distribution = .fillProportionally
    }
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .medium)
    }
    private let priceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 2
    }
    private let deadLineLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .light)
    }
    private let joinButton = UIButton().then {
        $0.backgroundColor = .hbdMain
        $0.setTitleColor(.white, for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
    }

    
    func bind() {
        let input = GiftInformationViewModel.Input()
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
    }

    
    // MARK: - Configure UI
    
    private func configureHierarchy() {
        addSubview(informationView)
        informationView.addSubview(HStackView)
        addSubview(HStackView)
        [giftImageView, vStackView].forEach {
            HStackView.addArrangedSubview($0)
        }
        
        [titleLabel, priceLabel, deadLineLabel].forEach {
            vStackView.addArrangedSubview($0)
        }
        informationView.addSubview(joinButton)

    }
    
    private func configureLayout() {
        informationView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
            make.height.equalTo(ContentSize.informationImage.size.height + 90)
        }
        HStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(informationView).inset(16)
        }
        giftImageView.snp.makeConstraints { make in
            make.size.equalTo(ContentSize.informationImage.size)
        }
        joinButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(informationView).inset(16)
            make.height.equalTo(ContentSize.joinButton.size.height * 0.7)
            make.width.equalTo(ContentSize.joinButton.size.width * 0.7)
        }
    }
    
    private func configureUI() {
        titleLabel.text = viewModel.title
        priceLabel.attributedText = createPriceAttributed()
        deadLineLabel.text = viewModel.deadLine       
        joinButton.setTitle("선물하기", for: .normal)
    }
    
    private func createPriceAttributed() -> NSAttributedString {
        let totalPriceString = viewModel.totalPrice
        let recruitmentNumberString = viewModel.recruitmentNumber
        let personalPriceString = viewModel.personalPrice
        
        let attributedString = NSMutableAttributedString()
        
        let totalPriceAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.hbdPink]
        attributedString.append(NSAttributedString(string: totalPriceString, attributes: totalPriceAttributes))
        attributedString.append(NSAttributedString(string: " / "))
        
        let recruitmentNumberAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.darkGray]
        attributedString.append(NSAttributedString(string: recruitmentNumberString, attributes: recruitmentNumberAttributes))
        
        let personalPriceAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.hbdMain]
        attributedString.append(NSAttributedString(string: "\n  = "))
        attributedString.append(NSAttributedString(string: personalPriceString, attributes: personalPriceAttributes))
        
        return attributedString
    }
}

