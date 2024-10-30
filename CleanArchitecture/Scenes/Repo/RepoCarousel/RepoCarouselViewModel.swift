//
//  RepoCarouselViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 15/12/2020.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import Factory
import RxCleanArchitecture

class RepoCarouselViewModel: GettingRepoList, ShowPageItemDetail {
    @Injected(\.repoGateway)
    var repoGateway: RepoGatewayProtocol

    unowned var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func getRepoList() -> Observable<[Repo]> {
        return getRepoList(dto: GetPageDto(page: 1, perPage: 20, usingCache: true))
            .map {
                $0.items
            }
    }
}

// MARK: - ViewModel
extension RepoCarouselViewModel: ViewModel {
    struct Input {
        let load: Driver<Void>
        let reload: Driver<Void>
        let selectRepo: Driver<IndexPath>
    }

    struct Output {
        @Property var error: Error?
        @Property var isLoading = false
        @Property var isReloading = false
        @Property var sections = [PageSectionViewModel]()
        @Property var isEmpty = false
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        let config = ListFetchConfig(
            loadTrigger: input.load,
            reloadTrigger: input.reload,
            fetchItems: { [unowned self] in
                getRepoList()
            }
        )
        
        let (repoList, error, isLoading, isReloading) = fetchList(config: config).destructured
            
        let sections = repoList
            .map { repos -> [PageSectionViewModel] in
                if repos.count == 20 {
                    return [
                        PageSectionViewModel(
                            index: 0,
                            type: .carousel,
                            items: (0...6).map { index -> PageItemViewModel in
                                return PageItemViewModel(pageItem: repos[index])
                            }
                        ),
                        PageSectionViewModel(
                            index: 0,
                            type: .list,
                            items: (7...14).map { index -> PageItemViewModel in
                                return PageItemViewModel(pageItem: repos[index])
                            }
                        )
                        ,
                        PageSectionViewModel(
                            index: 0,
                            type: .card,
                            items: (15...19).map { index -> PageItemViewModel in
                                return PageItemViewModel(pageItem: repos[index])
                            }
                        )
                    ]
                }
                return [
                    PageSectionViewModel(index: 0, type: .card, items: repos.map(PageItemViewModel.init))
                ]
            }
        
        sections.drive(output.$sections)
            .disposed(by: disposeBag)
        
        input.selectRepo
            .withLatestFrom(sections) { indexPath, sections in
                sections[indexPath.section].items[indexPath.row].pageItem
            }
            .drive(onNext: showPageItemDetail)
            .disposed(by: disposeBag)
        
        isDataEmpty(loadingTrigger: Driver.merge(isLoading, isReloading), dataItems: repoList)
            .drive(output.$isEmpty)
            .disposed(by: disposeBag)
        
        error
            .drive(output.$error)
            .disposed(by: disposeBag)
        
        isLoading
            .drive(output.$isLoading)
            .disposed(by: disposeBag)
        
        isReloading
            .drive(output.$isReloading)
            .disposed(by: disposeBag)
        
        return output
    }
}
