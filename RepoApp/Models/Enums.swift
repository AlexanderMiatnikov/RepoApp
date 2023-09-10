//
//  Enums.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 9.09.23.
//

import Foundation

enum DataSource {
    case all
    case bitbucket
    case github
}

enum SearchType {
    case author
    case repository
    case none
}

enum SortingOption {
    case none
    case alphabeticalAscending
    case alphabeticalDescending
}

