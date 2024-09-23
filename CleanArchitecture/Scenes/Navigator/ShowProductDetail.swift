//
//  ShowProductDetail.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 25/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit
import Factory

protocol ShowProductDetail {
    var navigationController: UINavigationController { get }
}

extension ShowProductDetail {
    func showProductDetail(product: Product) {
        let vc = Container.shared.productDetailViewController(product: product)()
        navigationController.pushViewController(vc, animated: true)
    }
}
