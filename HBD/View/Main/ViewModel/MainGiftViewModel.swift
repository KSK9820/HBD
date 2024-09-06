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
    private var cursor: String = ""
    private var isLoadingPage = false
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    
    
    struct Input {
        let profileSelect: BehaviorRelay<IndexPath>
        let postSelect: PublishRelay<IndexPath>
        let floatingButtonTap: ControlEvent<Void>
        let postPrefetchItemsTrigger: ControlEvent<[IndexPath]>
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
        let itemsRelay = BehaviorRelay<[PostModel]>(value: [])
        
        
        var userID: String = ""
        
        
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
                    userID = followList[indexPath.row].userID
                    
                    NetworkManager.shared.getPosts(userID, page: owner.cursor)
                        .map { result in
                            switch result {
                            case .success(let posts):
                                owner.cursor = posts.nextCursor
                                
                                var postModel = posts.data.map { $0.convertToPostModel() }
                                var currentSections = self.collectionViewData.value
                                let newSection = MainSection(header: "section2", items: postModel.map { MainsectionItem.otherPostCell($0) })
                                
                                
                                itemsRelay.accept(itemsRelay.value + postModel)
                                //                                if let sectionIndex = currentSections.firstIndex(where: { $0.header == "section2" }) {
                                //                                    currentSections[sectionIndex] = newSection
                                //                                }
                                //                                else {
                                currentSections.append(newSection)
                                //                                }
                                
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
        
        input.postPrefetchItemsTrigger
            .observe(on: MainScheduler.instance)
            .flatMap { indexPaths -> Observable<[PostModel]> in
                guard let maxIndex = indexPaths.map({ $0.row }).max(),
                      maxIndex >= itemsRelay.value.count - 2 else { return .empty() }
                
                return self.fetchPostItems(userID: userID, cursorPage: self.cursor)
            }.subscribe(with: self) { owner, value in
                itemsRelay.accept(itemsRelay.value + value)
            }
            .disposed(by: disposeBag)
        
        itemsRelay
            .map { items -> [MainSection] in
                var currentSections = self.collectionViewData.value
                
                if let sectionIndex = currentSections.firstIndex(where: { $0.header == "section2" }) {
                    currentSections[sectionIndex].items.append(contentsOf: items.map { MainsectionItem.otherPostCell($0) })
                }
                print("🥳🥳", currentSections)
                return currentSections
            }
            .debug("🥳🥳")
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, value in
                owner.collectionViewData.accept(value)
            }
            .disposed(by: disposeBag)
        
        
        return Output(beforeProfileSelect: selectedProfileIndexPath, collectionViewData: collectionViewData.asDriver(), selectedPostData: selectedPostData, floatingProfile: floatingProfile)
    }
    
    private func fetchPostItems(userID: String, cursorPage: String) -> Observable<[PostModel]> {
        guard !isLoadingPage else { return .empty() }
        guard cursor != "0" else { return .empty() }
        isLoadingPage = true
        isLoadingRelay.accept(true)
        
        return NetworkManager.shared.getPosts(userID, page: cursor)
            .asObservable()
            .flatMap { result -> Observable<[PostModel]> in
                switch result {
                case .success(let response):
                    self.cursor = response.nextCursor
                    
                    return Observable.just(response.data.map { $0.convertToPostModel() })
                case .failure(let error):
                    return Observable.error(error)
                }
            }
            .do(onDispose: { [weak self] in
                self?.isLoadingPage = false
                self?.isLoadingRelay.accept(false)
            })
    }
    
}
