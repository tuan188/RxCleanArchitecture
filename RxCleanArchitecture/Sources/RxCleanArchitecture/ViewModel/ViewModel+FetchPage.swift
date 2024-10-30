import UIKit
import RxSwift
import RxCocoa

public struct PageFetchConfig<Trigger, Item, MappedItem> {
    let pageSubject: BehaviorRelay<PagingInfo<MappedItem>>
    let pageActivityIndicator: PageActivityIndicator
    let errorTracker: ErrorTracker
    let loadTrigger: Driver<Trigger>
    let reloadTrigger: Driver<Trigger>
    let loadMoreTrigger: Driver<Trigger>
    let fetchItems: (Trigger) -> Observable<PagingInfo<Item>>
    let reloadItems: (Trigger) -> Observable<PagingInfo<Item>>
    let loadMoreItems: (Trigger, Int) -> Observable<PagingInfo<Item>>
    let mapper: (Item) -> MappedItem
    
    public init(pageSubject: BehaviorRelay<PagingInfo<MappedItem>>,
                pageActivityIndicator: PageActivityIndicator,
                errorTracker: ErrorTracker,
                loadTrigger: Driver<Trigger>,
                fetchItems: @escaping (Trigger) -> Observable<PagingInfo<Item>>,
                reloadTrigger: Driver<Trigger>,
                reloadItems: @escaping (Trigger) -> Observable<PagingInfo<Item>>,
                loadMoreTrigger: Driver<Trigger>,
                loadMoreItems: @escaping (Trigger, Int) -> Observable<PagingInfo<Item>>,
                mapper: @escaping (Item) -> MappedItem) {
        self.pageSubject = pageSubject
        self.pageActivityIndicator = pageActivityIndicator
        self.errorTracker = errorTracker
        self.loadTrigger = loadTrigger
        self.reloadTrigger = reloadTrigger
        self.loadMoreTrigger = loadMoreTrigger
        self.fetchItems = fetchItems
        self.reloadItems = reloadItems
        self.loadMoreItems = loadMoreItems
        self.mapper = mapper
    }
}

extension PageFetchConfig {
    public init(pageSubject: BehaviorRelay<PagingInfo<MappedItem>> = BehaviorRelay(value: PagingInfo<MappedItem>()),
                pageActivityIndicator: PageActivityIndicator = PageActivityIndicator(),
                errorTracker: ErrorTracker = ErrorTracker(),
                loadTrigger: Driver<Trigger>,
                reloadTrigger: Driver<Trigger>,
                loadMoreTrigger: Driver<Trigger>,
                fetchItems: @escaping (Trigger, Int) -> Observable<PagingInfo<Item>>,
                mapper: @escaping (Item) -> MappedItem) {
        self.init(pageSubject: pageSubject,
                  pageActivityIndicator: pageActivityIndicator,
                  errorTracker: errorTracker,
                  loadTrigger: loadTrigger,
                  fetchItems: { triggerInput in fetchItems(triggerInput, 1) },
                  reloadTrigger: reloadTrigger,
                  reloadItems: { triggerInput in fetchItems(triggerInput, 1) },
                  loadMoreTrigger: loadMoreTrigger,
                  loadMoreItems: fetchItems,
                  mapper: mapper)
    }
}

extension PageFetchConfig where Trigger == Void {
    public init(pageSubject: BehaviorRelay<PagingInfo<MappedItem>> = BehaviorRelay(value: PagingInfo<MappedItem>()),
                pageActivityIndicator: PageActivityIndicator = PageActivityIndicator(),
                errorTracker: ErrorTracker = ErrorTracker(),
                loadTrigger: Driver<Trigger>,
                reloadTrigger: Driver<Trigger>,
                loadMoreTrigger: Driver<Trigger>,
                fetchItems: @escaping (Int) -> Observable<PagingInfo<Item>>,
                mapper: @escaping (Item) -> MappedItem) {
        self.init(pageSubject: pageSubject,
                  pageActivityIndicator: pageActivityIndicator,
                  errorTracker: errorTracker,
                  loadTrigger: loadTrigger,
                  fetchItems: { _ in fetchItems(1) },
                  reloadTrigger: reloadTrigger,
                  reloadItems: { _ in fetchItems(1) },
                  loadMoreTrigger: loadMoreTrigger,
                  loadMoreItems: { _, page in fetchItems(page) },
                  mapper: mapper)
    }
}

extension PageFetchConfig where Item == MappedItem {
    public init(pageSubject: BehaviorRelay<PagingInfo<MappedItem>> = BehaviorRelay(value: PagingInfo<MappedItem>()),
                pageActivityIndicator: PageActivityIndicator = PageActivityIndicator(),
                errorTracker: ErrorTracker = ErrorTracker(),
                loadTrigger: Driver<Trigger>,
                reloadTrigger: Driver<Trigger>,
                loadMoreTrigger: Driver<Trigger>,
                fetchItems: @escaping (Trigger, Int) -> Observable<PagingInfo<Item>>) {
        self.init(pageSubject: pageSubject,
                  pageActivityIndicator: pageActivityIndicator,
                  errorTracker: errorTracker,
                  loadTrigger: loadTrigger,
                  fetchItems: { triggerInput in fetchItems(triggerInput, 1) },
                  reloadTrigger: reloadTrigger,
                  reloadItems: { triggerInput in fetchItems(triggerInput, 1) },
                  loadMoreTrigger: loadMoreTrigger,
                  loadMoreItems: fetchItems,
                  mapper: { $0 })
    }
}

