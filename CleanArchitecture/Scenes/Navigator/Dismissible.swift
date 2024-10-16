//
//  Dismissible.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 30/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol Dismissible {
    var navigationController: UINavigationController { get }
}

extension Dismissible {
    func dismiss() {
        let disposable = navigationController.viewControllers.first as? Disposable
        navigationController.dismiss(animated: true) {
            disposable?.dispose()
        }
    }
}
