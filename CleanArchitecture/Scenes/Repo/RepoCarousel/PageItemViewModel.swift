//
//  PageItemViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 16/12/2020.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import Foundation

struct PageItemViewModel {
    let title: String
    let imageURL: URL?
    let pageItem: PageItem
    
    init(pageItem: PageItem) {
        self.title = pageItem.title
        self.imageURL = pageItem.imageURL
        self.pageItem = pageItem
    }
}
