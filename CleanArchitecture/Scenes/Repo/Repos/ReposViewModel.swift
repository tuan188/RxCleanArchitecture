//
//  ReposViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/28/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import Factory
import RxCleanArchitecture

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
    
    func vm_showRepoDetail(repo: Repo) {
        showRepoDetail(repo: repo)
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
        
        let config = PageFetchConfig(
            loadTrigger: input.load,
            reloadTrigger: input.reload,
            loadMoreTrigger: input.loadMore,
            fetchItems: { [unowned self] page in
                getRepoList(page: page)
            })
        
        let (page, pagingError, isLoading, isReloading, isLoadingMore) = fetchPage(config: config).destructured

        let repoList = page
            .map { $0.items }
            
        repoList
            .map { $0.map(RepoItemViewModel.init) }
            .drive(output.$repoList)
            .disposed(by: disposeBag)

        selectItem(at: input.selectRepo, from: repoList)
            .drive(onNext: vm_showRepoDetail)
            .disposed(by: disposeBag)
        
        isDataEmpty(loadingTrigger: Driver.merge(isLoading, isReloading), dataItems: repoList)
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
