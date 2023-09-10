//
//  RepositoryModel.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 8.09.23.
//

import Foundation

struct Repository {
    let name: String
    let image: String
    let description: String
    let source: SourceType

    init(name: String, image: String, description: String, source: SourceType) {
        self.name = name
        self.image = image
        self.description = description
        self.source = source
    }
}

enum SourceType: String {
    case bitbucket
    case github
}
