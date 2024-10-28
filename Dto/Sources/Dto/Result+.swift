import ValidatedPropertyKit

/// A type alias representing the result of a validation operation.
/// - Success: Indicates the validation passed successfully with no errors.
/// - Failure: Contains a `ValidationError` if validation failed.
public typealias ValidationResult = Result<Void, ValidationError>

extension Result where Failure == ValidationError {
    
    /// A string message describing the validation result.
    ///
    /// Returns an empty string if the result is `.success`. If the result is `.failure`, it returns the description
    /// of the `ValidationError`.
    public var message: String {
        switch self {
        case .success:
            return ""
        case .failure(let error):
            return error.description
        }
    }
    
    /// A Boolean value indicating whether the validation result is successful.
    ///
    /// Returns `true` if the result is `.success` (indicating the validation passed),
    /// or `false` if the result is `.failure`.
    public var isValid: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    /// Maps the result to a `ValidationResult` with a `Void` success type.
    ///
    /// This function converts any successful result to a `Void` result, discarding any associated value.
    /// If the result is `.failure`, it passes through the `ValidationError`.
    /// - Returns: A `ValidationResult` of type `Void` on success, or the existing `ValidationError` on failure.
    public func mapToVoid() -> ValidationResult {
        return self.map { _ in () }
    }
}
