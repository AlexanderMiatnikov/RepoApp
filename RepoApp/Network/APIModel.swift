//
//  URLBuilder.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 8.09.23.
//

import Foundation
import Alamofire

protocol APIEndpoint {
    var baseURL: URL { get }
    var path: String { get }
    var queryParameters: [String: Any] { get }
    var method: HTTPMethod { get }
}

enum APIModel: APIEndpoint {

    case github
    case bitbucket

    var baseURL: URL {
        switch self {
        case .github:
            return URL(string: "https://api.github.com")!
        case .bitbucket:
            return URL(string: "https://api.bitbucket.org/2.0")!
        }
    }

    var path: String {
        switch self {
        case .github:
            return "/repositories"
        case .bitbucket:
            return "/repositories"
        }
    }

    var queryParameters: [String: Any] {
        switch self {
        case .github:
            return [:] // No query parameters for GitHub
        case .bitbucket:
            return ["fields": "values.name,values.owner,values.description"]
        }
    }

    var method: HTTPMethod {
        return .get
    }
}
