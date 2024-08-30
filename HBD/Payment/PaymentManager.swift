//
//  PaymentManager.swift
//  HBD
//
//  Created by 김수경 on 8/29/24.
//

import iamport_ios
import UIKit
import RxSwift

final class PaymentManager {
    
    static let shared = PaymentManager()
    
    private init() {}
    
    private let disposeBag = DisposeBag()
    
    func pay(price: String, itemName: String, nav: UINavigationController, postID: String) -> Single<Bool> {
        
        guard let apiKey = Bundle.main.infoDictionary?["SesacKey"] as? String else { return Single.just(false) }
        
        let payment = IamportPayment(pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
                                     merchant_uid: "ios_\(apiKey)_\(Date().timeIntervalSince1970))",
                                     amount: price).then {
            $0.pay_method = PayMethod.card.rawValue
            $0.name = "HBD_" + itemName
            $0.buyer_name = UserDefaultsManager.shared.userName
            $0.app_scheme = "HBD_SCHEME"
        }
        
        return Single<Bool>.create { single in
            Iamport.shared.payment(navController: nav,
                                   userCode: "imp57573124",
                                   payment: payment) { iamportResponse in
                guard let impUID = iamportResponse?.imp_uid else {
                    return single(.success(false))
                }
                let paymentQuery = PaymentQuery(impUID: impUID, postID: postID)
                
                NetworkManager.shared.paymentValidation(paymentQuery)
                    .subscribe { response in
                        switch response {
                        case .success(_):
                            single(.success(true))
                        case .failure(_):
                            single(.success(false))
                        }
                    } onFailure: { error in
                        single(.success(false))
                    }
                    .disposed(by: self.disposeBag)

            }
            return Disposables.create()
        }
    }
    
}
