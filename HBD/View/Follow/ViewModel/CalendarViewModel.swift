//
//  CalendarViewModel.swift
//  HBD
//
//  Created by 김수경 on 9/1/24.
//

import Foundation
import RxSwift
import RxCocoa

extension CalendarViewModel {
    typealias birth = [CalendarBirthDay : [Follow]]
}

final class CalendarViewModel {
    
    private(set) var followInformation = birth()
    private(set) var followBirthday = [DateComponents]()

    private let disposeBag = DisposeBag()
    
    struct Input {
        let load: BehaviorRelay<Void>
        let selectDay: PublishSubject<DateComponents>
    }
    
    struct Output {
        let birthdayUser: PublishSubject<[Follow]>
    }
    
    func transform(_ input: Input) -> Output {
        let birthdayUser = PublishSubject<[Follow]>()
        
        input.load
            .flatMap { _  in
                NetworkManager.shared.getMyProfile()
                    .map { response -> birth in
                        switch response {
                        case .success(let myProfile):
                            var birthInformation = birth()
                            
                            for follow in myProfile.following {
                                if let birthdayValue = follow.birthDay {
                                    let birthday = CalendarBirthDay.convert(birthdayValue)
                                    if birthInformation[birthday] != nil {
                                        birthInformation[birthday]?.append(follow)
                                    } else {
                                        birthInformation[birthday] = [follow]
                                    }
                                }
                            }
                            return birthInformation
                        case .failure(_):
                            return [:]
                        }
                    }
            }
            .subscribe(with: self) { owner, birth in
                owner.followInformation = birth
                owner.followBirthday = birth.map {
                    DateComponents(year: 2024, month: $0.key.month, day: $0.key.day)
                }
                print(owner.followBirthday)
            }
            .disposed(by: disposeBag)
        
        input.selectDay
            .map {
                let day = CalendarBirthDay(month: $0.month!, day: $0.day!)
                
                if self.followInformation[day] == nil {
                    return []
                } else {
                    return self.followInformation[day]!
                }
            }
            .subscribe(with: self) { owner, value in
                birthdayUser.onNext(value)
            }
            .disposed(by: disposeBag)
        
        
        return Output(birthdayUser: birthdayUser)
    }
}
