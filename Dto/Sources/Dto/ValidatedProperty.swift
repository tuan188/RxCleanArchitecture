import ValidatedPropertyKit

public protocol ValidatedProperty {
    var isValid: Bool { get }
    var error: ValidationError? { get }
}

extension Validated: ValidatedProperty {
    public var error: ValidationError? {
        if let errorMessage {
            return ValidationError(description: errorMessage)
        }
        
        return nil
    }

    public var result: ValidationResult {
        if isValid {
            return .success(())
        } else if let error {
            return.failure(error)
        } else {
            return .failure(ValidationError(description: "Invalid value"))
        }
    }
}
