//
//  ReposViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/28/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import MGArchitecture
import RxSwift
import RxCocoa
import UIKit
import Factory

class ReposViewModel: GettingRepoList, ShowRepoDetail {
    @Injected(\.repoGateway)
    var repoGateway: RepoGatewayProtocol
    
    unowned var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func getRepoList(page: Int) -> Observable<PagingInfo<Repo>> {
        return getRepoList(dto: GetPageDto(page: page, perPage: 10, usingCache: true))
    }
}

// MARK: - ViewModel
extension ReposViewModel: ViewModel {
    struct Input {
        let load: Driver<Void>
        let reload: Driver<Void>
        let loadMore: Driver<Void>
        let selectRepo: Driver<IndexPath>
    }

    struct Output {
        @Property var error: Error?
        @Property var isLoading = false
        @Property var isReloading = false
        @Property var isLoadingMore = false
        @Property var repoList = [RepoItemViewModel]()
        @Property var isEmpty = false
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        let getPageInput = GetPageInput(
            loadTrigger: input.load,
            reloadTrigger: input.reload,
            loadMoreTrigger: input.loadMore,
            getItems: { [unowned self] page in
                getRepoList(page: page)
            })
        
        let getPageResult = getPage(input: getPageInput)
        let (page, pagingError, isLoading, isReloading, isLoadingMore) = getPageResult.destructured

        let repoList = page
            .map { $0.items }
            
        repoList
            .map { $0.map(RepoItemViewModel.init) }
            .drive(output.$repoList)
            .disposed(by: disposeBag)

        select(trigger: input.selectRepo, items: repoList)
            .drive(onNext: { [unowned self] repo in
                showRepoDetail(repo: repo)
            })
            .disposed(by: disposeBag)
        
        checkIfDataIsEmpty(trigger: Driver.merge(isLoading, isReloading), items: repoList)
            .drive(output.$isEmpty)
            .disposed(by: disposeBag)
        
        pagingError
            .drive(output.$error)
            .disposed(by: disposeBag)
        
        isLoading
            .drive(output.$isLoading)
            .disposed(by: disposeBag)
        
        isReloading
            .drive(output.$isReloading)
            .disposed(by: disposeBag)
        
        isLoadingMore
            .drive(output.$isLoadingMore)
            .disposed(by: disposeBag)

        return output
    }
}
