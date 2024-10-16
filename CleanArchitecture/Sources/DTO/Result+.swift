import ValidatedPropertyKit

typealias ValidationResult = Result<Void, ValidationError>

extension Result where Failure == ValidationError {
    
    var message: String {
        switch self {
        case .success:
            return ""
        case .failure(let error):
            return error.description
        }
    }
    
    var isValid: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    func mapToVoid() -> ValidationResult {
        return self.map { _ in () }
    }
}
