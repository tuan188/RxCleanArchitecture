//
//  GitEndpoint.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 14/10/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import APIService

enum GitEndpoint: Endpoint {
    case repoList(page: Int, perPage: Int)
    
    var headers: [String : Any]? {
        [
            "Content-Type": "application/json; charset=utf-8",
            "Accept": "application/json"
        ]
    }
    
    var urlString: String? {
        return "https://api.github.com/search/repositories"
    }
    
    var queryItems: [String : Any]? {
        switch self {
        case .repoList(page: let page, perPage: let perPage):
            return ["q": "language:swift", "page": page, "per_page": perPage]
        }
    }
}
