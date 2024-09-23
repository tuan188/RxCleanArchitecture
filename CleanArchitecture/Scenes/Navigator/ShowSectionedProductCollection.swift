//
//  ShowSectionedProductCollection.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 23/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit
import Factory

protocol ShowSectionedProductCollection {
    var navigationController: UINavigationController { get }
}

extension ShowSectionedProductCollection {
    func showSectionedProductCollection() {
        let vc = Container.shared.sectionedProductCollectionViewController(navigationController: navigationController)()
        navigationController.pushViewController(vc, animated: true)
    }
}
