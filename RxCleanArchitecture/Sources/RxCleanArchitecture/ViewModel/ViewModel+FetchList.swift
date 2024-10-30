import UIKit
import RxSwift
import RxCocoa

public struct ListFetchConfig<Trigger, Item, MappedItem> {
    let pageActivityIndicator: PageActivityIndicator
    let errorTracker: ErrorTracker
    let loadTrigger: Driver<Trigger>
    let reloadTrigger: Driver<Trigger>
    let fetchItems: (Trigger) -> Observable<[Item]>
    let reloadItems: (Trigger) -> Observable<[Item]>
    let mapper: (Item) -> MappedItem
    
    public init(pageActivityIndicator: PageActivityIndicator,
                errorTracker: ErrorTracker,
                loadTrigger: Driver<Trigger>,
                fetchItems: @escaping (Trigger) -> Observable<[Item]>,
                reloadTrigger: Driver<Trigger>,
                reloadItems: @escaping (Trigger) -> Observable<[Item]>,
                mapper: @escaping (Item) -> MappedItem) {
        self.pageActivityIndicator = pageActivityIndicator
        self.errorTracker = errorTracker
        self.loadTrigger = loadTrigger
        self.reloadTrigger = reloadTrigger
        self.fetchItems = fetchItems
        self.reloadItems = reloadItems
        self.mapper = mapper
    }
}

extension ListFetchConfig {
    public init(pageActivityIndicator: PageActivityIndicator = PageActivityIndicator(),
                errorTracker: ErrorTracker = ErrorTracker(),
                loadTrigger: Driver<Trigger>,
                reloadTrigger: Driver<Trigger>,
                fetchItems: @escaping (Trigger) -> Observable<[Item]>,
                mapper: @escaping (Item) -> MappedItem) {
        self.init(pageActivityIndicator: pageActivityIndicator,
                  errorTracker: errorTracker,
                  loadTrigger: loadTrigger,
                  fetchItems: fetchItems,
                  reloadTrigger: reloadTrigger,
                  reloadItems: fetchItems,
                  mapper: mapper)
    }
}

extension ListFetchConfig where Item == MappedItem {
    public init(pageActivityIndicator: PageActivityIndicator = PageActivityIndicator(),
                errorTracker: ErrorTracker = ErrorTracker(),
                loadTrigger: Driver<Trigger>,
                reloadTrigger: Driver<Trigger>,
                fetchItems: @escaping (Trigger) -> Observable<[Item]>) {
        self.init(pageActivityIndicator: pageActivityIndicator,
                  errorTracker: errorTracker,
                  loadTrigger: loadTrigger,
                  fetchItems: fetchItems,
                  reloadTrigger: reloadTrigger,
                  reloadItems: fetchItems,
                  mapper: { $0 })
    }
}

public struct ListFetchResult<T> {
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
    public func fetchList<Trigger, Item, MappedItem>(config: ListFetchConfig<Trigger, Item, MappedItem>)
        -> ListFetchResult<MappedItem> {
            
            let error = config.errorTracker.asDriver()
            let isLoading = config.pageActivityIndicator.isLoading
            let isReloading = config.pageActivityIndicator.isReloading
            
            let isLoadingOrReloading = Driver.merge(isLoading, isReloading)
                .startWith(false)
            
            let items = Driver<ScreenLoadingType<Trigger>>
                .merge(
                    config.loadTrigger.map { ScreenLoadingType.loading($0) },
                    config.reloadTrigger.map { ScreenLoadingType.reloading($0) }
                )
                .withLatestFrom(isLoadingOrReloading) {
                    (triggerType: $0, loading: $1)
                }
                .filter { !$0.loading }
                .map { $0.triggerType }
                .flatMapLatest { triggerType -> Driver<[Item]> in
                    switch triggerType {
                    case .loading(let triggerInput):
                        return config.fetchItems(triggerInput)
                            .trackError(config.errorTracker)
                            .trackActivity(config.pageActivityIndicator.loadingIndicator)
                            .asDriverOnErrorJustComplete()
                    case .reloading(let triggerInput):
                        return config.reloadItems(triggerInput)
                            .trackError(config.errorTracker)
                            .trackActivity(config.pageActivityIndicator.reloadingIndicator)
                            .asDriverOnErrorJustComplete()
                    }
                }
                .map { $0.map(config.mapper) }
            
            return ListFetchResult(
                items: items,
                error: error,
                isLoading: isLoading,
                isReloading: isReloading
            )
    }
}