extension PageFetchConfig where Item == MappedItem, Trigger == Void {
    public init(pageSubject: BehaviorRelay<PagingInfo<MappedItem>> = BehaviorRelay(value: PagingInfo<MappedItem>()),
                pageActivityIndicator: PageActivityIndicator = PageActivityIndicator(),
                errorTracker: ErrorTracker = ErrorTracker(),
                loadTrigger: Driver<Trigger>,
                reloadTrigger: Driver<Trigger>,
                loadMoreTrigger: Driver<Trigger>,
                fetchItems: @escaping (Int) -> Observable<PagingInfo<Item>>) {
        self.init(pageSubject: pageSubject,
                  pageActivityIndicator: pageActivityIndicator,
                  errorTracker: errorTracker,
                  loadTrigger: loadTrigger,
                  fetchItems: { _ in fetchItems(1) },
                  reloadTrigger: reloadTrigger,
                  reloadItems: { _ in fetchItems(1) },
                  loadMoreTrigger: loadMoreTrigger,
                  loadMoreItems: { _, page in fetchItems(page) },
                  mapper: { $0 })
    }
}

public struct PageFetchResult<T> {
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
    public func fetchPage<Trigger, Item, MappedItem>(config: PageFetchConfig<Trigger, Item, MappedItem>)
    -> PageFetchResult<MappedItem> {
        
        let error = config.errorTracker.asDriver()
        let isLoading = config.pageActivityIndicator.isLoading
        let isReloading = config.pageActivityIndicator.isReloading
        
        let loadingMoreSubject = PublishSubject<Bool>()
        
        let isLoadingMore = Driver.merge(
            config.pageActivityIndicator.isLoadingMore,
            loadingMoreSubject.asDriverOnErrorJustComplete()
        )
        
        let isLoadingOrLoadingMore = Driver.merge(isLoading, isReloading, isLoadingMore)
            .startWith(false)
        
        let loadItems = Driver<ScreenLoadingType<Trigger>>
            .merge(
                config.loadTrigger.map { ScreenLoadingType.loading($0) },
                config.reloadTrigger.map { ScreenLoadingType.reloading($0) }
            )
            .withLatestFrom(isLoadingOrLoadingMore) {
                (triggerType: $0, loading: $1)
            }
            .filter { !$0.loading }
            .map { $0.triggerType }
            .flatMapLatest { triggerType -> Driver<PagingInfo<Item>> in
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
            .do(onNext: { page in
                let newPage = PagingInfo<MappedItem>(
                    page: page.page,
                    items: page.items.map(config.mapper),
                    hasMorePages: page.hasMorePages,
                    totalItems: page.totalItems,
                    itemsPerPage: page.itemsPerPage,
                    totalPages: page.totalPages
                )
                
                config.pageSubject.accept(newPage)
            })
        
        let loadMoreItems = config.loadMoreTrigger
            .withLatestFrom(isLoadingOrLoadingMore) {
                (triggerInput: $0, loading: $1)
            }
            .filter { !$0.loading }
            .map { $0.triggerInput }
            .do(onNext: { _ in
                if config.pageSubject.value.items.isEmpty {
                    loadingMoreSubject.onNext(false)
                }
            })
            .filter { _ in !config.pageSubject.value.items.isEmpty }
            .flatMapLatest { triggerInput -> Driver<PagingInfo<Item>> in
                let page = config.pageSubject.value.page
                
                return config.loadMoreItems(triggerInput, page + 1)
                    .trackError(config.errorTracker)
                    .trackActivity(config.pageActivityIndicator.loadingMoreIndicator)
                    .asDriverOnErrorJustComplete()
            }
            .filter { !$0.items.isEmpty || !$0.hasMorePages }
            .do(onNext: { page in
                let currentPage = config.pageSubject.value
                let items = currentPage.items + page.items.map(config.mapper)
                
                let newPage = PagingInfo<MappedItem>(
                    page: page.page,
                    items: items,
                    hasMorePages: page.hasMorePages,
                    totalItems: page.totalItems,
                    itemsPerPage: page.itemsPerPage,
                    totalPages: page.totalPages
                )
                
                config.pageSubject.accept(newPage)
            })
        
        let page = Driver.merge(loadItems, loadMoreItems)
            .withLatestFrom(config.pageSubject.asDriver())
        
        return PageFetchResult(
            page: page,
            error: error,
            isLoading: isLoading,
            isReloading: isReloading,
            isLoadingMore: isLoadingMore
        )
        
    }
}
