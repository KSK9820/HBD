//
//  String+Extension.swift
//  HBD
//
//  Created by 김수경 on 8/20/24.
//

import Foundation

extension String {
    enum StringDateFormat: String {
        case yyyyMMdd
        case iso8601 = "yyyy-MM-dd HH:mm:ss Z"
        case yymmdd_dash = "yy-MM-dd"
        
    }
    
    func convertDate(_ from: StringDateFormat, to: StringDateFormat) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = from.rawValue
        
        guard let date = dateFormatter.date(from: self) else {
            return nil
        }
        
        dateFormatter.dateFormat = to.rawValue
        return dateFormatter.string(from: date)
    }
    
    func convertToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: self) ?? Date()
        return date
    }

}

