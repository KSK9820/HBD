//
//  NetworkManager.swift
//  HBD
//
//  Created by 김수경 on 8/15/24.
//

import Foundation
import Alamofire


final class NetworkManager {
    static let decoder = JSONDecoder()
    
    func checkDuplicateEmail(_ email: String) {
        do {
            let request = try HBDRequest.duplicateEmailCheck(email: email).asURLRequest()
            AF.request(request)
                .responseString { response in
                    switch response.result {
                    case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            print(data)
                        case 409:
                            print(data)
                        default:
                            print(data)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func signIn(_ account: SignInQuery) {
        do {
            let request = try HBDRequest.signin(account: account).asURLRequest()
            AF.request(request)
                .responseString { response in
                    switch response.result {
                    case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            print(data)
                        default:
                            print(data)
                        }
                    case .failure(let error):
                        switch response.response?.statusCode {
                        case 409:
                            print(error)
                        default:
                            print(error)
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func login(_ account: LoginQuery) {
        do {
            let request = try HBDRequest.login(account: account).asURLRequest()
            AF.request(request)
                .responseDecodable(of: LoginResponse.self) { response in
                    switch response.result {
                    case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            UserDefaultsManager.shared.accessToken = data.accessToken
                            UserDefaultsManager.shared.refreshToken = data.refreshToken
                        default:
                            print(data)
                        }
                    case .failure(let error):
                        switch response.response?.statusCode {
                        case 401:
                            print(error)
                        default:
                            print(error)
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func getMyProfile() {
        do {
            let request = try HBDRequest.readMyProfile.asURLRequest()
            
            AF.request(request)
                .responseDecodable(of: UserModel.self) { response in
                    switch response.result {
                    case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            print(data)
                        default:
                            break
                        }
                    case .failure(let error):
                        switch  response.response?.statusCode {
                        case 401, 403:
                            print(error)
                        case 419:
                            self.refreshToken { status in
                                switch status {
                                case true:
                                    self.getMyProfile()
                                case false:
                                    print("갱신 실패")
                                }
                            }
                        default:
                            break
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func updateMyProfile(_ profile: UpdateProfileModel) {
        let request = HBDRequest.updateProfile
        
        AF.upload(multipartFormData: { multipart in
            let mirror = Mirror(reflecting: profile)
            for child in mirror.children {
                guard let label = child.label else { continue }
                if let dataValue = child.value as? Data {
                    multipart.append(dataValue, withName: label, fileName: "profile.jpg", mimeType: "image/jpeg")
                } else if let stringValue = child.value as? String {
                    multipart.append(Data(stringValue.utf8), withName: label)
                }
            }
        }, with: request)
        .responseDecodable(of: UserProfileResponse.self) { response in
            switch response.result {
            case .success(let data):
                switch response.response?.statusCode {
                case 200:
                    print(data)
                default:
                    break
                }
            case .failure(let error):
                switch  response.response?.statusCode {
                case 400, 401, 402, 403, 409:
                    print(error)
                case 419:
                    self.refreshToken { status in
                        switch status {
                        case true:
                            self.updateMyProfile(profile)
                        case false:
                            print("갱신 실패")
                        }
                    }
                default:
                    break
                }
            }
        }
    }
    
    func getOtherProfile(_ id: String) {
        do {
            let request = try HBDRequest.readOtherProfile(id: id).asURLRequest()
            
            AF.request(request)
                .responseDecodable(of: UserProfileResponse.self) { response in
                    switch response.result {
                    case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            print(data)
                        default:
                            break
                        }
                    case .failure(let error):
                        switch  response.response?.statusCode {
                        case 401, 403:
                            print(error)
                        case 419:
                            self.refreshToken { status in
                                switch status {
                                case true:
                                    self.getOtherProfile(id)
                                case false:
                                    print("갱신 실패")
                                }
                            }
                        default:
                            break
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    
    func uploadImage(_ images: [Data]) {
        let request = HBDRequest.createImage
        
        AF.upload(multipartFormData: { multipart in
            for image in images {
                multipart.append(image, withName: "files", fileName: image.base64EncodedString() + ".jpg", mimeType: "image/jpg")
            }
        }, with: request)
        .responseDecodable(of: ImageResponse.self) { response in
            switch response.result {
            case .success(let data):
                switch response.response?.statusCode {
                case 200:
                    print(data)
                default:
                    break
                }
            case .failure(let error):
                switch  response.response?.statusCode {
                case 400, 401, 403:
                    print(error)
                case 419:
                    self.refreshToken { status in
                        switch status {
                        case true:
                            self.uploadImage(images)
                        case false:
                            print("갱신 실패")
                        }
                    }
                default:
                    break
                }
            }
        }
    }
    
    func uploadPost(_ post: UploadPostQuery) {
        do {
            let request = try HBDRequest.createPost(post: post).asURLRequest()
            
            AF.request(request)
                .responseDecodable(of: PostResponse.self) { response in
                    switch response.result {
                    case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            print(data)
                        default:
                            break
                        }
                    case .failure(let error):
                        switch  response.response?.statusCode {
                        case 401, 403:
                            print(error)
                        case 419:
                            self.refreshToken { status in
                                switch status {
                                case true:
                                    self.uploadPost(post)
                                case false:
                                    print("갱신 실패")
                                }
                            }
                        default:
                            break
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func getPosts(_ productID: String, page: String) {
        do {
            let request = try HBDRequest.readPosts(productID: productID, page: page).asURLRequest()
            
            AF.request(request)
                .responseDecodable(of: PostsResponse.self) { response in
                    switch response.result {
                    case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            for i in data.data {
                                print(i.convertToPostModel())
                                print(data)
                            }
                        default:
                            break
                        }
                    case .failure(let error):
                        switch  response.response?.statusCode {
                        case 401, 403:
                            print(error)
                        case 419:
                            self.refreshToken { status in
                                switch status {
                                case true:
                                    self.getPosts(productID, page: page)
                                case false:
                                    print("갱신 실패")
                                }
                            }
                        default:
                            break
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func getaPost(_ postID: String) {
        do {
            let request = try HBDRequest.readPost(postID: postID).asURLRequest()
            
            AF.request(request)
                .responseDecodable(of: PostResponse.self) { response in
                    switch response.result {
                    case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            print(data)
                        default:
                            break
                        }
                    case .failure(let error):
                        switch  response.response?.statusCode {
                        case 401, 403:
                            print(error)
                        case 419:
                            self.refreshToken { status in
                                switch status {
                                case true:
                                    self.getaPost(postID)
                                case false:
                                    print("갱신 실패")
                                }
                            }
                        default:
                            break
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func deletePost(_ postID: String) {
        do {
            let request = try HBDRequest.deletePost(postID: postID).asURLRequest()
            
            AF.request(request)
                .response { response in
                    switch response.result {
                    case .success(_):
                        switch response.response?.statusCode {
                        case 200:
                            print("deleted")
                        default:
                            break
                        }
                    case .failure(let error):
                        switch  response.response?.statusCode {
                        case 401, 403, 410, 445:
                            print(error)
                        case 419:
                            self.refreshToken { status in
                                switch status {
                                case true:
                                    self.deletePost(postID)
                                case false:
                                    print("갱신 실패")
                                }
                            }
                        default:
                            break
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func joinPost(_ postID: String, status: Bool) {
        do {
            let request = try HBDRequest.joinPost(postID: postID, status: status).asURLRequest()
            
            AF.request(request)
                .responseDecodable(of: LikeDTO.self) { response in
                    switch response.result {
                    case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            print(data)
                        default:
                            break
                        }
                    case .failure(let error):
                        switch  response.response?.statusCode {
                        case 401, 403, 410, 445:
                            print(error)
                        case 419:
                            self.refreshToken { status in
                                switch status {
                                case true:
                                    self.joinPost(postID, status: status)
                                case false:
                                    print("갱신 실패")
                                }
                            }
                        default:
                            break
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func updatePost(_ postID: String, post: UploadPostQuery) {
        do {
            let request = try HBDRequest.updatePost(postID: postID, post: post).asURLRequest()
            
            AF.request(request)
                .responseDecodable(of: PostResponse.self) { response in
                    switch response.result {
                    case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            print(data)
                        default:
                            break
                        }
                    case .failure(let error):
                        switch  response.response?.statusCode {
                        case 400, 401, 403, 410:
                            print(error)
                        case 419:
                            self.refreshToken { status in
                                switch status {
                                case true:
                                    self.updatePost(postID, post: post)
                                case false:
                                    print("갱신 실패")
                                }
                            }
                        case 445:
                            print(error)
                        default:
                            break
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func searchUser(_ nickname: String) {
        do {
            let request = try HBDRequest.searchUser(nickname: nickname).asURLRequest()
            
            AF.request(request)
                .responseDecodable(of: SearchUserReponse.self) { response in
                    switch response.result {
                    case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            print(data)
                        default:
                            break
                        }
                    case .failure(let error):
                        switch  response.response?.statusCode {
                        case 401, 403:
                            print(error)
                        case 419:
                            self.refreshToken { status in
                                switch status {
                                case true:
                                    self.searchUser(nickname)
                                case false:
                                    print("갱신 실패")
                                }
                            }
                        default:
                            break
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func followUser(_ userID: String) {
        do {
            let request = try HBDRequest.followUser(userID: userID).asURLRequest()
            
            AF.request(request)
                .responseDecodable(of: FollowUserResponse.self) { response in
                    switch response.result {
                    case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            print(data)
                        default:
                            break
                        }
                    case .failure(let error):
                        switch  response.response?.statusCode {
                        case 400, 401, 403, 409, 410:
                            print(error)
                        case 419:
                            self.refreshToken { status in
                                switch status {
                                case true:
                                    self.followUser(userID)
                                case false:
                                    print("갱신 실패")
                                }
                            }
                        default:
                            break
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func followCancel(_ userID: String) {
        do {
            let request = try HBDRequest.followCancel(userID: userID).asURLRequest()
            
            AF.request(request)
                .responseDecodable(of: FollowUserResponse.self) { response in
                    switch response.result {
                    case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            print(data)
                        default:
                            break
                        }
                    case .failure(let error):
                        switch  response.response?.statusCode {
                        case 400, 401, 403, 409, 410:
                            print(error)
                        case 419:
                            self.refreshToken { status in
                                switch status {
                                case true:
                                    self.followUser(userID)
                                case false:
                                    print("갱신 실패")
                                }
                            }
                        default:
                            break
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    private func refreshToken(_ completion: @escaping (Bool) -> Void ) {
        do {
            let request = try HBDRequest.refreshToken.asURLRequest()
            struct RefreshToken: Decodable {
                let accessToken: String
            }
            AF.request(request)
                .responseDecodable(of: RefreshToken.self) { response in
                    switch response.result {
                    case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            UserDefaultsManager.shared.accessToken = data.accessToken
                            completion(true)
                        default:
                            print(data)
                        }
                    case .failure(let error):
                        switch response.response?.statusCode {
                        case 401, 403, 418:
                            completion(false)
                            print(error)
                        default:
                            break
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
}
