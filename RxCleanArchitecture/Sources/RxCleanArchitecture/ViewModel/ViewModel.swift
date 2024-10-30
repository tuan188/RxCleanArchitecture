import UIKit
import RxSwift
import RxCocoa

/// A protocol that defines a generic view model with an input-output transformation function.
///
/// The `ViewModel` protocol is designed for use in reactive programming, where input events are transformed
/// into output states, providing a clear structure for managing data flow and side effects in the view model.
public protocol ViewModel {
    
    /// The type representing the input events or data for the view model.
    associatedtype Input
    
    /// The type representing the output events or data produced by the view model.
    associatedtype Output
    
    /// Transforms the view model's input into output, managing any necessary subscriptions.
    ///
    /// - Parameters:
    ///   - input: The input events or data for the view model.
    ///   - disposeBag: The `DisposeBag` used to manage subscriptions.
    /// - Returns: The output events or data produced by the transformation.
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output
}

extension ViewModel {
    
    /// Determines if the data collection is empty, based on the loading state and item collection.
    ///
    /// Emits `false` while data is loading, and emits `true` when loading completes if the collection is empty.
    /// This is useful for managing empty states in the UI.
    ///
    /// - Parameters:
    ///   - loadingTrigger: A `Driver` that emits `true` when loading, and `false` when loading completes.
    ///   - dataItems: A `Driver` of the collection being loaded, used to check if data is available.
    /// - Returns: A `Driver` that emits `true` when the collection is empty and not loading.
    public func isDataEmpty<T: Collection>(loadingTrigger: Driver<Bool>, dataItems: Driver<T>) -> Driver<Bool> {
        return Driver
            .combineLatest(loadingTrigger, dataItems) { isLoading, items in
                (isLoading, items.isEmpty)
            }
            .map { isLoading, isEmpty -> Bool in
                if isLoading { return false }
                return isEmpty
            }
            .distinctUntilChanged()
    }
    
    /// Selects an item from a collection at the specified index path.
    ///
    /// Filters out invalid index paths and emits the item at the specified index when available.
    /// This is commonly used for item selection in list-based UIs.
    ///
    /// - Parameters:
    ///   - indexPathTrigger: A `Driver` that emits an `IndexPath` indicating the selected item position.
    ///   - items: A `Driver` containing the collection of items from which to select.
    /// - Returns: A `Driver` that emits the selected item, or does not emit if the index path is out of bounds.
    public func selectItem<T>(at indexPathTrigger: Driver<IndexPath>, from items: Driver<[T]>) -> Driver<T> {
        return indexPathTrigger
            .withLatestFrom(items) { indexPath, items in
                (indexPath, items)
            }
            .filter { indexPath, items in indexPath.row < items.count }
            .map { indexPath, items in
                items[indexPath.row]
            }
    }
}

extension ViewModel where Output == Never {
    
    /// Provides a default implementation for `transform` when the output type is `Never`.
    ///
    /// This allows view models with no output requirements to conform to the `ViewModel` protocol without providing an implementation.
    /// - Parameters:
    ///   - input: The input events or data for the view model.
    ///   - disposeBag: The `DisposeBag` used to manage subscriptions.
    func transform(_ input: Input, disposeBag: DisposeBag) {
        // No implementation required when Output is Never
    }
}
