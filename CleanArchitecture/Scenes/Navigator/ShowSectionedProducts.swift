//
//  ShowSectionedProducts.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 23/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit
import Factory

protocol ShowSectionedProducts {
    var navigationController: UINavigationController { get }
}

extension ShowSectionedProducts {
    func showSectionedProducts() {
        let vc = Container.shared.sectionedProductsViewController(navigationController: navigationController)()
        navigationController.pushViewController(vc, animated: true)
    }
}
