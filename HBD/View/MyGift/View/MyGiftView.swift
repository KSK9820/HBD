//
//  MyGiftView.swift
//  HBD
//
//  Created by 김수경 on 9/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class MyGiftView: UIView {
    
    private let viewModel = MyGiftViewModel()
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .createGiftLayout())
        .then {
            $0.register(GiftCollectionViewCell.self, forCellWithReuseIdentifier: GiftCollectionViewCell.reuseIdentifier)
        }
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureLayout()
        configureUI()
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        let load = BehaviorRelay<Void>(value: ())
        
        let input = MyGiftViewModel.Input(load: load, postPrefetchItemsTrigger: collectionView.rx.prefetchItems)
        let output = viewModel.transform(input)
        
        output.myGiftPost
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(cellIdentifier: GiftCollectionViewCell.reuseIdentifier, cellType: GiftCollectionViewCell.self)) { (item, element, cell) in
                cell.setContent(element)
            }
            .disposed(by: disposeBag)
        
        
    }
    
    
    // MARK: - Configure UI
    
    private func configureHierarchy() {
        addSubview(collectionView)
    }
    
    private func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureUI() {
        backgroundColor = .white
    }
    
}


