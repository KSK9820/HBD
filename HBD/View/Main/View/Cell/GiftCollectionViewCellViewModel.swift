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
        return "\(content.price) 원 / \(content.recruitment) 명"
    }
    var deadLine: String {
        guard let due = "\(content.recruitDeadline)".convertDate(.iso8601, to: .yymmdd_dash) else { return "" }
        return "\(due) 마감"
    }
    var buttonPrice: String {
        return "\(content.price / content.recruitment) 원"
    }
    var participated: Bool {
        content.likes.contains(UserDefaultsManager.shared.userID) 
    }
    
    struct Input {
        let joinButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let giftImageData: Observable<Data?>
        let joinResponse: PublishSubject<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        let joinResponse = PublishSubject<Bool>()
        
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
        
        
        input.joinButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .flatMap {
                NetworkManager.shared.joinPost(self.content.postID, status: true)
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
        
        return Output(giftImageData: giftImage, joinResponse: joinResponse)
    }
  
}
