//
//  PagingInfo+Equalable.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/29/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit

extension PagingInfo: Equatable where T: Equatable {
    public static func == (lhs: PagingInfo<T>, rhs: PagingInfo<T>) -> Bool {
        return lhs.page == rhs.page
            && lhs.items == rhs.items
    }
}
