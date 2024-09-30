//
//  APIResponse.swift
//  MGAPIService
//
//  Created by Tuan Truong on 12/27/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

public struct APIResponse<T> {
    public var header: ResponseHeader?
    public var data: T
    
    public init(header: ResponseHeader?, data: T) {
        self.header = header
        self.data = data
    }
}
