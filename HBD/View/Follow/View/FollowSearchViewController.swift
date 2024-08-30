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
import Then

final class FollowSearchViewController: UIViewController {
    
    private let viewModel = FollowSearchViewModel()
    
    private let searchController = UISearchController(searchResultsController: nil)
    let searchFollowCollectionView = UICollectionView(frame: .zero, collectionViewLayout: FollowSearchViewController.createSearchLayout())
        .then {
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
            .asDriver(onErrorJustReturn: [])
            .drive(searchFollowCollectionView.rx.items(cellIdentifier: FollowCollectionViewCell.reuseIdentifier, cellType: FollowCollectionViewCell.self)) { row, element, cell in
                cell.setContents(element)
            }
            .disposed(by: disposeBag)
    }
    

    // MARK: - Configure UI
    
    private func configureHierarchy() {
        view.addSubview(searchFollowCollectionView)
    }
    
    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        searchFollowCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        configureSearchController()
    }
    
    private func configureSearchController() {
        self.navigationItem.searchController = searchController
        
        searchController.searchBar.placeholder = "팔로우할 친구를 검색해보세요"
    }
    
    static func createSearchLayout() -> UICollectionViewLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: size)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(ContentSize.screenWidth), heightDimension: .absolute(ContentSize.profileImageCell.size.height))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
}

