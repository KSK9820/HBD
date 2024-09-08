//
//  CalendarBirthDay.swift
//  HBD
//
//  Created by 김수경 on 9/1/24.
//

import Foundation

struct CalendarBirthDay: Hashable {
    let month: Int
    let day: Int
    
    static func convert(_ birth: String) -> Self {
        let input = birth.split(separator: ".")
        
        return CalendarBirthDay(month: Int(input[1])!, day: Int(input[2])!)
    }
}
