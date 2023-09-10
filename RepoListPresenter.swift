//
//  RepoListPresenter.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 7.09.23.
//

import Foundation

final class RepoListPresenter: RepoListPresenterProtocol {

    weak var delegate: RepoListViewProtocol?
    var networkService: NetworkManagerProtocol
    var imageLoader: ImageLoaderProtocol
    var isFiltering: Bool = false
    var selectedSearchType: SearchType = .author
    var githubRepos: [GithubModel] = []
    var bitbucketRepos: [BitbucketModel] = []
    var repositoryArray: [Repository] = []
    var originalRepository: [Repository] = []
    var filteredData: [Repository] = []


    // MARK: - Lifecycle

    init(networkService: NetworkManagerProtocol, imageLoader: ImageLoaderProtocol ) {
        self.networkService = networkService
        self.imageLoader = imageLoader
    }

    func filterRepositoriesBySearchText(_ option: SearchType, searchText: String) {
        filteredData = repositoryArray.filter { repository in
            switch option {
            case .author:
                return repository.name.lowercased().contains(searchText.lowercased())
            case .repository:
                return repository.description.lowercased().contains(searchText.lowercased())
            case .none:
                return true
            }
        }
        delegate?.reloadTableData()
    }


    func sortedByName(_ option: SortingOption, array: [Repository]) -> [Repository] {
        var sortedData: [Repository]
        switch option {
        case .none:
            sortedData = array
        case .alphabeticalAscending:
            sortedData = array.sorted { $0.description < $1.description }
        case .alphabeticalDescending:
            sortedData = array.sorted { $0.description > $1.description }
        }
        return sortedData
    }

    func sortedBySource(_ option: DataSource, array: [Repository]) -> [Repository] {
        var sortedData: [Repository]
        switch option {
        case .all:
            sortedData = array
        case .bitbucket:
            sortedData = array.filter { $0.source == .bitbucket }
        case .github:
            sortedData = array.filter { $0.source == .github }
        }
        return sortedData
    }

    func combineRepositories(bitbucketRepositories: [BitbucketModel], githubRepositories: [GithubModel]) {
        repositoryArray.removeAll()
        for bitbucketRepo in bitbucketRepositories {
            let repo = Repository(
                name: bitbucketRepo.name ?? Strings.noName,
                image: bitbucketRepo.owner?.links?.avatar?.href?.absoluteString ?? "",
                description: bitbucketRepo.description ?? Strings.noDescription,
                source: .bitbucket
            )
            repositoryArray.append(repo)
        }

        for githubRepo in githubRepositories {
            let repo = Repository(
                name: githubRepo.name ?? Strings.noName,
                image: githubRepo.owner.avatar ?? "",
                description: githubRepo.description ?? Strings.noDescription,
                source: .github
            )
            repositoryArray.append(repo)
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
            case .failure(let error):
                DispatchQueue.main.async {
                    self.displayErrorAlert(error: error)
                }
            }
        }
    }

    func displayErrorAlert(error: Error) {
        delegate?.displayAlert(title: Strings.error,
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
