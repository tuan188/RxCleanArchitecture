import Foundation
import RxSwift
import RxCocoa

/// A class to track errors emitted by observables, allowing them to be observed as a `Driver` or an `Observable`.
///
/// `ErrorTracker` is useful for capturing and handling errors in reactive streams, providing a consistent way
/// to observe errors in the UI layer.
open class ErrorTracker: SharedSequenceConvertibleType {
    public typealias SharingStrategy = DriverSharingStrategy
    private let _subject = PublishSubject<Error>()
    
    /// Initializes a new `ErrorTracker`.
    ///
    /// The tracker captures errors and emits them for observation without terminating the original observable.
    public init() {}
    
    /// Tracks errors from the specified observable sequence.
    ///
    /// Any errors emitted by the source sequence are passed to the error tracker, allowing them to be observed
    /// without disrupting the source sequence.
    /// - Parameter source: The observable sequence to monitor for errors.
    /// - Returns: The original observable sequence with error tracking applied.
    open func trackError<O: ObservableConvertibleType>(from source: O) -> Observable<O.Element> {
        return source.asObservable().do(onError: onError)
    }

    /// Converts the tracked errors to a `Driver` shared sequence.
    ///
    /// This is particularly useful for observing errors in the UI, where you want to avoid propagating errors
    /// to subscribers and instead handle them gracefully.
    /// - Returns: A shared sequence (`Driver`) that emits tracked errors.
    open func asSharedSequence() -> SharedSequence<SharingStrategy, Error> {
        return _subject.asObservable().asDriverOnErrorJustComplete()
    }

    /// Provides the tracked errors as an observable sequence.
    ///
    /// This allows observing errors as they occur without terminating the original observable sequence.
    /// - Returns: An observable sequence that emits tracked errors.
    open func asObservable() -> Observable<Error> {
        return _subject.asObservable()
    }

    /// Handles an error by passing it to the subject for observation.
    ///
    /// This method is called internally whenever an error occurs in the tracked observable sequence.
    /// - Parameter error: The error to be tracked.
    private func onError(_ error: Error) {
        _subject.onNext(error)
    }
    
    deinit {
        _subject.onCompleted()
    }
}

extension ObservableConvertibleType {
    
    /// Tracks errors from the observable sequence using a specified `ErrorTracker`.
    ///
    /// Any errors emitted by the sequence are passed to the `ErrorTracker` for observation, allowing them to be handled
    /// separately from the main observable stream.
    /// - Parameter errorTracker: The `ErrorTracker` instance to monitor for errors.
    /// - Returns: The original observable sequence with error tracking applied.
    public func trackError(_ errorTracker: ErrorTracker) -> Observable<Element> {
        return errorTracker.trackError(from: self)
    }
}
