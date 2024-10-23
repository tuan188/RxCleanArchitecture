//
//  ViewModel+GetList.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 9/3/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public struct GetListInput<TriggerInput, Item, MappedItem> {
    let pageActivityIndicator: PageActivityIndicator
    let errorTracker: ErrorTracker
    let loadTrigger: Driver<TriggerInput>
    let reloadTrigger: Driver<TriggerInput>
    let getItems: (TriggerInput) -> Observable<[Item]>
    let reloadItems: (TriggerInput) -> Observable<[Item]>
    let mapper: (Item) -> MappedItem
    
    public init(pageActivityIndicator: PageActivityIndicator,
                errorTracker: ErrorTracker,
                loadTrigger: Driver<TriggerInput>,
                getItems: @escaping (TriggerInput) -> Observable<[Item]>,
                reloadTrigger: Driver<TriggerInput>,
                reloadItems: @escaping (TriggerInput) -> Observable<[Item]>,
                mapper: @escaping (Item) -> MappedItem) {
        self.pageActivityIndicator = pageActivityIndicator
        self.errorTracker = errorTracker
        self.loadTrigger = loadTrigger
        self.reloadTrigger = reloadTrigger
        self.getItems = getItems
        self.reloadItems = reloadItems
        self.mapper = mapper
    }
}

extension GetListInput {
    public init(pageActivityIndicator: PageActivityIndicator = PageActivityIndicator(),
                errorTracker: ErrorTracker = ErrorTracker(),
                loadTrigger: Driver<TriggerInput>,
                reloadTrigger: Driver<TriggerInput>,
                getItems: @escaping (TriggerInput) -> Observable<[Item]>,
                mapper: @escaping (Item) -> MappedItem) {
        self.init(pageActivityIndicator: pageActivityIndicator,
                  errorTracker: errorTracker,
                  loadTrigger: loadTrigger,
                  getItems: getItems,
                  reloadTrigger: reloadTrigger,
                  reloadItems: getItems,
                  mapper: mapper)
    }
}

extension GetListInput where Item == MappedItem {
    public init(pageActivityIndicator: PageActivityIndicator = PageActivityIndicator(),
                errorTracker: ErrorTracker = ErrorTracker(),
                loadTrigger: Driver<TriggerInput>,
                reloadTrigger: Driver<TriggerInput>,
                getItems: @escaping (TriggerInput) -> Observable<[Item]>) {
        self.init(pageActivityIndicator: pageActivityIndicator,
                  errorTracker: errorTracker,
                  loadTrigger: loadTrigger,
                  getItems: getItems,
                  reloadTrigger: reloadTrigger,
                  reloadItems: getItems,
                  mapper: { $0 })
    }
}

public struct GetListResult<T> {
    public var items: Driver<[T]>
    public var error: Driver<Error>
    public var isLoading: Driver<Bool>
    public var isReloading: Driver<Bool>
    
    public var destructured: (Driver<[T]>, Driver<Error>, Driver<Bool>, Driver<Bool>) {
        return (items, error, isLoading, isReloading)
    }
    
    public init(items: Driver<[T]>,
                error: Driver<Error>,
                isLoading: Driver<Bool>,
                isReloading: Driver<Bool>) {
        self.items = items
        self.error = error
        self.isLoading = isLoading
        self.isReloading = isReloading
    }
}

extension ViewModel {
    public func getList<TriggerInput, Item, MappedItem>(input: GetListInput<TriggerInput, Item, MappedItem>)
        -> GetListResult<MappedItem> {
            
            let error = input.errorTracker.asDriver()
            let isLoading = input.pageActivityIndicator.isLoading
            let isReloading = input.pageActivityIndicator.isReloading
            
            let isLoadingOrReloading = Driver.merge(isLoading, isReloading)
                .startWith(false)
            
            let items = Driver<ScreenLoadingType<TriggerInput>>
                .merge(
                    input.loadTrigger.map { ScreenLoadingType.loading($0) },
                    input.reloadTrigger.map { ScreenLoadingType.reloading($0) }
                )
                .withLatestFrom(isLoadingOrReloading) {
                    (triggerType: $0, loading: $1)
                }
                .filter { !$0.loading }
                .map { $0.triggerType }
                .flatMapLatest { triggerType -> Driver<[Item]> in
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
                .map { $0.map(input.mapper) }
            
            return GetListResult(
                items: items,
                error: error,
                isLoading: isLoading,
                isReloading: isReloading
            )
    }
}

