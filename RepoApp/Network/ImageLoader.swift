//
//  ImageLoader.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 7.09.23.
//

import Alamofire
import UIKit

protocol ImageLoaderProtocol {
    func loadImage(from link: String, completion: @escaping (Data?) -> Void)
}

final class ImageLoader: ImageLoaderProtocol {

    var imageCache = NSCache<NSString, NSData>()

    func loadImage(from link: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: link) else {
            completion(nil)
            return
        }
        let cacheId = url.absoluteString as NSString
        if let cachedImage = self.imageCache.object(forKey: cacheId) as? Data {
            completion(cachedImage)
            return
        }

        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                self.imageCache.setObject(data as NSData, forKey: cacheId)
                completion(data)
            case .failure:
                completion(nil)
            }
        }
    }
}
