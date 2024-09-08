//
//  UserDefaultsManager.swift
//  HBD
//
//  Created by 김수경 on 8/18/24.
//

import Foundation

@propertyWrapper
struct UserDefaultType<T: Codable> {
    let key: String
    let defaultValue: T
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.data(forKey: key) else {
                return defaultValue
            }
            let decodedValue = try? JSONDecoder().decode(T.self, from: data)
            return decodedValue ?? defaultValue
        }
        set {
            let encodedData = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.setValue(encodedData, forKey: key)
        }
    }
    
}


final class UserDefaultsManager {
    
    enum UserDefaultsKey: String {
        case access
        case refresh
        case userID
        case userName
    }
    
    static let shared = UserDefaultsManager()
    
    private init() {}
    
    @UserDefaultType(key: UserDefaultsKey.access.rawValue, defaultValue: "")
    var accessToken: String
    
    @UserDefaultType(key: UserDefaultsKey.refresh.rawValue, defaultValue: "")
    var refreshToken: String
    
    @UserDefaultType(key: UserDefaultsKey.userID.rawValue, defaultValue: "")
    var userID: String
    
    @UserDefaultType(key: UserDefaultsKey.userName.rawValue, defaultValue: "")
    var userName: String
    
}
