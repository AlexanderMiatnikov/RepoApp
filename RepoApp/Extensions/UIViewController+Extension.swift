//
//  UIViewController+Extension.swift
//  RepoApp
//
//  Created by Aliaksandr Miatnikau on 8.09.23.
//

import UIKit

enum AlertAction {
    case okay
    case cancel
    var action: UIAlertAction {
        switch self {
        case .okay:
            return UIAlertAction(title: "OK", style: .default, handler: nil)
        case .cancel:
            return UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        }
    }
}

extension UIViewController {

    // MARK: - Methods

    func displayAlert(title: String,
                      message: String,
                      actions: [UIAlertAction] = []) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true, completion: nil)
    }
}
