//
//  ShowUsers.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 23/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit
import Factory

protocol ShowUsers {
    var navigationController: UINavigationController { get }
}

extension ShowUsers {
    func showUsers() {
        let vc = Container.shared.userListViewController()()
        navigationController.pushViewController(vc, animated: true)
    }
}
