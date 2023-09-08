//
//  GithubModel.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 7.09.23.
//

import Foundation

struct GithubModel: Codable {
    let name: String?
    let description: String?
    let owner: Owner

    enum CodingKeys: String, CodingKey {
        case name, owner, description
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        owner = try container.decode(Owner.self, forKey: .owner)
    }
}

struct Owner: Codable {
    let avatar: String?

    enum CodingKeys: String, CodingKey {
        case avatar = "avatar_url"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
    }
}
