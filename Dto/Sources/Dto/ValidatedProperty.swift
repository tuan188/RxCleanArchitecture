import ValidatedPropertyKit
import Foundation

/// A protocol representing a property with validation capabilities.
public protocol ValidatedProperty {
    
    /// A Boolean value indicating whether the property is valid.
    var isValid: Bool { get }
    
    /// An optional `ValidationError` describing why the property is invalid.
    ///
    /// Returns `nil` if the property is valid, otherwise provides details about the validation failure.
    var error: ValidationError? { get }
}

extension Validated: ValidatedProperty {
    
    /// An optional `ValidationError` describing why the validation failed.
    ///
    /// Returns a `ValidationError` with a description if the property is invalid, or `nil` if it is valid.
    public var error: ValidationError? {
        if let errorMessage {
            return ValidationError(description: errorMessage)
        }
        
        return nil
    }

    /// A `ValidationResult` representing the outcome of the validation.
    ///
    /// - Returns: `.success` if the property is valid. If invalid, returns `.failure` with an associated `ValidationError`.
    /// If no specific error is provided, a generic "Invalid value" error is returned.
    public var result: ValidationResult {
        if isValid {
            return .success(())
        } else if let error {
            return .failure(error)
        } else {
            return .failure(ValidationError(description: NSLocalizedString("dto.error.invalid-value",
                                                                           value: "Invalid value",
                                                                           comment: "")))
        }
    }
}
