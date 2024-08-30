//
//  MainGiftViewController.swift
//  HBD
//
//  Created by 김수경 on 8/21/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Toast
import Then

final class MainGiftViewController: UIViewController {
    
    private let viewModel = MainGiftViewModel()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: ProfileCollectionViewCell.reuseIdentifier)
        $0.register(GiftCollectionViewCell.self, forCellWithReuseIdentifier: GiftCollectionViewCell.reuseIdentifier)
    }
    private let floatingButton = UIButton().then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: ContentSize.floatingButton.size.width / 2, weight: .bold)
        let buttonImage = UIImage(systemName: "gift.fill", withConfiguration: imageConfig)
        
        $0.setImage(buttonImage, for: .normal)
        $0.backgroundColor = UIColor.hbdMain
        $0.tintColor = .white
        $0.layer.cornerRadius = ContentSize.floatingButton.radius
    }

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureLayout()
        configureUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func bind() {
        
        let nowSelectProfile = BehaviorRelay(value: IndexPath(item: 0, section: 0))
        let selectPost = PublishRelay<IndexPath>()
        
        let input = MainGiftViewModel.Input(profileSelect: nowSelectProfile, userID: PublishSubject(), postSelect: selectPost, floatingButtonTap: floatingButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        // collectionView
        let dataSource = RxCollectionViewSectionedReloadDataSource<MainSection>(configureCell: { dataSource, collectionView, indexPath, item in
            
            switch item {
            case let .profileCell(followModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionViewCell.reuseIdentifier, for: indexPath) as? ProfileCollectionViewCell else { return UICollectionViewCell() }
                
                if indexPath == nowSelectProfile.value {
                    cell.toggleBorder(true)
                } else {
                    cell.toggleBorder(false)
                }
                
                cell.setContent(followModel)
                
                return cell
            case let .ownerPostCell(postModel):
                break
            case let .otherPostCell(postModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GiftCollectionViewCell.reuseIdentifier, for: indexPath) as? GiftCollectionViewCell else { return UICollectionViewCell() }
                
                cell.setContent(postModel)
                
                return cell
            case let .completedPostCell(_):
                break
            }
            return UICollectionViewCell()
        })
        
        output.collectionViewData
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.selectedPostData
            .compactMap { sectionItem -> PostModel? in
                switch sectionItem {
                case .otherPostCell(let postModel):
                    return postModel
                default:
                    return nil
                }
            }
            .subscribe(with: self) { owner, value in
                let vc = DetailGiftViewController(content: value)
                owner.navigationController?.pushViewController(vc, animated: false)
            } onError: { owner, error in
                print(error)
            } onCompleted: { _ in
                print("completed")
            } onDisposed: { _ in
                print("disposed")
            }
            .disposed(by: disposeBag)

        output.floatingProfile
            .subscribe(with: self) { owner, value in
                let vc = PostGiftViewController(id: value.userID)
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: false)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(with: self) { owner, value in
                switch value.section {
                case 0:
                    nowSelectProfile.accept(value)
                case 1:
                    selectPost.accept(value)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
    }

    
    // MARK: - Configure UI
    
    private func configureHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(floatingButton)
    }
    
    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }
        floatingButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(safeArea).inset(20)
            make.size.equalTo(ContentSize.floatingButton.size)
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
    }
    

    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            switch sectionIndex {
            case 0:
                self?.createProfileSectionLayout()
            case 1:
                self?.createGiftSectionLayout()
            default:
                self?.createGiftSectionLayout()
            }
        }
    }
    
    private func createProfileSectionLayout() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: size)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(ContentSize.profileImageCell.size.width + 8), heightDimension: .absolute(ContentSize.profileImageCell.size.height + 8))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        return section
    }
    
    private func createGiftSectionLayout() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: size)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(ContentSize.screenWidth - 10), heightDimension: .absolute(ContentSize.screenWidth))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
}


