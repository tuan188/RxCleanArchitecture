import ValidatedPropertyKit

/// A protocol that represents a Data Transfer Object (DTO) with validation capabilities.
public protocol Dto {
    
    /// An array of `ValidatedProperty` instances that represent the validated properties of the DTO.
    ///
    /// Each `ValidatedProperty` contains validation rules and the current validation state of the property.
    var validatedProperties: [ValidatedProperty] { get }
}

public extension Dto {
    
    /// A Boolean value indicating whether all validated properties are valid.
    ///
    /// This property returns `true` if all properties satisfy their validation rules, otherwise `false`.
    var isValid: Bool {
        return validatedProperties.allSatisfy { $0.isValid }
    }
    
    /// An array of `ValidationError` objects for properties that did not pass validation.
    ///
    /// This property returns an array of `ValidationError` instances, one for each invalid property.
    /// If all properties are valid, this array is empty.
    var validationErrors: [ValidationError] {
        return validatedProperties.compactMap { $0.error }
    }
    
    /// An array of error messages for properties that did not pass validation.
    ///
    /// This property returns an array of strings, where each string is a description of a validation error.
    /// If all properties are valid, this array is empty.
    var validationErrorMessages: [String] {
        return validationErrors.map { $0.description }
    }
    
    /// A single `ValidationError` representing all validation errors, or `nil` if all properties are valid.
    ///
    /// If there are any invalid properties, this property returns a `ValidationError` that includes descriptions
    /// of all individual errors. If all properties are valid, this property returns `nil`.
    var validationError: ValidationError? {
        if isValid { return nil }
        return ValidationError(descriptions: validationErrorMessages)
    }
}

public extension Dto {
    
    /// An array of `ValidatedProperty` instances that represent the validated properties of the DTO.
    ///
    /// The default implementation returns an empty array. Classes or structs conforming to `Dto`
    /// should override this to provide the actual properties to be validated.
    var validatedProperties: [ValidatedProperty] {
        return []
    }
}
