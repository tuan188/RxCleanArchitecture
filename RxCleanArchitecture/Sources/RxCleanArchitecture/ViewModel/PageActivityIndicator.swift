import UIKit
import RxSwift
import RxCocoa

/// A class to manage different loading states for paginated data, tracking initial loading, reloading, and loading more operations independently.
open class PageActivityIndicator {
    
    /// The activity indicator for the initial loading state.
    public var loadingIndicator: MultiActivityIndicator
    
    /// The activity indicator for the reloading state.
    public var reloadingIndicator: MultiActivityIndicator
    
    /// The activity indicator for the loading more state.
    public var loadingMoreIndicator: MultiActivityIndicator
    
    /// Initializes a new `PageActivityIndicator` with default `MultiActivityIndicator` instances for each loading state.
    public init() {
        loadingIndicator = MultiActivityIndicator()
        reloadingIndicator = MultiActivityIndicator()
        loadingMoreIndicator = MultiActivityIndicator()
    }
    
    /// Initializes a new `PageActivityIndicator` with specified `MultiActivityIndicator` instances.
    ///
    /// - Parameters:
    ///   - loadingIndicator: The `MultiActivityIndicator` instance for the initial loading state.
    ///   - reloadingIndicator: The `MultiActivityIndicator` instance for the reloading state.
    ///   - loadingMoreIndicator: The `MultiActivityIndicator` instance for the loading more state.
    public init(loadingIndicator: MultiActivityIndicator,
                reloadingIndicator: MultiActivityIndicator,
                loadingMoreIndicator: MultiActivityIndicator) {
        self.loadingIndicator = loadingIndicator
        self.reloadingIndicator = reloadingIndicator
        self.loadingMoreIndicator = loadingMoreIndicator
    }
}

extension PageActivityIndicator {
    
    /// A `Driver` representing the current state of the initial loading process.
    ///
    /// Emits `true` if the initial loading is ongoing, otherwise emits `false`.
    public var isLoading: Driver<Bool> {
        return loadingIndicator.asDriver()
    }
    
    /// A `Driver` representing the current state of the reloading process.
    ///
    /// Emits `true` if reloading is ongoing, otherwise emits `false`.
    public var isReloading: Driver<Bool> {
        return reloadingIndicator.asDriver()
    }
    
    /// A `Driver` representing the current state of the loading more process.
    ///
    /// Emits `true` if loading more data is ongoing, otherwise emits `false`.
    public var isLoadingMore: Driver<Bool> {
        return loadingMoreIndicator.asDriver()
    }
    
    /// A tuple containing the three loading states: `isLoading`, `isReloading`, and `isLoadingMore`.
    ///
    /// This provides easy access to all three loading state drivers in a single destructured form.
    public var destructured: (Driver<Bool>, Driver<Bool>, Driver<Bool>) {
        return (isLoading, isReloading, isLoadingMore)
    }
}
