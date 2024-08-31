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
    private let searchFollowCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .followLayout())
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
        let emptyName = BehaviorSubject<String>(value: "")
        
        let input = FollowSearchViewModel.Input(searchName: searchName, emptyName: emptyName)
        let output = viewModel.transform(input)

        searchController.searchBar.rx.text
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(with: self) { owner, value in
                guard let value else { return }
                if value == "" {
                    emptyName.onNext("")
                } else {
                    searchName.accept(value)
                }
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
        setNavigation()
        configureSearchController()
    }
    
    private func configureSearchController() {
        self.navigationItem.searchController = searchController
        
        searchController.searchBar.placeholder = "팔로우할 친구를 검색해보세요"
    }
    
    private func setNavigation() {
        let calendarImage = UIImage(systemName: "calendar")!.withTintColor(.hbdMain, renderingMode: .alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: calendarImage, style: .plain, target: self, action: #selector(calendarButtonTapped))
    }

    @objc private func calendarButtonTapped() {
        self.navigationController?.pushViewController(CalendarViewController(), animated: false)
    }
}
