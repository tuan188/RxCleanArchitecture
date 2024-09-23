//
//  ShowDynamicEditProduct.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 25/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit
import Factory

protocol ShowDynamicEditProduct {
    var navigationController: UINavigationController { get }
}

extension ShowDynamicEditProduct {
    func showDynamicEditProduct(_ product: Product) {
        let nav = UINavigationController()
        let vc =  Container.shared.dynamicEditProduct(navigationController: nav, product: product)()
        nav.viewControllers = [vc]
        navigationController.present(nav, animated: true, completion: nil)
    }
}
