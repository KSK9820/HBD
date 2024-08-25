//
//  MainViewModel.swift
//  HBD
//
//  Created by 김수경 on 8/21/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MainViewModel {

    private var collectionViewData = BehaviorRelay<[MainSection]>(value: [])
    
    private let disposeBag = DisposeBag()

    
    struct Input {
        let profileSelect: BehaviorRelay<IndexPath>
        let userID: PublishSubject<String>
    }
    
    struct Output {
        let beforeProfileSelect: BehaviorRelay<IndexPath>
        let collectionViewData: Driver<[MainSection]>
        
    }
    
    func transform(input: Input) -> Output {
        let selectedIndexPath = BehaviorRelay<IndexPath>(value: IndexPath(item: 0, section: 0))
        
        var followList = [Follow]()
        
        
        NetworkManager.shared.getMyProfile()
            .map { result in
                switch result {
                case .success(let userModel):
                    followList = userModel.following
                    let sectionItem = followList.map { MainsectionItem.profileCell($0) }
                    var existingSection = self.collectionViewData.value
                    
                    existingSection.append(MainSection(header: "", items: sectionItem))
                    self.collectionViewData.accept(existingSection)
                case .failure(let error):
                    self.collectionViewData.accept([MainSection(header: "", items: [])])
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
            
        input.profileSelect
            .distinctUntilChanged()
            .subscribe(with: self) { owner, indexPath in
                selectedIndexPath.accept(indexPath)
                if !followList.isEmpty {
                    let userID = followList[indexPath.row].userID
                    
                    NetworkManager.shared.getPosts(userID, page: "")
                        .map { result in
                            switch result {
                            case .success(let posts):
                                let sectionItem = posts.map { MainsectionItem.otherPostCell($0) }
                                var existingSection = self.collectionViewData.value
                                existingSection.append(MainSection(header: "", items: sectionItem))
                                self.collectionViewData.accept(existingSection)
                            case .failure(let error):
                                break
                            }
                        }
                        .subscribe()
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
            
        
        return Output(beforeProfileSelect: selectedIndexPath, collectionViewData: collectionViewData.asDriver())
    }
    
}
