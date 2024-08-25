//
//  GiftCollectionViewCellViewModel.swift
//  HBD
//
//  Created by 김수경 on 8/26/24.
//

import Foundation
import Alamofire
import Kingfisher

final class GiftCollectionViewCellViewModel {
    
    private var content: PostModel
    
    init(_ content: PostModel) {
        self.content = content
    }
    
    private var image: HTTPRequestable {
        return HBDRequest.readImage(link: content.files[0])
    }
    
    var imageURL: URL {
        do {
            return try image.asURL()
        } catch {
            return URL(string: "")!
        }
    }
    
    // MARK: - HBDRequest에서 이미지 Data만 받아오게 변경 필요

    var headerModifier: AnyModifier {
        return AnyModifier { request in
            var req = request
            if let header = self.image.httpHeaders {
                req.headers = HTTPHeaders(header)
            }
            return req
        }
    }
    
    var title: String {
        return content.title
    }
    var totalPrice: String {
        return "\(content.price) 원"
    }
    var deadLine: String {
        guard let due = "\(content.recruitDeadline)".convertDate(.iso8601, to: .yymmdd_dash) else { return "" }
        return "\(due) 마감"
    }
    var buttonPrice: String {
        return "\(content.price / content.recruitment) 원"
    }
}
