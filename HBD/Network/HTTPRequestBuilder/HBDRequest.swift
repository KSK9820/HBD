//
//  HBDRequest.swift
//  HBD
//
//  Created by 김수경 on 8/15/24.
//

import Foundation
import Alamofire

enum HBDRequest {
    static let encoder = JSONEncoder()
    
    case refreshToken

    case duplicateEmailCheck(email: String)
    case signin(account: SignInQuery)
    case login(account: LoginQuery)
    
    case readMyProfile
    case readOtherProfile(id: String)
    case updateProfile
    
    case createImage
    case createPost(post: UploadPostQuery)
    case readPost(postID: String)
    case readPosts(productID: String, page: String)
    case deletePost(postID: String)
    case updatePost(postID: String, post: UploadPostQuery)
    case joinPost(postID: String, status: Bool)
    
    case searchUser(nickname: String)
    case followUser(userID: String)
    case followCancel(userID: String)
    
}

extension HBDRequest: HTTPRequestable {
    
    private var apiKey: String {
        get throws {
            guard let apiKey = Bundle.main.infoDictionary?["SesacKey"] as? String
            else {
                throw NetworkError.notFoundAPIKey
            }
            return apiKey
        }
    }
    
    var scheme: String {
        "http"
    }
    
    var baseURLString: String {
        get throws {
            guard let baseURL = Bundle.main.infoDictionary?["BaseURL"] as? String
            else {
                throw NetworkError.notFoundBaseURL
            }
            return baseURL
        }
    }
    
    var portNum: Int? {
        get throws {
            guard let port = Bundle.main.infoDictionary?["PortNum"] as? String
                    
            else {
                throw NetworkError.InvalidPortNum
            }
            return Int(port)
        }
    }
    
    
    var httpMethod: Alamofire.HTTPMethod {
        switch self {
        case .duplicateEmailCheck, .signin, .login, .createImage, .createPost, .joinPost, .followUser:
                .post
        case .refreshToken, .readMyProfile, .readOtherProfile, .readPost, .readPosts, .searchUser:
                .get
        case .updateProfile, .updatePost:
                .put
        case .deletePost, .followCancel:
                .delete
        }
    }
    
    var version: RequestVersion {
        .v1
    }
    
    var path: [String] {
        switch self {
        case .duplicateEmailCheck:
            ["validation", "email"]
        case .signin:
            ["users", "join"]
        case .login:
            ["users", "login"]
        case .refreshToken:
            ["auth", "refresh"]
        case .readMyProfile, .updateProfile:
            ["users", "me", "profile"]
        case .readOtherProfile(let id):
            ["users", id, "profile"]
        case .createImage:
            ["posts", "files"]
        case .createPost, .readPosts:
            ["posts"]
        case .readPost(let id), .deletePost(let id), .updatePost(let id, _):
            ["posts", id]
        case .joinPost(let id, _):
            ["posts", id, "like"]
        case .searchUser:
            ["users", "search"]
        case .followUser(let id), .followCancel(let id):
            ["follow", id]
        }
    }
    
    var queries: [URLQueryItem]? {
        switch self {
        case .readPosts(let id, let page):
            return [
                URLQueryItem(name: "next", value: page),
                URLQueryItem(name: "product_id", value: id)
            ]
        case .searchUser(let nickname):
            return [
                URLQueryItem(name: "nick", value: nickname)
            ]
        default:
            return nil
        }
    }
    
    var httpHeaders: [String : String]? {
        do {
            switch self {
            case .duplicateEmailCheck, .signin, .login:
                return [
                    HeaderContents.contentType.rawValue : HeaderContents.json.rawValue,
                    HeaderContents.sesacKey.rawValue : try apiKey
                ]
            case .refreshToken:
                return [
                    HeaderContents.authorization.rawValue : UserDefaultsManager.shared.accessToken,
                    HeaderContents.sesacKey.rawValue : try apiKey,
                    HeaderContents.refresh.rawValue : UserDefaultsManager.shared.refreshToken
                ]
            case .readMyProfile, .readOtherProfile, .readPost, .readPosts, .deletePost, .searchUser, .followUser, .followCancel:
                return [
                    HeaderContents.sesacKey.rawValue : try apiKey,
                    HeaderContents.authorization.rawValue : UserDefaultsManager.shared.accessToken
                ]
            case .updateProfile, .createImage:
                return [
                    HeaderContents.authorization.rawValue : UserDefaultsManager.shared.accessToken,
                    HeaderContents.contentType.rawValue : HeaderContents.multi.rawValue,
                    HeaderContents.sesacKey.rawValue : try apiKey
                ]
            case .createPost, .joinPost, .updatePost:
                return [
                    HeaderContents.authorization.rawValue : UserDefaultsManager.shared.accessToken,
                    HeaderContents.contentType.rawValue : HeaderContents.json.rawValue,
                    HeaderContents.sesacKey.rawValue : try apiKey
                ]
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    var httpBody: Data? {
        switch self {
        case .duplicateEmailCheck(let email):
            do {
                struct EmailQuery: Encodable {
                    let email: String
                }
                
                let query = EmailQuery(email: email)
                return try HBDRequest.encoder.encode(query)
            } catch {
                print(error)
            }
            return nil
        case .signin(let account):
            do {
                return try HBDRequest.encoder.encode(account)
            } catch {
                print(error)
            }
            return nil
        case .login(let account):
            do {
                return try HBDRequest.encoder.encode(account)
            } catch {
                print(error)
            }
            return nil
        case .createPost(let post), .updatePost(_, let post):
            do {
                return try HBDRequest.encoder.encode(post)
            } catch {
                print(error)
            }
            return nil
        case .joinPost(_, let status):
            do {
                let likeQuery = LikeDTO(likeStatus: status)
                return try HBDRequest.encoder.encode(likeQuery)
            } catch {
                print(error)
            }
            return nil
            
        default:
            return nil
        }
    }
}
