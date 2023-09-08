//
//  InfoPresenter.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 8.09.23.
//

import Foundation

protocol InfoPresenterProtocol: AnyObject {
    var repository: Repository { get set }
    func setImage(_ name: String?, completion: @escaping (Data?) -> Void)
}

final class InfoPresenter: InfoPresenterProtocol {
    var repository: Repository
    var imageLoader: ImageLoaderProtocol

    init(data: Repository, imageLoader: ImageLoaderProtocol) {
        self.repository = data
        self.imageLoader = imageLoader
    }

    func setImage(_ name: String?, completion: @escaping (Data?) -> Void) {
        if let link = name {
            imageLoader.loadImage(from: link) { imageData in
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
