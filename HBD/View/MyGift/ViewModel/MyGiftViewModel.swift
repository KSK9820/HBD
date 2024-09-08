//
//  MyGiftViewModel.swift
//  HBD
//
//  Created by 김수경 on 9/1/24.
//

import Foundation

import Foundation
import RxSwift
import RxCocoa

final class MyGiftViewModel {

    private var cursor: String = ""
    private var isLoadingPage = false
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let load: BehaviorRelay<Void>
        let postPrefetchItemsTrigger: ControlEvent<[IndexPath]>
    }
    
    struct Output {
        let myGiftPost: BehaviorRelay<[PostModel]>
    }
    
    func transform(_ input: Input) -> Output {
        let myGiftPost = BehaviorRelay<[PostModel]>(value: [])
        
        var cursor = ""
        
        input.load
            .flatMap { _  in
                NetworkManager.shared.getPosts(UserDefaultsManager.shared.userID, page: cursor)
                    .map { response in
                        switch response {
                        case .success(let data):
                            cursor = data.nextCursor
                            return data.data.map { $0.convertToPostModel() }
                        case .failure(_):
                            return []
                        }
                    }
            }
            .subscribe(with: self) { owner, value in
                myGiftPost.accept(value)
            }
            .disposed(by: disposeBag)
        
        input.postPrefetchItemsTrigger
            .observe(on: MainScheduler.instance)
            .flatMap { indexPaths -> Observable<[PostModel]> in
               
                return self.fetchPostItems(cursorPage: self.cursor)
            }.subscribe(with: self) { owner, value in
                myGiftPost.accept(myGiftPost.value + value)
            }
            .disposed(by: disposeBag)
        
       
        
        return Output(myGiftPost: myGiftPost)
    }
    
    private func fetchPostItems(cursorPage: String) -> Observable<[PostModel]> {
        guard !isLoadingPage else { return .empty() }
        guard cursor != "0" else { return .empty() }
        isLoadingPage = true
        
        return NetworkManager.shared.getPosts(UserDefaultsManager.shared.userID, page: cursor)
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
            })
    }
}
