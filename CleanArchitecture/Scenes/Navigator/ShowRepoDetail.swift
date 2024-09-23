//
//  ShowRepoDetail.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 25/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit

protocol ShowRepoDetail {
    var navigationController: UINavigationController { get }
}

extension ShowRepoDetail {
    func showRepoDetail(repo: Repo) {
        navigationController
            .showAutoCloseMessage(image: nil,
                                  title: "Repo Detail",
                                  message: repo.name,
                                  interval: 1)
    }
}
