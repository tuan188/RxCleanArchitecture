//
//  RepoGateway.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/26/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift
import Factory
import APIServiceRx
import APIService
import RxCleanArchitecture

protocol RepoGatewayProtocol {
    func getRepoList(dto: GetPageDto) -> Observable<PagingInfo<Repo>>
}

struct RepoGateway: RepoGatewayProtocol {
    struct RepoList: Codable {
        let items: [Repo]
    }
    
    func getRepoList(dto: GetPageDto) -> Observable<PagingInfo<Repo>> {
        let (page, perPage) = (dto.page, dto.perPage)

        return APIServices.rxSwift
            .rx
            .request(GitEndpoint.repoList(page: page, perPage: perPage))
            .data(type: RepoList.self)
            .map { $0.items }
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
