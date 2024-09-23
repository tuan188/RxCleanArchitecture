//
//  ShowAutoCloseMessage.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 25/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit

protocol ShowAutoCloseMessage {
    var navigationController: UINavigationController { get }
}

extension ShowAutoCloseMessage {
    func showAutoCloseMessage(_ message: String) {
        navigationController.showAutoCloseMessage(image: nil, title: nil, message: message)
    }
}
