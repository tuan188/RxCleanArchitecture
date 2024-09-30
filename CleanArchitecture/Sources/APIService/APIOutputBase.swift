//
//  APIOutputBase.swift
//  MGAPIService
//
//  Created by Tuan Truong on 4/5/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import ObjectMapper

open class APIOutputBase: Mappable {
    
    public init() {
        
    }
    
    public required init?(map: Map) {

    }
    
    open func mapping(map: Map) {
        
    }
}

