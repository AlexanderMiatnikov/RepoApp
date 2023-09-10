//
//  RepoListProtocol.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 11.09.23.
//

import Foundation

typealias RepoListPresenterProtocol = ListPresenterProtocol & SortingProtocol & filterProtocol

protocol ListPresenterProtocol: AnyObject {
    var delegate: RepoListViewProtocol? { get set }
    var repositoryArray: [Repository] { get set }
    var selectedSearchType: SearchType { get set }
    func fetchFromGitHub()
    func fetchFromBitBucket()
    func waitForData(completion: @escaping () -> Void)
    func imageForCell(_ name: String?, completion: @escaping (Data?) -> Void)
}

protocol SortingProtocol: AnyObject {
    var originalRepository: [Repository] { get set }
    func sortedByName(_ option: SortingOption, array: [Repository]) -> [Repository]
    func sortedBySource(_ option: DataSource, array: [Repository]) -> [Repository]
}

protocol filterProtocol: AnyObject {
    var isFiltering: Bool { get set }
    var filteredData: [Repository] { get set }
    func filterRepositoriesBySearchText(_ option: SearchType, searchText: String)
}
