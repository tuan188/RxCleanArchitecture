//
//  ShowEditProduct.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 25/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Factory

protocol ShowEditProduct {
    var navigationController: UINavigationController { get }
}

extension ShowEditProduct {
    func showEditProduct(_ product: Product) -> Driver<EditProductDelegate> {
        let delegate = PublishSubject<EditProductDelegate>()
        
        let nav = UINavigationController()
        let vc = Container.shared.editProductViewController(
            product: product,
            delegate: delegate,
            navigationController: nav
        )()
        
        nav.viewControllers.append(vc)
        navigationController.present(nav, animated: true, completion: nil)
        
        return delegate.asDriverOnErrorJustComplete()
    }
}
