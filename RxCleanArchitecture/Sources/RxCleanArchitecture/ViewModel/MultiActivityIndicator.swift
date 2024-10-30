import Foundation
import RxSwift
import RxCocoa

/// A class that tracks the loading state of multiple asynchronous operations simultaneously, extending the functionality of `ActivityIndicator`.
///
/// `MultiActivityIndicator` is designed to manage multiple loading states independently and emit `true` if any tracked
/// operation is ongoing, and `false` when all tracked operations have completed.
open class MultiActivityIndicator: ActivityIndicator {
    
    private let _lock = NSRecursiveLock()
    private let _set = BehaviorRelay<Set<String>>(value: [])
    private let _loading: SharedSequence<SharingStrategy, Bool>
    
    /// Initializes a new `MultiActivityIndicator`.
    ///
    /// The loading state is set to `false` initially and will emit `true` if any operations are in progress, returning to `false` only when all have completed.
    override public init() {
        _loading = _set
            .asDriver()
            .map { !$0.isEmpty }
            .distinctUntilChanged()
    }
    
    /// Tracks the loading state of an observable sequence with a unique identifier.
    ///
    /// The method generates a unique identifier for each observable and manages its loading state separately.
    /// Emits `true` while the operation is in progress and `false` once it completes or encounters an error.
    /// - Parameter source: The observable sequence to track.
    /// - Returns: The original observable sequence with multi-activity tracking applied.
    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        let id = UUID().uuidString
        
        return source.asObservable()
            .do(onNext: { [weak self] _ in
                self?.sendStopLoading(id: id)
            }, onError: { [weak self] _ in
                self?.sendStopLoading(id: id)
            }, onCompleted: { [weak self] in
                self?.sendStopLoading(id: id)
            }, onSubscribe: { [weak self] in
                self?.subscribed(id: id)
            })
    }
    
    /// Marks the start of a loading state for a unique identifier.
    ///
    /// The identifier is added to the set of active operations, setting the loading state to `true`.
    /// - Parameter id: A unique identifier for the observable sequence being tracked.
    private func subscribed(id: String) {
        _lock.lock()
        var set = _set.value
        set.insert(id)
        _set.accept(set)
        _lock.unlock()
    }
    
    /// Marks the end of a loading state for a unique identifier.
    ///
    /// The identifier is removed from the set of active operations. If there are no active identifiers remaining,
    /// the loading state is set to `false`.
    /// - Parameter id: The unique identifier for the observable sequence that has completed or encountered an error.
    private func sendStopLoading(id: String) {
        _lock.lock()
        var set = _set.value
        set.remove(id)
        _set.accept(set)
        _lock.unlock()
    }
}
