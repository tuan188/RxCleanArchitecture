import ValidatedPropertyKit

public protocol Dto {
    var validatedProperties: [ValidatedProperty] { get }
}

public extension Dto {
    var isValid: Bool {
        return validatedProperties.allSatisfy { $0.isValid }
    }
    
    var validationErrors: [ValidationError] {
        return validatedProperties.compactMap { $0.error }
    }
    
    var validationErrorMessages: [String] {
        return validationErrors.map { $0.description }
    }
    
    var validationError: ValidationError? {
        if isValid { return nil }
        return ValidationError(descriptions: validationErrorMessages)
    }
}

public extension Dto {
    var validatedProperties: [ValidatedProperty] {
        return []
    }
}
