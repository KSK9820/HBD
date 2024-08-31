//
//  FollowCollectionViewModel.swift
//  HBD
//
//  Created by 김수경 on 8/30/24.
//

import Foundation
import RxSwift
import RxCocoa

final class FollowCollectionViewModel {
    
    private var user: SearchUser?
    
    private let disposeBag = DisposeBag()
    
    var isFollowing: Bool? {
        user?.isFollowing
    }
    var userID: String? {
        user?.userID
    }
    
    func initUser() {
        self.user = nil 
    }
    
    func setUser(_ user: SearchUser) {
        self.user = user
    }
    
    func setFollowing(_ isFollow: Bool) {
        user?.isFollowing = isFollow
    }
    
    struct Input {
        let follow: PublishSubject<String>
        let unfollow: PublishSubject<String>
    }
    
    struct Output {
        let followResult: PublishSubject<Bool>
        let unfollowResult: PublishSubject<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        let follow = PublishSubject<Bool>()
        let unfollow = PublishSubject<Bool>()
        
        input.follow
            .flatMap {
                NetworkManager.shared.followCancel($0)
            }
            .map { response in
                switch response {
                case .success(let result):
                    return result
                case .failure(_):
                    return false
                }
            }
            .subscribe { value in
                if value {
                    unfollow.onNext(true)
                }
            }
            .disposed(by: disposeBag)
        
        input.unfollow
            .flatMap {
                NetworkManager.shared.followUser($0)
            }
            .map { response in
                switch response {
                case .success(let result):
                    return result
                case .failure(_):
                    return false
                }
            }
            .subscribe { value in
                if value {
                    follow.onNext(true)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(followResult: follow, unfollowResult: unfollow)
    }
    
    
    
}
