//
//  ShowRepoCollection.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 23/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit
import Factory

protocol ShowRepoCollection {
    var navigationController: UINavigationController { get }
}

extension ShowRepoCollection {
    func showRepoCollection() {
        let vc = Container.shared.repoCollectionViewController(navigationController: navigationController)()
        navigationController.pushViewController(vc, animated: true)
    }
}
