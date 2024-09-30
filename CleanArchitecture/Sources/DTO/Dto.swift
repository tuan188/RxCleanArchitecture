import ValidatedPropertyKit

public protocol Dto {
    var validatedProperties: [ValidatedProperty] { get }
}

extension Dto {
    public var isValid: Bool {
        return validatedProperties.allSatisfy { $0.isValid }
    }
    
    public var validationErrors: [ValidationError] {
        return validatedProperties.compactMap { $0.validationError }
    }
    
    public var validationErrorMessages: [String] {
        return validationErrors.map { $0.description }
    }
    
    public var validationError: ValidationError? {
        if isValid { return nil }
        return ValidationError(messages: validationErrorMessages)
    }
}

extension Dto {
    public var validatedProperties: [ValidatedProperty] {
        return []
    }
}
