//
//  URL+Extension.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 11.09.23.
//

import Foundation

extension URL {
    func withQueryParameters(_ parameters: [String: Any]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        var queryItems = [URLQueryItem]()

        for (key, value) in parameters {
            let stringValue = String(describing: value)
            let queryItem = URLQueryItem(name: key, value: stringValue)
            queryItems.append(queryItem)
        }

        components?.queryItems = queryItems
        return components?.url ?? self
    }
}
