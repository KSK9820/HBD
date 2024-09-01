//
//  PaymentsListResponse.swift
//  HBD
//
//  Created by 김수경 on 9/1/24.
//

import Foundation

struct PaymentsListResponse: Decodable {
    let data: [PaymentResponse]
}

