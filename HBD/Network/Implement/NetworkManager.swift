//
//  NetworkManager.swift
//  HBD
//
//  Created by 김수경 on 8/15/24.
//

import Foundation
import Alamofire
import RxSwift


final class NetworkManager {
    
    static let shared = NetworkManager()
    static let decoder = JSONDecoder()
    private let disposeBag = DisposeBag()
    
    private init() {}
    
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
                            UserDefaultsManager.shared.userID = data.userID
                            UserDefaultsManager.shared.userName = data.nick
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
    
    func getMyProfile() -> Single<Result<UserModel, Error>> {
        return Single.create { single -> Disposable in
            do {
                let request = try HBDRequest.readMyProfile.asURLRequest()
                
                AF.request(request)
                    .responseDecodable(of: UserModel.self) { response in
                        switch response.result {
                        case .success(let data):
                            switch response.response?.statusCode {
                            case 200:
                                print(data)
                                single(.success(.success(data)))
                            default:
                                break
                            }
                        case .failure(let error):
                            switch  response.response?.statusCode {
                            case 401, 403:
                                single(.success(.failure(error)))
                            case 419:
                                self.refreshToken()
                                    .subscribe(with: self) { owner, response in
                                        switch response {
                                        case .success(_):
                                            owner.getMyProfile()
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                    .disposed(by: self.disposeBag)
                            default:
                                break
                            }
                        }
                    }
            } catch {
                print(error)
            }
            return Disposables.create()
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
                    self.refreshToken()
                        .subscribe(with: self) { owner, response in
                            switch response {
                            case .success(_):
                                owner.updateMyProfile(profile)
                            case .failure(let error):
                                print(error)
                            }
                        }
                        .disposed(by: self.disposeBag)
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
                            self.refreshToken()
                                .subscribe(with: self) { owner, response in
                                    switch response {
                                    case .success(_):
                                        owner.getOtherProfile(id)
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                                .disposed(by: self.disposeBag)
                        default:
                            break
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func uploadImage(_ images: [Data]) -> Single<Result<[String], Error>> {
        return Single.create { single -> Disposable in
            do {
                let request = try HBDRequest.createImage.asURLRequest()
                
                AF.upload(multipartFormData: { multipart in
                    for image in images {
                        multipart.append(image, withName: "files", fileName: UUID().uuidString + ".jpeg", mimeType: "image/jpeg")
                    }
                }, with: request)
                .responseDecodable(of: ImageResponse.self) { response in
                    switch response.result {
                    case .success(let data):
                        switch response.response?.statusCode {
                        case 200:
                            single(.success(.success(data.files)))
                        default:
                            break
                        }
                    case .failure(let error):
                        switch  response.response?.statusCode {
                        case 400, 401, 403:
                            single(.success(.failure(NetworkError.emptyDataError)))
                        case 419:
                            self.refreshToken()
                                .subscribe(with: self) { owner, response in
                                    switch response {
                                    case .success(_):
                                        owner.uploadImage(images)
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                                .disposed(by: self.disposeBag)
                        default:
                            break
                        }
                    }
                }
            }
            catch {
                print(error)
            }

            return Disposables.create()
        }
    }
    
    func uploadPost(_ post: UploadPostQuery) -> Single<Result<PostModel, Error>> {
        return Single.create { single -> Disposable in
            do {
                let request = try HBDRequest.createPost(post: post).asURLRequest()
                
                AF.request(request)
                    .responseDecodable(of: PostResponse.self) { response in
                        switch response.result {
                        case .success(let data):
                            switch response.response?.statusCode {
                            case 200:
                                single(.success(.success(data.convertToPostModel())))
                            default:
                                break
                            }
                        case .failure(let error):
                            switch  response.response?.statusCode {
                            case 401, 403:
                                single(.success(.failure(NetworkError.emptyDataError)))
                            case 419:
                                self.refreshToken()
                                    .subscribe(with: self) { owner, response in
                                        switch response {
                                        case .success(_):
                                            owner.uploadPost(post)
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                    .disposed(by: self.disposeBag)
                            default:
                                break
                            }
                        }
                    }
            } catch {
                print(error)
            }
            return Disposables.create()
        }
    }
    
    func getPosts(_ productID: String, page: String) -> Single<Result<[PostModel], Error>> {
        return Single.create { single -> Disposable in
            do {
                let request = try HBDRequest.readPosts(productID: productID, page: page).asURLRequest()
                
                AF.request(request)
                    .responseDecodable(of: PostsResponse.self) { response in
                        switch response.result {
                        case .success(let posts):
                            switch response.response?.statusCode {
                            case 200:
                                var postModel = [PostModel]()
                                for post in posts.data {
                                    postModel.append(post.convertToPostModel())
                                }
                                single(.success(.success(postModel)))
                            default:
                                break
                            }
                        case .failure(let error):
                            switch  response.response?.statusCode {
                            case 401, 403:
                                single(.success(.failure(NetworkError.emptyDataError)))
                            case 419:
                                self.refreshToken()
                                    .subscribe(with: self) { owner, response in
                                        switch response {
                                        case .success(_):
                                            owner.getPosts(productID, page: page)
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                    .disposed(by: self.disposeBag)
                            default:
                                break
                            }
                        }
                    }
            } catch {
                print(error)
            }
            return Disposables.create()
        }
    }
    
    func getaPost(_ postID: String) -> Single<Result<PostModel, Error>> {
        return Single.create { single -> Disposable in
            do {
                let request = try HBDRequest.readPost(postID: postID).asURLRequest()
                
                AF.request(request)
                    .responseDecodable(of: PostResponse.self) { response in
                        switch response.result {
                        case .success(let post):
                            switch response.response?.statusCode {
                            case 200:
                                single(.success(.success(post.convertToPostModel())))
                            default:
                                break
                            }
                        case .failure(let error):
                            switch  response.response?.statusCode {
                            case 401, 403:
                                single(.success(.failure(NetworkError.emptyDataError)))
                            case 419:
                                self.refreshToken()
                                    .subscribe(with: self) { owner, response in
                                        switch response {
                                        case .success(_):
                                            owner.getaPost(postID)
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                    .disposed(by: self.disposeBag)
                            default:
                                break
                            }
                        }
                    }
            } catch {
                print(error)
            }
            return Disposables.create()
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
                            self.refreshToken()
                                .subscribe(with: self) { owner, response in
                                    switch response {
                                    case .success(_):
                                        owner.deletePost(postID)
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                                .disposed(by: self.disposeBag)
                        default:
                            break
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func joinPost(_ postID: String, status: Bool) ->  Single<Result<LikeDTO, Error>> {
        return Single.create { single -> Disposable in
            do {
                let request = try HBDRequest.joinPost(postID: postID, status: status).asURLRequest()
                
                AF.request(request)
                    .responseDecodable(of: LikeDTO.self) { response in
                        switch response.result {
                        case .success(let data):
                            switch response.response?.statusCode {
                            case 200:
                                single(.success(.success(data)))
                            default:
                                break
                            }
                        case .failure(let error):
                            switch  response.response?.statusCode {
                            case 401, 403, 410, 445:
                                single(.success(.failure(error)))
                                print(error)
                            case 419:
                                self.refreshToken()
                                    .subscribe(with: self) { owner, response in
                                        switch response {
                                        case .success(_):
                                            owner.joinPost(postID, status: status)
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                    .disposed(by: self.disposeBag)
                            default:
                                break
                            }
                        }
                    }
            } catch {
                print(error)
            }
            return Disposables.create()
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
                            self.refreshToken()
                                .subscribe(with: self) { owner, response in
                                    switch response {
                                    case .success(_):
                                        owner.updatePost(postID, post: post)
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                                .disposed(by: self.disposeBag)
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
    
    func searchUser(_ nickname: String)  ->  Single<Result<[SearchUser], Error>> {
        return Single.create { single -> Disposable in
            do {
                let request = try HBDRequest.searchUser(nickname: nickname).asURLRequest()
                
                AF.request(request)
                    .responseDecodable(of: SearchUserReponse.self) { response in
                        switch response.result {
                        case .success(let searchResult):
                            switch response.response?.statusCode {
                            case 200:
                                single(.success(.success(searchResult.data)))
                            default:
                                break
                            }
                        case .failure(let error):
                            switch  response.response?.statusCode {
                            case 401, 403:
                                single(.success(.failure(NetworkError.emptyDataError)))
                            case 419:
                                self.refreshToken()
                                    .subscribe(with: self) { owner, response in
                                        switch response {
                                        case .success(_):
                                            owner.searchUser(nickname)
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                    .disposed(by: self.disposeBag)
                            default:
                                break
                            }
                        }
                    }
            } catch {
                print(error)
            }
            return Disposables.create()
        }
    }
    
    func followUser(_ userID: String) -> Single<Result<Bool, Error>> {
        return Single.create { single -> Disposable in
            do {
                let request = try HBDRequest.followUser(userID: userID).asURLRequest()
                
                AF.request(request)
                    .responseDecodable(of: FollowUserResponse.self) { response in
                        switch response.result {
                        case .success(let data):
                            switch response.response?.statusCode {
                            case 200:
                                single(.success(.success(true)))
                            default:
                                break
                            }
                        case .failure(let error):
                            switch  response.response?.statusCode {
                            case 400, 401, 403, 409, 410:
                                single(.success(.failure(NetworkError.emptyDataError)))
                            case 419:
                                self.refreshToken()
                                    .subscribe(with: self) { owner, response in
                                        switch response {
                                        case .success(_):
                                            owner.followUser(userID)
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                    .disposed(by: self.disposeBag)
                            default:
                                break
                            }
                        }
                    }
            } catch {
                print(error)
            }
            return Disposables.create()
        }
    }
    
    func followCancel(_ userID: String) -> Single<Result<Bool, Error>> {
        return Single.create { single -> Disposable in
            do {
                let request = try HBDRequest.followCancel(userID: userID).asURLRequest()
                
                AF.request(request)
                    .responseDecodable(of: FollowUserResponse.self) { response in
                        switch response.result {
                        case .success(let data):
                            switch response.response?.statusCode {
                            case 200:
                                single(.success(.success(true)))
                            default:
                                break
                            }
                        case .failure(let error):
                            switch  response.response?.statusCode {
                            case 400, 401, 403, 409, 410:
                                single(.success(.failure(error)))
                            case 419:
                                self.refreshToken()
                                    .subscribe(with: self) { owner, response in
                                        switch response {
                                        case .success(_):
                                            owner.followUser(userID)
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                    .disposed(by: self.disposeBag)
                            default:
                                break
                            }
                        }
                    }
            } catch {
                print(error)
            }
            return Disposables.create()
        }
    }
    
    func readImage(_ link: String) -> Single<Result<Data, Error>> {
        return Single.create { single -> Disposable in
            do {
                let request = try HBDRequest.readImage(link: link).asURLRequest()
                
                AF.request(request)
                    .response { response in
                        switch response.result {
                        case .success(let imageData):
                            switch response.response?.statusCode {
                            case 200:
                                if let imageData {
                                    single(.success(.success(imageData)))
                                }
                            default:
                                break
                            }
                        case .failure(_):
                            switch  response.response?.statusCode {
                            case 401, 403:
                                single(.success(.failure(NetworkError.emptyDataError)))
                            case 419:
                                self.refreshToken()
                                    .subscribe(with: self) { owner, response in
                                        switch response {
                                        case .success(_):
                                            owner.readImage(link)
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                    .disposed(by: self.disposeBag)
                            default:
                                break
                            }
                        }
                    }
            } catch {
                print(error)
            }
            return Disposables.create()
        }
    }
    
    func paymentValidation(_ payment: PaymentQuery) -> Single<Result<PaymentResponse, Error>> {
        return Single.create { single -> Disposable in
            do {
                
                let request = try HBDRequest.paymentValidation(payment: payment).asURLRequest()
                
                AF.request(request)
                    .responseDecodable(of: PaymentResponse.self) { response in
                        switch response.result {
                        case .success(let data):
                            switch response.response?.statusCode {
                            case 200:
                                single(.success(.success(data)))
                            default:
                                break
                            }
                        case .failure(let error):
                            switch  response.response?.statusCode {
                            case 401, 403:
                                single(.success(.failure(NetworkError.emptyDataError)))
                            case 419:
                                self.refreshToken()
                                    .subscribe(with: self) { owner, response in
                                        switch response {
                                        case .success(_):
                                            owner.paymentValidation(payment)
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                    .disposed(by: self.disposeBag)
                            default:
                                break
                            }
                        }
                    }
            } catch {
                print(error)
            }
            return Disposables.create()
        }
    }
    
    func getPaymentsList() -> Single<Result<[PaymentResponse], Error>> {
        return Single.create { single -> Disposable in
            do {
                
                let request = try HBDRequest.paymentsList.asURLRequest()
                
                AF.request(request)
                    .responseDecodable(of: PaymentsListResponse.self) { response in
                        switch response.result {
                        case .success(let data):
                            switch response.response?.statusCode {
                            case 200:
                                single(.success(.success(data.data)))
                            default:
                                break
                            }
                        case .failure(_):
                            switch  response.response?.statusCode {
                            case 401, 403:
                                single(.success(.failure(NetworkError.emptyDataError)))
                            case 419:
                                self.refreshToken()
                                    .subscribe(with: self) { owner, response in
                                        switch response {
                                        case .success(_):
                                            owner.getPaymentsList()
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                    .disposed(by: self.disposeBag)
                            default:
                                break
                            }
                        }
                    }
            } catch {
                print(error)
            }
            return Disposables.create()
        }
    }
    
    
    private func refreshToken() -> Single<Result<Bool, Error>> {
        return Single.create { single -> Disposable in
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
                                single(.success(.success(true)))
                            default:
                                print(data)
                            }
                        case .failure(let error):
                            switch response.response?.statusCode {
                            case 401, 403, 418:
                                self.login(LoginQuery(email: "hbd0@com", password: "1"))
                                //single(.success(.failure(NetworkError.emptyDataError)))
                            default:
                                break
                            }
                        }
                    }
            } catch {
                print(error)
            }
            return Disposables.create()
        }
    }

}
