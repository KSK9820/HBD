//
//  MyPaymentViewModel.swift
//  HBD
//
//  Created by 김수경 on 9/1/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MyPaymentViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let load: BehaviorRelay<Void>
    }
    
    struct Output {
        let paidPosts: PublishSubject<[PostModel]>
    }
    
    func transform(_ input: Input) -> Output {
        let paymentList = PublishSubject<[PaymentResponse]>()
        let paymentPost = PublishSubject<[PostModel]>()
        
        input.load
            .flatMap { _  in
                NetworkManager.shared.getPaymentsList()
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
                paymentList.onNext(value)
            }
            .disposed(by: disposeBag)
        
        paymentList
            .flatMap { items in
                // 모든 항목을 Observable로 변환
                Observable.from(items)
                    .concatMap { value in
                        NetworkManager.shared.getaPost(value.postID)
                            .asObservable()
                            .compactMap { result in
                                switch result {
                                case .success(let data):
                                    return data
                                case .failure(_):
                                    return nil
                                }
                            }
                    }
                    .toArray()
            }
            .subscribe { postArray in
                paymentPost.onNext(postArray)
            }
            .disposed(by: disposeBag)
        
        return Output(paidPosts: paymentPost)
    }
}
