import Foundation

/// A struct representing a validation error with a description.
public struct ValidationError: LocalizedError {
    
    /// A textual description of the validation error.
    ///
    /// This property provides a user-readable description of the validation error.
    public var errorDescription: String? { description }
    
    /// The detailed description of the validation error.
    public let description: String
    
    /// Creates a new validation error with a specified description.
    /// - Parameter description: A `String` describing the validation error.
    public init(description: String) {
        self.description = description
    }
    
    /// Creates a new validation error from multiple error descriptions.
    ///
    /// Joins the descriptions into a single string, separated by newlines.
    /// - Parameter descriptions: An array of `String` descriptions representing individual validation errors.
    public init(descriptions: [String]) {
        self.description = descriptions.joined(separator: "\n")
    }
}
