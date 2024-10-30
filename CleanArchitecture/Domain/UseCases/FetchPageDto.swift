//
//  FetchPageDto.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/26/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import ValidatedPropertyKit
import Then
import Dto

struct FetchPageDto: Dto, Then {
    var page = 1
    var perPage = 10
    var usingCache = false
}
