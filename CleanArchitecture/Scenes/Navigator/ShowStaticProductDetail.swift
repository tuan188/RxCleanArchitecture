//
//  ShowStaticProductDetail.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 25/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit
import Factory

protocol ShowStaticProductDetail {
    var navigationController: UINavigationController { get }
}

extension ShowStaticProductDetail {
    func showStaticProductDetail(product: Product) {
        let vc = Container.shared.staticProductDetailViewController(product: product)()
        navigationController.pushViewController(vc, animated: true)
    }
}
