import RxSwift
import RxCocoa

extension ObservableType {
    
    /// Catches an error and completes the sequence.
    ///
    /// If an error occurs, this function completes the sequence instead of propagating the error.
    /// - Returns: An observable sequence that completes when an error is caught.
    public func catchErrorJustComplete() -> Observable<Element> {
        self.catch { error in
            return Observable.empty()
        }
    }
    
    /// Converts the observable sequence to a `Driver`, completing if an error occurs.
    ///
    /// If an error occurs, this function converts the sequence to a `Driver` that completes instead of propagating the error.
    /// - Returns: A `Driver` that completes when an error is caught.
    public func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { _ in
            return Driver.empty()
        }
    }
    
    /// Maps each element of the sequence to `Void`.
    ///
    /// This is useful when only the completion of the sequence matters, regardless of the element values.
    /// - Returns: An observable sequence containing only `Void` elements.
    public func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
    
    /// Wraps each element of the sequence in an optional.
    ///
    /// This function maps each element to an optional type, effectively adding an additional layer of optionality.
    /// - Returns: An observable sequence where each element is wrapped as an optional.
    public func mapToOptional() -> Observable<Element?> {
        return map { value -> Element? in value }
    }
    
    /// Unwraps optional elements from the sequence.
    ///
    /// Filters out any `nil` values, emitting only non-optional elements.
    /// - Returns: An observable sequence containing only non-optional elements.
    public func unwrap<T>() -> Observable<T> where Element == T? {
        return flatMap { Observable.from(optional: $0) }
    }
}

extension ObservableType where Element == Bool {
    
    /// Negates each Boolean element in the sequence.
    ///
    /// Maps `true` to `false` and `false` to `true` for each element.
    /// - Returns: An observable sequence where each Boolean element is the negation of the original value.
    public func not() -> Observable<Bool> {
        return map(!)
    }
    
    /// Combines multiple Boolean sequences using the logical OR operation.
    ///
    /// Emits `true` if any of the sources emit `true`; otherwise, emits `false`.
    /// - Parameter sources: A variadic list of Boolean observable sequences.
    /// - Returns: An observable sequence that emits `true` if any source emits `true`.
    public static func or(_ sources: Observable<Bool>...)
        -> Observable<Bool> {
            return Observable.combineLatest(sources)
                .map { $0.contains(true) }
    }
    
    /// Combines multiple Boolean sequences using the logical AND operation.
    ///
    /// Emits `true` only if all of the sources emit `true`; otherwise, emits `false`.
    /// - Parameter sources: A variadic list of Boolean observable sequences.
    /// - Returns: An observable sequence that emits `true` if all sources emit `true`.
    public static func and(_ sources: Observable<Bool>...)
        -> Observable<Bool> {
            return Observable.combineLatest(sources)
                .map { $0.allSatisfy { $0 } }
    }
}
