//
//  Dismissible.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 30/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit

protocol Dismissible {
    var navigationController: UINavigationController { get }
}

extension Dismissible {
    func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }
}
