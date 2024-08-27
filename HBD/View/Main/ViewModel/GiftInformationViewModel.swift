//
//  GiftInformationViewModel.swift
//  HBD
//
//  Created by 김수경 on 8/27/24.
//

import Foundation
import RxSwift

final class GiftInformationViewModel {

    let content: PostModel
    
    var title: String {
        content.title
    }
    var totalPrice: String {
        "\(content.price)원"
    }
    var recruitmentNumber: String {
        "\(content.recruitment)명"
    }
    var personalPrice: String {
        "\(content.price / content.recruitment)원"
    }
    var deadLine: String? {
        "\(content.recruitDeadline)".convertDate(.iso8601, to: .yymmdd_dash)
    }
    
    init(content: PostModel) {
        self.content = content
    }
    
    struct Input {
        
    }
    
    struct Output {
        let giftImageData: Observable<Data?>
    }
    
    func transform(_ input: Input) -> Output {
        
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
        
        return Output(giftImageData: giftImage)
    }
}
