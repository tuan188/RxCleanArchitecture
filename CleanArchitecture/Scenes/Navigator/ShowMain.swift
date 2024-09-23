//
//  ShowMain.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 23/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import UIKit
import Factory

protocol ShowMain {
    var window: UIWindow { get }
}

extension ShowMain {
    func showMain() {
        let nav = UINavigationController()
        let vc = Container.shared.mainViewController(navigationController: nav)()
        nav.viewControllers.append(vc)
        
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
}
