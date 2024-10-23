//
//  ViewModel+GetPage.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 9/3/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public struct GetPageInput<TriggerInput, Item, MappedItem> {
    let pageSubject: BehaviorRelay<PagingInfo<MappedItem>>
    let pageActivityIndicator: PageActivityIndicator
    let errorTracker: ErrorTracker
    let loadTrigger: Driver<TriggerInput>
    let reloadTrigger: Driver<TriggerInput>
    let loadMoreTrigger: Driver<TriggerInput>
    let getItems: (TriggerInput) -> Observable<PagingInfo<Item>>
    let reloadItems: (TriggerInput) -> Observable<PagingInfo<Item>>
    let loadMoreItems: (TriggerInput, Int) -> Observable<PagingInfo<Item>>
    let mapper: (Item) -> MappedItem
    
    public init(pageSubject: BehaviorRelay<PagingInfo<MappedItem>>,
                pageActivityIndicator: PageActivityIndicator,
                errorTracker: ErrorTracker,
                loadTrigger: Driver<TriggerInput>,
                getItems: @escaping (TriggerInput) -> Observable<PagingInfo<Item>>,
                reloadTrigger: Driver<TriggerInput>,
                reloadItems: @escaping (TriggerInput) -> Observable<PagingInfo<Item>>,
                loadMoreTrigger: Driver<TriggerInput>,
                loadMoreItems: @escaping (TriggerInput, Int) -> Observable<PagingInfo<Item>>,
                mapper: @escaping (Item) -> MappedItem) {
        self.pageSubject = pageSubject
        self.pageActivityIndicator = pageActivityIndicator
        self.errorTracker = errorTracker
        self.loadTrigger = loadTrigger
        self.reloadTrigger = reloadTrigger
        self.loadMoreTrigger = loadMoreTrigger
        self.getItems = getItems
        self.reloadItems = reloadItems
        self.loadMoreItems = loadMoreItems
        self.mapper = mapper
    }
}

extension GetPageInput {
    public init(pageSubject: BehaviorRelay<PagingInfo<MappedItem>> = BehaviorRelay(value: PagingInfo<MappedItem>()),
                pageActivityIndicator: PageActivityIndicator = PageActivityIndicator(),
                errorTracker: ErrorTracker = ErrorTracker(),
                loadTrigger: Driver<TriggerInput>,
                reloadTrigger: Driver<TriggerInput>,
                loadMoreTrigger: Driver<TriggerInput>,
                getItems: @escaping (TriggerInput, Int) -> Observable<PagingInfo<Item>>,
                mapper: @escaping (Item) -> MappedItem) {
        self.init(pageSubject: pageSubject,
                  pageActivityIndicator: pageActivityIndicator,
                  errorTracker: errorTracker,
                  loadTrigger: loadTrigger,
                  getItems: { triggerInput in getItems(triggerInput, 1) },
                  reloadTrigger: reloadTrigger,
                  reloadItems: { triggerInput in getItems(triggerInput, 1) },
                  loadMoreTrigger: loadMoreTrigger,
                  loadMoreItems: getItems,
                  mapper: mapper)
    }
}

extension GetPageInput where TriggerInput == Void {
    public init(pageSubject: BehaviorRelay<PagingInfo<MappedItem>> = BehaviorRelay(value: PagingInfo<MappedItem>()),
                pageActivityIndicator: PageActivityIndicator = PageActivityIndicator(),
                errorTracker: ErrorTracker = ErrorTracker(),
                loadTrigger: Driver<TriggerInput>,
                reloadTrigger: Driver<TriggerInput>,
                loadMoreTrigger: Driver<TriggerInput>,
                getItems: @escaping (Int) -> Observable<PagingInfo<Item>>,
                mapper: @escaping (Item) -> MappedItem) {
        self.init(pageSubject: pageSubject,
                  pageActivityIndicator: pageActivityIndicator,
                  errorTracker: errorTracker,
                  loadTrigger: loadTrigger,
                  getItems: { _ in getItems(1) },
                  reloadTrigger: reloadTrigger,
                  reloadItems: { _ in getItems(1) },
                  loadMoreTrigger: loadMoreTrigger,
                  loadMoreItems: { _, page in getItems(page) },
                  mapper: mapper)
    }
}

extension GetPageInput where Item == MappedItem {
    public init(pageSubject: BehaviorRelay<PagingInfo<MappedItem>> = BehaviorRelay(value: PagingInfo<MappedItem>()),
                pageActivityIndicator: PageActivityIndicator = PageActivityIndicator(),
                errorTracker: ErrorTracker = ErrorTracker(),
                loadTrigger: Driver<TriggerInput>,
                reloadTrigger: Driver<TriggerInput>,
                loadMoreTrigger: Driver<TriggerInput>,
                getItems: @escaping (TriggerInput, Int) -> Observable<PagingInfo<Item>>) {
        self.init(pageSubject: pageSubject,
                  pageActivityIndicator: pageActivityIndicator,
                  errorTracker: errorTracker,
                  loadTrigger: loadTrigger,
                  getItems: { triggerInput in getItems(triggerInput, 1) },
                  reloadTrigger: reloadTrigger,
                  reloadItems: { triggerInput in getItems(triggerInput, 1) },
                  loadMoreTrigger: loadMoreTrigger,
                  loadMoreItems: getItems,
                  mapper: { $0 })
    }
}

