//
//  RepoGatewayMock.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 6/26/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import UIKit
import RxSwift
import RxCleanArchitecture

final class RepoGatewayMock: RepoGatewayProtocol {

    // MARK: - getRepoList

    var getRepoListCalled = false
    var getRepoListReturnValue = Observable<PagingInfo<Repo>>.empty()

    func fetchRepos(dto: FetchPageDto) -> Observable<PagingInfo<Repo>> {
        getRepoListCalled = true
        return getRepoListReturnValue
    }
}
