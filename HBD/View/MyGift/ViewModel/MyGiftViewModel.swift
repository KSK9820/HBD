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

    private let disposeBag = DisposeBag()
    
    struct Input {
        let load: BehaviorRelay<Void>
    }
    
    struct Output {
        let myGiftPost: PublishSubject<[PostModel]>
    }
    
    func transform(_ input: Input) -> Output {
        let myGiftPost = PublishSubject<[PostModel]>()
        
        input.load
            .flatMap { _  in
                NetworkManager.shared.getPosts(UserDefaultsManager.shared.userID, page: "")
                    .map { response in
                        switch response {
                        case .success(let data):
                            return data
                        case .failure(_):
                            return []
                        }
                    }
            }
            .subscribe(with: self) { owner, value in
                myGiftPost.onNext(value)
            }
            .disposed(by: disposeBag)
        
        
        
        return Output(myGiftPost: myGiftPost)
    }
}
