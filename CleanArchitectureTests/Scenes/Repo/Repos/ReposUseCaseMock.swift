//
//  ReposUseCaseMock.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/28/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import RxSwift

final class ReposUseCaseMock: ReposUseCaseType {

    // MARK: - loadMoreRepoList
    
    var getRepoListCalled = false
    
    var getRepoListReturnValue: Observable<PagingInfo<Repo>> = {
        let items = [
            Repo().with { $0.id = 2 }
        ]
        
        let page = PagingInfo<Repo>(page: 2, items: items)
        return Observable.just(page)
    }()
    
    func getRepoList(page: Int) -> Observable<PagingInfo<Repo>> {
        getRepoListCalled = true
        return getRepoListReturnValue
    }
}
