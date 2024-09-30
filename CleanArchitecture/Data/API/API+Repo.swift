//
//  API+Repo.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/28/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import ObjectMapper
import RxSwift

extension API {
    func getRepoList(_ input: GetRepoListInput) -> Observable<GetRepoListOutput> {
        return request(input)
    }
}

// MARK: - GetRepoList
extension API {
    final class GetRepoListInput: APIInput {
        init(page: Int, perPage: Int = 10) {
            let params: JSONDictionary = [
                "q": "language:swift",
                "per_page": perPage,
                "page": page
            ]
            super.init(urlString: API.Urls.getRepoList,
                       parameters: params,
                       method: .get,
                       requireAccessToken: true)
        }
    }
    
    final class GetRepoListOutput: APIOutput, Equatable {
        private(set) var repos: [Repo]?
        
        override func mapping(map: Map) {
            super.mapping(map: map)
            repos <- map["items"]
        }
        
        static func == (lhs: API.GetRepoListOutput, rhs: API.GetRepoListOutput) -> Bool {
            return lhs.repos == rhs.repos
        }
    }
}

