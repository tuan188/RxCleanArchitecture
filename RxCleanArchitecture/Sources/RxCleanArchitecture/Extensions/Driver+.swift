import RxSwift
import RxCocoa

extension SharedSequenceConvertibleType {
    
    /// Maps each element of the sequence to `Void`.
    ///
    /// This is useful when only the completion of the sequence matters, regardless of the element values.
    /// - Returns: A shared sequence containing only `Void` elements.
    public func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
    
    /// Wraps each element of the sequence in an optional.
    ///
    /// This function maps each element to an optional type, effectively adding an additional layer of optionality.
    /// - Returns: A shared sequence where each element is wrapped as an optional.
    public func mapToOptional() -> SharedSequence<SharingStrategy, Element?> {
        return map { value -> Element? in value }
    }
    
    /// Unwraps optional elements from the sequence.
    ///
    /// Filters out any `nil` values, emitting only non-optional elements.
    /// - Returns: A shared sequence containing only non-optional elements.
    public func unwrap<T>() -> SharedSequence<SharingStrategy, T> where Element == T? {
        return flatMap { SharedSequence.from(optional: $0) }
    }
}

extension SharedSequenceConvertibleType where Element == Bool {
    
    /// Negates each Boolean element in the sequence.
    ///
    /// Maps `true` to `false` and `false` to `true` for each element.
    /// - Returns: A shared sequence where each Boolean element is the negation of the original value.
    public func not() -> SharedSequence<SharingStrategy, Bool> {
        return map(!)
    }
    
    /// Combines multiple Boolean sequences using the logical OR operation.
    ///
    /// Emits `true` if any of the sources emit `true`; otherwise, emits `false`.
    /// - Parameter sources: A variadic list of Boolean shared sequences.
    /// - Returns: A shared sequence that emits `true` if any source emits `true`.
    public static func or(_ sources: SharedSequence<DriverSharingStrategy, Bool>...)
        -> SharedSequence<DriverSharingStrategy, Bool> {
            return Driver.combineLatest(sources)
                .map { $0.contains(true) }
    }
    
    /// Combines multiple Boolean sequences using the logical AND operation.
    ///
    /// Emits `true` only if all of the sources emit `true`; otherwise, emits `false`.
    /// - Parameter sources: A variadic list of Boolean shared sequences.
    /// - Returns: A shared sequence that emits `true` if all sources emit `true`.
    public static func and(_ sources: SharedSequence<DriverSharingStrategy, Bool>...)
        -> SharedSequence<DriverSharingStrategy, Bool> {
            return Driver.combineLatest(sources)
                .map { $0.allSatisfy { $0 } }
    }
}
