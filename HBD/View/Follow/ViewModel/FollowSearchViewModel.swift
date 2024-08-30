//
//  FollowSearchViewModel.swift
//  HBD
//
//  Created by 김수경 on 8/29/24.
//

import Foundation
import RxSwift
import RxCocoa

final class FollowSearchViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let searchName: PublishRelay<String>
    }
    
    struct Output {
        let searchNameResult: PublishSubject<[Follow]>
    }
    
    func transform(_ input: Input) -> Output {
        let searchNameResult = PublishSubject<[Follow]>()
        
        input.searchName
            .flatMap {
                NetworkManager.shared.searchUser($0)
            }
            .subscribe(with: self) { _, response in
                switch response {
                case .success(let searchResult):
                    searchNameResult.onNext(searchResult)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(searchNameResult: searchNameResult)
    }
    
}
