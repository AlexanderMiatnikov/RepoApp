//
//  InfoPresenterProtocol.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 11.09.23.
//

import Foundation

protocol InfoPresenterProtocol: AnyObject {
    var repository: Repository { get set }
    func setImage(_ name: String?, completion: @escaping (Data?) -> Void)
}
