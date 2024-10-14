//
//  PageItem.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 16/12/2020.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import Foundation

protocol PageItem {
    var title: String { get }
    var body: String { get }
    var imageURL: URL? { get }
}

extension Repo: PageItem {
    var title: String {
        return self.name
    }
    
    var body: String {
        return self.fullname
    }
    
    var imageURL: URL? {
        return URL(string: self.owner.avatarURLString)
    }
}
