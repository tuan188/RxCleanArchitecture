//
//  ShowProducts.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 23/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit
import Factory

protocol ShowProducts {
    var navigationController: UINavigationController { get }
}

extension ShowProducts {
    func showProducts() {
        let vc = Container.shared.productsViewController(navigationController: navigationController)()
        navigationController.pushViewController(vc, animated: true)
    }
}
