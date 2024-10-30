//
//  FetchRepos.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/26/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift
import RxCleanArchitecture

protocol FetchRepos {
    var repoGateway: RepoGatewayProtocol { get }
}

extension FetchRepos {
    func fetchRepos(dto: FetchPageDto) -> Observable<PagingInfo<Repo>> {
        return repoGateway.fetchRepos(dto: dto)
    }
}
