//
//  HTTPRequestable.swift
//  HBD
//
//  Created by 김수경 on 8/15/24.
//

import Foundation
import Alamofire

protocol HTTPRequestable: URLRequestConvertible {
    var scheme: String { get }
    var baseURLString: String { get throws }
    var httpMethod: HTTPMethod { get }
    var version: RequestVersion { get }
    var portNum: Int? { get throws }
    var path: [String] { get }
    var queries: [URLQueryItem]? { get }
    var httpHeaders: [String: String]? { get }
    var httpBody: Data? { get }
    
}

extension HTTPRequestable {
    func asURLRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = scheme
        components.host = try baseURLString
        components.port = try portNum
        components.path = "/\(version)/" + path.joined(separator: "/")
        
        if let queries {
            components.queryItems = queries
        }
        
        let url = try components.asURL()
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = httpHeaders
        request.httpBody = httpBody
        
        return request
    }
}

extension HTTPRequestable {
    func asURL() throws -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = try baseURLString
        components.port = try portNum
        components.path = "/\(version)/" + path.joined(separator: "/")

        return try components.asURL()
    }
}
