//
//  BitbucketModel.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 7.09.23.
//

import Foundation

struct BitbucketModelContainer: Codable {
    let values: [BitbucketModel]

    enum CodingKeys: String, CodingKey {
        case values
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        values = try container.decode([BitbucketModel].self, forKey: .values)
    }
}

struct BitbucketModel: Codable {
    let name: String?
    let owner: BitbucketOwner?
    let description: String?

    enum CodingKeys: String, CodingKey {
        case name
        case owner
        case description
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        owner = try container.decodeIfPresent(BitbucketOwner.self, forKey: .owner)
        description = try container.decodeIfPresent(String.self, forKey: .description)
    }
}

struct BitbucketOwner: Codable {
    let displayName: String?
    let links: BitbucketOwnerLinks?

    enum CodingKeys: String, CodingKey {
        case displayName
        case links
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        links = try container.decode(BitbucketOwnerLinks.self, forKey: .links)
    }
}

struct BitbucketOwnerLinks: Codable {
    let avatar: BitbucketAvatarLink?

    enum CodingKeys: String, CodingKey {
        case avatar
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        avatar = try container.decode(BitbucketAvatarLink.self, forKey: .avatar)
    }
}

struct BitbucketAvatarLink: Codable {
    let href: URL?
    
    enum CodingKeys: String, CodingKey {
        case href
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        href = try container.decode(URL.self, forKey: .href)
    }
}
