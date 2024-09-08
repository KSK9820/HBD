//
//  PostGiftViewModel.swift
//  HBD
//
//  Created by 김수경 on 8/28/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PostGiftViewModel {
    
    let followingID: String
    
    init(followingID: String) {
        self.followingID = followingID
    }
    
    var recruitmentNum: [String] {
        return [Int](2...10).map { "\($0)" }
    }
    
    struct Input {
        let imageData: Observable<[Data]>
        let postModelData: Observable<UploadPostQuery>
    }
    
    struct Output {
        let stringImageData: Observable<[String]>
        let postResult: Observable<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        let stringImageData = input.imageData
            .flatMap {
                NetworkManager.shared.uploadImage($0)
                    .asObservable()
            }
            .map { response in
                
                switch response {
                case .success(let value):
                    return value
                case .failure(let error):
                    print(error)
                    return nil
                }
            }
            .compactMap { $0 }

        let postData = input.postModelData
            .flatMap { value in
                NetworkManager.shared.uploadPost(value)
            }
            .map { response in
                switch response {
                case .success(_):
                    return true
                case .failure(let error):
                    print(error)
                    return false
                }
            }
            .compactMap { $0 }
            
        return Output(stringImageData: stringImageData, postResult: postData)
    }
}
