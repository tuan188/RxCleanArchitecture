//
//  PagingInfo.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/1/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

public struct PagingInfo<T> {
    public var page: Int
    public var items: [T]
    public var hasMorePages: Bool
    public var totalItems: Int
    public var itemsPerPage: Int
    public var totalPages: Int
    
    public init(page: Int = 1,
                items: [T] = [],
                hasMorePages: Bool = true,
                totalItems: Int = 0,
                itemsPerPage: Int = 0,
                totalPages: Int = 0) {
        self.page = page
        self.items = items
        self.hasMorePages = hasMorePages
        self.totalItems = totalItems
        self.itemsPerPage = itemsPerPage
        self.totalPages = totalPages
    }
}
