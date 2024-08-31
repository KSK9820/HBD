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
        let emptyName: BehaviorSubject<String>
    }
    
    struct Output {
        let searchNameResult: PublishSubject<[SearchUser]>
    }
    
    func transform(_ input: Input) -> Output {
        let followSearchList = PublishSubject<(String, [String])>()
        let searchNameResult = PublishSubject<[SearchUser]>()
        
        input.searchName
            .flatMap { searchName in
                return NetworkManager.shared.getMyProfile()
                    .map { response in
                        switch response {
                        case .success(let myProfile):
                            let followingUserID = myProfile.following.map { $0.userID }
                            return (searchName, followingUserID)
                        case .failure(_):
                            return (searchName, [])
                        }
                    }
            }
            .subscribe(onNext: { result in
                followSearchList.onNext(result)
            })
            .disposed(by: disposeBag)
        
        input.emptyName
            .flatMap { _ in
                NetworkManager.shared.getMyProfile()
                    .map { response in
                        switch response {
                        case .success(let myProfile):
                            let following = myProfile.following.map { $0.convertToSearchUser() }
                            return following
                        case .failure(_):
                            return []
                        }
                    }
            }
            .subscribe { follow in
                searchNameResult.onNext(follow)
            }
            .disposed(by: disposeBag)
        
            
        followSearchList
            .flatMap { (searchName, followingList) in
                NetworkManager.shared.searchUser(searchName)
                    .map { response in
                        switch response {
                        case .success(let users):
                            var searchUser = users
                            for user in users.indices {
                                if followingList.contains(users[user].userID) {
                                    searchUser[user].isFollowing = true
                                }
                            }
                            return searchUser
                        case .failure(_):
                            return []
                        }
                    }
            }
            .subscribe { searchResult in
                searchNameResult.onNext(searchResult)
            }
            .disposed(by: disposeBag)
            
        return Output(searchNameResult: searchNameResult)
    }
    
}
