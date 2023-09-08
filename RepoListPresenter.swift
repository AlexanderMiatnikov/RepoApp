//
//  RepoListPresenter.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 7.09.23.
//

import Foundation

protocol RepoListPresenterProtocol: AnyObject {
    var delegate: RepoListViewProtocol? { get set }
    var githubRepos: [GithubModel] { get set }
    var bitbucketRepos: [BitbucketModel] { get set }
    var repository: [Repository] { get set }
    func fetchFromGitHub()
    func fetchFromBitBucket()
    func waitForData(completion: @escaping () -> Void)
    func imageForCell(_ name: String?, completion: @escaping (Data?) -> Void)
    func sortData(_ option: SortingOption) 
    func reloadData(_ sortedData: [Repository]) 
}

enum SortingOption {
    case none
    case alphabeticalAscending
    case alphabeticalDescending
}

final class RepoListPresenter: RepoListPresenterProtocol {


    weak var delegate: RepoListViewProtocol?
    var networkService: NetworkManagerProtocol
    var imageLoader: ImageLoaderProtocol

    var githubRepos: [GithubModel] = []
    var bitbucketRepos: [BitbucketModel] = []
    var repository: [Repository] = []

    // MARK: - Lifecycle

    init(networkService: NetworkManagerProtocol, imageLoader: ImageLoaderProtocol ) {
        self.networkService = networkService
        self.imageLoader = imageLoader
    }

    func sortData(_ option: SortingOption) {
        var sortedData: [Repository]

        switch option {
        case .none:
            sortedData = repository
        case .alphabeticalAscending:
            sortedData = repository.sorted { $0.description ?? "" < $1.description ?? "" }
        case .alphabeticalDescending:
            sortedData = repository.sorted { $0.description ?? "" > $1.description ?? "" }
        }
        reloadData(sortedData)
    }

    func reloadData(_ sortedData: [Repository]) {
        repository = sortedData
        delegate?.reloadTableData()
    }


    func combineRepositories(bitbucketRepositories: [BitbucketModel], githubRepositories: [GithubModel]) {
        repository.removeAll()
        for bitbucketRepo in bitbucketRepositories {
            let repo = Repository(
                name: bitbucketRepo.name ?? "no name",
                image: bitbucketRepo.owner?.links?.avatar?.href?.absoluteString ?? "",
                description: bitbucketRepo.description,
                source: .bitbucket
            )
            repository.append(repo)
        }

        for githubRepo in githubRepositories {
            let repo = Repository(
                name: githubRepo.name ?? "no name",
                image: githubRepo.owner.avatar ?? "",
                description: githubRepo.description,
                source: .github
            )
            repository.append(repo)
        }
    }

    func waitForData(completion: @escaping () -> Void) {
        networkService.dispatchGroup.notify(queue: .main) {
            self.combineRepositories(bitbucketRepositories: self.bitbucketRepos, githubRepositories: self.githubRepos)
            completion()
        }
    }

    func fetchFromGitHub() {
        networkService.fetchFromGitHub() { (result: Result<[GithubModel], APIError>) in
            self.delegate?.hideLoadingIndicator()
            switch result {
            case .success(let repos):
                self.githubRepos = repos
                DispatchQueue.main.async {
                    self.combineRepositories(bitbucketRepositories: self.bitbucketRepos, githubRepositories: self.githubRepos)
                    self.delegate?.reloadTableData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.displayErrorAlert(error: error)
                }
            }
        }
    }

    func fetchFromBitBucket() {
        networkService.fetchFromBitBucket() { (result: Result<[BitbucketModel], APIError>) in
            self.delegate?.hideLoadingIndicator()
            switch result {
            case .success(let repos):
                self.bitbucketRepos = repos
                DispatchQueue.main.async {
                    self.combineRepositories(bitbucketRepositories: self.bitbucketRepos, githubRepositories: self.githubRepos)
                    self.delegate?.reloadTableData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.displayErrorAlert(error: error)
                }
            }
        }
    }

    func displayErrorAlert(error: Error) {
        delegate?.displayAlert(title: "Error",
                               message: error.localizedDescription,
                               actions: [AlertAction.okay.action])
    }

    func imageForCell(_ name: String?, completion: @escaping (Data?) -> Void) {
        if let coverLink = name {
            imageLoader.loadImage(from: coverLink) { imageData in
                if let data = imageData {
                    completion(data)
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
}
