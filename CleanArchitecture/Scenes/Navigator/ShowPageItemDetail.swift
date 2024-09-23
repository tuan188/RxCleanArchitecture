//
//  ShowPageItemDetail.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 25/9/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import UIKit

protocol ShowPageItemDetail {
    var navigationController: UINavigationController { get }
}

extension ShowPageItemDetail {
    func showPageItemDetail(_ pageItem: PageItem) {
        navigationController
            .showAutoCloseMessage(image: nil, title: "PageItem detail", message: pageItem.title)
    }
}
