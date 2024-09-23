//
//  ShowRepoCarousel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 23/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit
import Factory

protocol ShowRepoCarousel {
    var navigationController: UINavigationController { get }
}

extension ShowRepoCarousel {
    func showRepoCarousel() {
        let vc = Container.shared.repoCarouselViewController(navigationController: navigationController)()
        navigationController.pushViewController(vc, animated: true)
    }
}
