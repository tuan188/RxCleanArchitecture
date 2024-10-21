//
//  Product.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/5/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import Then

struct Product {
    var id = 0
    var name = ""
    var price = 0.0
}

extension Product: Then, Equatable { }
