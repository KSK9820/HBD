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

final class MainGiftViewController: UIViewController {
    
    private let viewModel = MainViewModel()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: ProfileCollectionViewCell.reuseIdentifier)
        $0.register(GiftCollectionViewCell.self, forCellWithReuseIdentifier: GiftCollectionViewCell.reuseIdentifier)
        
    }
    private let disposeBag = DisposeBag()
    
    let dummy = [Follow]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureLayout()
        configureUI()
        
//        NetworkManager.shared.login(LoginQuery(email: "1@1", password: "1"))
//        NetworkManager.shared.searchUser("hbd_3")
//        NetworkManager.shared.getPosts("hbd_1", page: "")
//        NetworkManager.shared.uploadPost(UploadPostQuery(title: "조말론 향수", price: 285000, content: "잉글리쉬 페어 앤 프리지아 또는 잉글리쉬 페어 앤 스윗 피 코롱으로 선물할 것 같습니다.", content1: "https://www.jomalone.co.kr/scents/fruity/english-pear-freesia", content2: "6", content3: "20241111", content4: "false", productID: "66c601bbfb4075f921416672", files: ["uploads/posts/jo_sku_L32R01_1000x1000_0_1724481203310.jpeg"]))
        
        bind()
    }
    
    private func bind() {
        let nowSelectProfile = BehaviorRelay(value: IndexPath(item: 0, section: 0))
        
        let input = MainViewModel.Input(profileSelect: nowSelectProfile, userID: PublishSubject())
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
                cell.setName(followModel.nick)
                
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
        
        
        collectionView.rx.itemSelected
            .subscribe(with: self) { owner, value in
                switch value.section {
                case 0:
                    nowSelectProfile.accept(value)
                    break
                case 2:
                    owner.navigationController?.pushViewController(DetailGiftViewController(), animated: false)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)

    }

    
    // MARK: - Configure UI
    
    private func configureHierarchy() {
        view.addSubview(collectionView)
    }
    
    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
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
            case 2:
                self?.createGiftSectionLayout()
            default:
                self?.createProfileSectionLayout()
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


struct MainSection {
    var header: String
    var items: [Item]
}

extension MainSection: SectionModelType {
    typealias Item = MainsectionItem
    
    init(original: MainSection, items: [Item]) {
        self = original
        self.items = items
    }
}

enum MainsectionItem {
    case profileCell(Follow)
    case ownerPostCell(PostModel)
    case otherPostCell(PostModel)
    case completedPostCell(PostModel)
}
