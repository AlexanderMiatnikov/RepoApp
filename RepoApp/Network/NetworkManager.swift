//
//  NetworkManager.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 7.09.23.
//

import Foundation
import Alamofire

enum APIError: Error {
    case noData
    case decodingError(Error)
}

protocol NetworkManagerProtocol {
    var dispatchGroup: DispatchGroup { get set }
    func fetchFromBitBucket(completion: @escaping (Result<[BitbucketModel], APIError>) -> Void)
    func fetchFromGitHub(completion: @escaping (Result<[GithubModel], APIError>) -> Void)
}

final class NetworkManager: NetworkManagerProtocol {

    var dispatchGroup = DispatchGroup()

    func fetchFromBitBucket(completion: @escaping (Result<[BitbucketModel], APIError>) -> Void) {
        if let urlString = bitbucketAPIURL() {
            dispatchGroup.enter()
            AF.request(urlString).responseDecodable(of: BitbucketModel.self) { response in
                defer {
                    self.dispatchGroup.leave()
                }
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        completion(.failure(.noData))
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let bitbucketResponse = try decoder.decode(BitbucketModelContainer.self, from: data)
                        completion(.success(bitbucketResponse.values))
                    } catch {
                        completion(.failure(.decodingError(error)))
                    }
                case .failure(let error):
                    completion(.failure(.decodingError(error)))
                }
            }
        } else {
            completion(.failure(.noData))
        }
    }

    func fetchFromGitHub(completion: @escaping (Result<[GithubModel], APIError>) -> Void) {
        if let urlString = githubAPIURL() {
            dispatchGroup.enter()
            AF.request(urlString).responseDecodable(of: [GithubModel].self) { response in
                defer {
                    self.dispatchGroup.leave()
                }
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        completion(.failure(.noData))
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let githubResponse = try decoder.decode([GithubModel].self, from: data)
                        completion(.success(githubResponse))
                    } catch {
                        completion(.failure(.decodingError(error)))
                    }
                case .failure(let error):
                    completion(.failure(.decodingError(error)))
                }
            }
        } else {
            completion(.failure(.noData))
        }
    }

    func githubAPIURL() -> URL? {
        return APIModel.github.baseURL
            .appendingPathComponent(APIModel.github.path)
            .withQueryParameters(APIModel.github.queryParameters)
    }

    func bitbucketAPIURL() -> URL? {
        return APIModel.bitbucket.baseURL
            .appendingPathComponent(APIModel.bitbucket.path)
            .withQueryParameters(APIModel.bitbucket.queryParameters)
    }
}

