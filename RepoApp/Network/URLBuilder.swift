//
//  URLBuilder.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 8.09.23.
//

import Foundation

struct URLBuilder {
    private var baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func withPath(_ path: String) -> URLBuilder {
        var builder = self
        builder.baseURL.appendPathComponent(path)
        return builder
    }

    func withQueryParameters(_ parameters: [String: Any]) -> URLBuilder {
        var builder = self
        var components = URLComponents(url: builder.baseURL, resolvingAgainstBaseURL: true)
        var queryItems = [URLQueryItem]()

        for (key, value) in parameters {
            let stringValue = String(describing: value)
            let queryItem = URLQueryItem(name: key, value: stringValue)
            queryItems.append(queryItem)
        }

        components?.queryItems = queryItems
        builder.baseURL = components?.url ?? builder.baseURL
        return builder
    }

    func build() -> URL {
        return baseURL
    }
}

func githubAPIURL() -> URL? {
    if let githubURL = URL(string: "https://api.github.com") {
        return URLBuilder(baseURL: githubURL)
            .withPath("repositories")
            .build()
    }
    return nil
}

func bitbucketAPIURL() -> URL? {
    if let bitbucketURL = URL(string: "https://api.bitbucket.org/2.0") {
        return URLBuilder(baseURL: bitbucketURL)
            .withPath("repositories")
            .withQueryParameters(["fields": "values.name,values.owner,values.description"])
            .build()
    }
    return nil
}
