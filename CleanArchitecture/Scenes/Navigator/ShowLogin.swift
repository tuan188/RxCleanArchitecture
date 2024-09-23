//
//  ShowLogin.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 23/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit
import Factory

protocol ShowLogin {
    var navigationController: UINavigationController { get }
}

extension ShowLogin {
    func showLogin() {
        let vc = Container.shared.loginViewController(navigationController: navigationController)()
        navigationController.pushViewController(vc, animated: true)
    }
}
