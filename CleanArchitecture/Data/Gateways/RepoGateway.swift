//
//  RepoGateway.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/26/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift
import MGArchitecture
import Factory

protocol RepoGatewayProtocol {
    func getRepoList(dto: GetPageDto) -> Observable<PagingInfo<Repo>>
}

struct RepoGateway: RepoGatewayProtocol {
    func getRepoList(dto: GetPageDto) -> Observable<PagingInfo<Repo>> {
        let (page, perPage, usingCache) = (dto.page, dto.perPage, dto.usingCache)
        
        let input = API.GetRepoListInput(page: page, perPage: perPage)
        input.usingCache = usingCache
        
        return API.shared.getRepoList(input)
            .map { $0.repos }
            .unwrap()
            .distinctUntilChanged { $0 == $1 }
            .map { repos in
                return PagingInfo<Repo>(page: page, items: repos)
            }
    }
}

extension Container {
    var repoGateway: Factory<RepoGatewayProtocol> {
        Factory(self) {
            RepoGateway()
        }
    }
}
