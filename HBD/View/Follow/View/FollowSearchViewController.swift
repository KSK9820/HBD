//
//  FollowSearchViewController.swift
//  HBD
//
//  Created by 김수경 on 8/29/24.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

final class FollowSearchViewController: UIViewController {
    
    private let viewModel = FollowSearchViewModel()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private lazy var searchCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createSearchLayout()).then {
        $0.register(FollowCollectionViewCell.self, forCellWithReuseIdentifier: FollowCollectionViewCell.reuseIdentifier)
    }
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureLayout()
        configureUI()
        
        bind()
    }
    
    private func bind() {
        let searchName = PublishRelay<String>()
        
        let input = FollowSearchViewModel.Input(searchName: searchName)
        let output = viewModel.transform(input)
        
        searchController.searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .subscribe(with: self) { owner, value in
                searchName.accept(value)
            }
            .disposed(by: disposeBag)
        
        output.searchNameResult
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, value in
                owner.searchCollectionView.rx.items(cellIdentifier: FollowCollectionViewCell.reuseIdentifier, cellType: FollowCollectionViewCell.self) {
                    
                }
            }
        //            .bind(with: self) { owner, value in
        //                owner.searchCollectionView.rx.items(cellIdentifier: FollowCollectionViewCell.reuseIdentifier, cellType: FollowCollectionViewCell.self) { (row, element, cell) in
        //
        //
        //                }
        //            }
            .disposed(by: disposeBag)
        
        //        output.searchNameResult
        //            .observe(on: MainScheduler.instance)
        //            .bind(to: searchCollectionView.rx.items(cellIdentifier: FollowCollectionViewCell.reuseIdentifier, cellType: FollowCollectionViewCell.self) { (row, element, cell) in
        //
        //
        //            })
        //            .disposed(by: disposeBag)
        
    }
    
    
    // MARK: - Configure UI
    
    private func configureHierarchy() {
        
    }
    
    private func configureLayout() {
        
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        configureSearchController()
    }
    
    private func configureSearchController() {
        self.navigationItem.searchController = searchController
        
        searchController.searchBar.placeholder = "팔로우할 친구를 검색해보세요"
    }
    
    private func createSearchLayout() -> UICollectionViewLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: size)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(ContentSize.screenWidth), heightDimension: .absolute(ContentSize.unit.size.height))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
}

