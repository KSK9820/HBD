//
//  MainGiftViewModel.swift
//  HBD
//
//  Created by 김수경 on 8/21/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MainGiftViewModel {

    private var collectionViewData = BehaviorRelay<[MainSection]>(value: [])
    
    private let disposeBag = DisposeBag()

    
    struct Input {
        let profileSelect: BehaviorRelay<IndexPath>
        let userID: PublishSubject<String>
        let postSelect: PublishRelay<IndexPath>
        let floatingButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let beforeProfileSelect: BehaviorRelay<IndexPath>
        let collectionViewData: Driver<[MainSection]>
        let selectedPostData: PublishSubject<MainsectionItem>
        let floatingProfile: PublishSubject<Follow>
    }
    
    func transform(input: Input) -> Output {
        let selectedProfileIndexPath = BehaviorRelay<IndexPath>(value: IndexPath(item: 0, section: 0))
        let selectedPostData = PublishSubject<MainsectionItem>()
        let floatingProfile = PublishSubject<Follow>()
        var followList = [Follow]()
        
        
        NetworkManager.shared.getMyProfile()
            .map { result in
                switch result {
                case .success(let userModel):
                    followList = userModel.following
                    
                    let sectionItem = followList.map { MainsectionItem.profileCell($0) }
                    var existingSection = self.collectionViewData.value
                    existingSection.append(MainSection(header: "section0", items: sectionItem))
                    
                    self.collectionViewData.accept(existingSection)
                case .failure(_):
                    self.collectionViewData.accept([MainSection(header: "", items: [])])
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
            
        input.profileSelect
            .distinctUntilChanged()
            .subscribe(with: self) { owner, indexPath in
                selectedProfileIndexPath.accept(indexPath)
                if !followList.isEmpty {
                    let userID = followList[indexPath.row].userID
                    
                    NetworkManager.shared.getPosts(userID, page: "")
                        .map { result in
                            switch result {
                            case .success(let posts):
                                
                                var currentSections = self.collectionViewData.value
                                let newSection = MainSection(header: "section2", items: posts.map { MainsectionItem.otherPostCell($0) })
                                
                                if let sectionIndex = currentSections.firstIndex(where: { $0.header == "section2" }) {
                                    currentSections[sectionIndex] = newSection
                                } else {
                                    currentSections.append(newSection)
                                }
                                
                                self.collectionViewData.accept(currentSections)
                                
                            case .failure(let error):
                                break
                            }
                        }
                        .subscribe()
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
          
        input.postSelect
            .subscribe(with: self) { owner, indexPath in
                selectedPostData.onNext(owner.collectionViewData.value[indexPath.section].items[indexPath.row])
            }
            .disposed(by: disposeBag)
        
        input.floatingButtonTap
            .map {
                followList[selectedProfileIndexPath.value.row]
            }
            .bind(with: self) { owner, value in
                floatingProfile.onNext(value)
            }
            .disposed(by: disposeBag)
        
        return Output(beforeProfileSelect: selectedProfileIndexPath, collectionViewData: collectionViewData.asDriver(), selectedPostData: selectedPostData, floatingProfile: floatingProfile)
    }
    
}
