//
//  ShowRepos.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 23/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit
import Factory

protocol ShowRepos: AnyObject {
    var navigationController: UINavigationController { get }
}

extension ShowRepos {
    func showRepos() {
        let vc = Container.shared.reposViewController(navigationController: navigationController)()
        navigationController.pushViewController(vc, animated: true)
    }
}
