//
//  GiftCollectionViewCellViewModel.swift
//  HBD
//
//  Created by 김수경 on 8/26/24.
//

import Foundation
import RxSwift
import RxCocoa


final class GiftCollectionViewCellViewModel {
    
    private var content: PostModel
    private let disposeBag = DisposeBag()
    
    init(_ content: PostModel) {
        self.content = content
    }
    
    var title: String {
        return content.title
    }
    var totalPrice: String {
        return "\(content.totalPrice) 원"
    }
    var deadLine: String {
        guard let due = "\(content.recruitDeadline)".convertDate(.iso8601, to: .yymmdd_dash) else { return "" }
        return "\(due) 마감"
    }
    var personalPrice: String {
        return "\(content.personalPrice) 원"
    }
    var participated: Bool {
        content.likes.contains(UserDefaultsManager.shared.userID) 
    }
    
    var particiapatedPerson: [String] {
        content.likes
    }

    var recruitmentNumber: Int {
        content.recruitment
    }
    
    struct Input {
        let paymentResult: PublishSubject<Bool>
    }
    
    struct Output {
        let giftImageData: Observable<Data?>
        let participatedProfile: BehaviorRelay<[Data]>
        let joinResponse: PublishSubject<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        let joinResponse = PublishSubject<Bool>()
        let participated = BehaviorRelay<[Data]>(value: [])
        
        let profileImage = content.files[0]
        let giftImage =  NetworkManager.shared.readImage(profileImage)
            .map { result -> Data? in
                switch result {
                case .success(let imageData):
                    return imageData
                case .failure(let error):
                    print(error)
                    return nil
                }
            }
            .asObservable()

        let profileIDRequest = particiapatedPerson.map { profile in
            NetworkManager.shared.getOtherProfile(profile)
                .flatMap { result -> Single<Data?> in
                    switch result {
                    case .success(let user):
                        guard let profileImage = user.profileImage else { return .just(nil) }
                        return NetworkManager.shared.readImage(profileImage)
                            .map { newResult in
                                switch newResult {
                                case .success(let data):
                                    return data
                                case .failure(_):
                                    return nil
                                }
                            }
                    case .failure(_):
                        return .just(nil)
                    }
                }
                .asObservable()
        }
        
        Observable.zip(profileIDRequest)
            .subscribe { profileImage in
                participated.accept(profileImage.compactMap { $0 })
            }
            .disposed(by: disposeBag)
        
        input.paymentResult
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .flatMap { value in
                NetworkManager.shared.joinPost(self.content.postID, status: value)
                    .map { result -> Bool? in
                        switch result {
                        case .success(let like):
                            return like.likeStatus
                        case .failure(let error):
                            print(error)
                            return nil
                        }
                    }
            }
            .subscribe(with: self) { owner, response in
                if let response {
                    joinResponse.onNext(response)
                }
            }
            .disposed(by: disposeBag)
        
        
        
        return Output(giftImageData: giftImage, participatedProfile: participated, joinResponse: joinResponse)
    }
  
}