extension GetPageInput where Item == MappedItem, TriggerInput == Void {
    public init(pageSubject: BehaviorRelay<PagingInfo<MappedItem>> = BehaviorRelay(value: PagingInfo<MappedItem>()),
                pageActivityIndicator: PageActivityIndicator = PageActivityIndicator(),
                errorTracker: ErrorTracker = ErrorTracker(),
                loadTrigger: Driver<TriggerInput>,
                reloadTrigger: Driver<TriggerInput>,
                loadMoreTrigger: Driver<TriggerInput>,
                getItems: @escaping (Int) -> Observable<PagingInfo<Item>>) {
        self.init(pageSubject: pageSubject,
                  pageActivityIndicator: pageActivityIndicator,
                  errorTracker: errorTracker,
                  loadTrigger: loadTrigger,
                  getItems: { _ in getItems(1) },
                  reloadTrigger: reloadTrigger,
                  reloadItems: { _ in getItems(1) },
                  loadMoreTrigger: loadMoreTrigger,
                  loadMoreItems: { _, page in getItems(page) },
                  mapper: { $0 })
    }
}

public struct GetPageResult<T> {
    public var page: Driver<PagingInfo<T>>
    public var error: Driver<Error>
    public var isLoading: Driver<Bool>
    public var isReloading: Driver<Bool>
    public var isLoadingMore: Driver<Bool>
    
    public var destructured: (Driver<PagingInfo<T>>, Driver<Error>, Driver<Bool>, Driver<Bool>, Driver<Bool>) {
        return (page, error, isLoading, isReloading, isLoadingMore)
    }
    
    public init(page: Driver<PagingInfo<T>>,
                error: Driver<Error>,
                isLoading: Driver<Bool>,
                isReloading: Driver<Bool>,
                isLoadingMore: Driver<Bool>) {
        self.page = page
        self.error = error
        self.isLoading = isLoading
        self.isReloading = isReloading
        self.isLoadingMore = isLoadingMore
    }
}

extension ViewModel {
    public func getPage<TriggerInput, Item, MappedItem>(input: GetPageInput<TriggerInput, Item, MappedItem>)
        -> GetPageResult<MappedItem> {
            
            let error = input.errorTracker.asDriver()
            let isLoading = input.pageActivityIndicator.isLoading
            let isReloading = input.pageActivityIndicator.isReloading
            
            let loadingMoreSubject = PublishSubject<Bool>()
            
            let isLoadingMore = Driver.merge(
                input.pageActivityIndicator.isLoadingMore,
                loadingMoreSubject.asDriverOnErrorJustComplete()
            )
            
            let isLoadingOrLoadingMore = Driver.merge(isLoading, isReloading, isLoadingMore)
                .startWith(false)
            
            let loadItems = Driver<ScreenLoadingType<TriggerInput>>
                .merge(
                    input.loadTrigger.map { ScreenLoadingType.loading($0) },
                    input.reloadTrigger.map { ScreenLoadingType.reloading($0) }
                )
                .withLatestFrom(isLoadingOrLoadingMore) {
                    (triggerType: $0, loading: $1)
                }
                .filter { !$0.loading }
                .map { $0.triggerType }
                .flatMapLatest { triggerType -> Driver<PagingInfo<Item>> in
                    switch triggerType {
                    case .loading(let triggerInput):
                        return input.getItems(triggerInput)
                            .trackError(input.errorTracker)
                            .trackActivity(input.pageActivityIndicator.loadingIndicator)
                            .asDriverOnErrorJustComplete()
                    case .reloading(let triggerInput):
                        return input.reloadItems(triggerInput)
                            .trackError(input.errorTracker)
                            .trackActivity(input.pageActivityIndicator.reloadingIndicator)
                            .asDriverOnErrorJustComplete()
                    }
                }
                .do(onNext: { page in
                    let newPage = PagingInfo<MappedItem>(
                        page: page.page,
                        items: page.items.map(input.mapper),
                        hasMorePages: page.hasMorePages,
                        totalItems: page.totalItems,
                        itemsPerPage: page.itemsPerPage,
                        totalPages: page.totalPages
                    )
                    
                    input.pageSubject.accept(newPage)
                })
            
            let loadMoreItems = input.loadMoreTrigger
                .withLatestFrom(isLoadingOrLoadingMore) {
                    (triggerInput: $0, loading: $1)
                }
                .filter { !$0.loading }
                .map { $0.triggerInput }
                .do(onNext: { _ in
                    if input.pageSubject.value.items.isEmpty {
                        loadingMoreSubject.onNext(false)
                    }
                })
                .filter { _ in !input.pageSubject.value.items.isEmpty }
                .flatMapLatest { triggerInput -> Driver<PagingInfo<Item>> in
                    let page = input.pageSubject.value.page
                    
                    return input.loadMoreItems(triggerInput, page + 1)
                        .trackError(input.errorTracker)
                        .trackActivity(input.pageActivityIndicator.loadingMoreIndicator)
                        .asDriverOnErrorJustComplete()
                }
                .filter { !$0.items.isEmpty || !$0.hasMorePages }
                .do(onNext: { page in
                    let currentPage = input.pageSubject.value
                    let items = currentPage.items + page.items.map(input.mapper)
                    
                    let newPage = PagingInfo<MappedItem>(
                        page: page.page,
                        items: items,
                        hasMorePages: page.hasMorePages,
                        totalItems: page.totalItems,
                        itemsPerPage: page.itemsPerPage,
                        totalPages: page.totalPages
                    )
                    
                    input.pageSubject.accept(newPage)
                })
            
            let page = Driver.merge(loadItems, loadMoreItems)
                .withLatestFrom(input.pageSubject.asDriver())
            
            return GetPageResult(
                page: page,
                error: error,
                isLoading: isLoading,
                isReloading: isReloading,
                isLoadingMore: isLoadingMore
            )

    }
}
