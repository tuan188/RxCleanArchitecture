import Foundation
import RxSwift
import RxCocoa

/// A class to track the loading state of asynchronous operations, emitting `true` when an operation is ongoing and `false` when complete.
///
/// `ActivityIndicator` is useful for managing loading indicators in an app by converting the loading state into a `Driver`
/// that can be observed by the UI layer.
open class ActivityIndicator: SharedSequenceConvertibleType {
    public typealias Element = Bool
    public typealias SharingStrategy = DriverSharingStrategy
    
    private let _lock = NSRecursiveLock()
    private let _variable = BehaviorRelay<Bool>(value: false)
    private let _loading: SharedSequence<SharingStrategy, Bool>
    
    /// Initializes a new `ActivityIndicator`.
    ///
    /// The loading state is set to `false` initially and will emit `true` during active operations, returning to `false` when complete.
    public init() {
        _loading = _variable.asDriver()
            .distinctUntilChanged()
    }
    
    /// Tracks the loading state of an observable sequence.
    ///
    /// Emits `true` when the observable begins, and `false` upon completion or if an error occurs.
    /// - Parameter source: The observable sequence to track.
    /// - Returns: The original observable sequence with tracking applied.
    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        return source.asObservable()
            .do(onNext: { _ in
                self.sendStopLoading()
            }, onError: { _ in
                self.sendStopLoading()
            }, onCompleted: {
                self.sendStopLoading()
            }, onSubscribe: subscribed)
    }
    
    /// Locks and sets the loading state to `true`, indicating an operation is in progress.
    private func subscribed() {
        _lock.lock()
        _variable.accept(true)
        _lock.unlock()
    }
    
    /// Locks and sets the loading state to `false`, indicating an operation has completed or failed.
    private func sendStopLoading() {
        _lock.lock()
        _variable.accept(false)
        _lock.unlock()
    }
    
    /// Converts the activity indicator's loading state to a shared sequence.
    ///
    /// - Returns: A shared sequence of the loading state (`true` for loading, `false` for idle).
    open func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return _loading
    }
}

extension ObservableConvertibleType {
    
    /// Tracks the observable sequence with the provided `ActivityIndicator`.
    ///
    /// The activity indicator will emit `true` when the sequence begins and `false` when it completes or encounters an error.
    /// - Parameter activityIndicator: The `ActivityIndicator` instance to track the observable sequence.
    /// - Returns: The original observable sequence, with loading state tracking applied.
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        return activityIndicator.trackActivityOfObservable(self)
    }
}
