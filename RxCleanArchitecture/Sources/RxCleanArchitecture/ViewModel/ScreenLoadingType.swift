/// An enum representing the type of loading state for a screen, with an associated input value.
///
/// `ScreenLoadingType` is useful for distinguishing between an initial loading state and a reloading state,
/// each carrying an input value that can provide context or data for the loading operation.
public enum ScreenLoadingType<Input> {
    
    /// Represents an initial loading state with an associated input value.
    ///
    /// Use this case when the screen is being loaded for the first time or after a significant state change.
    /// - Parameter Input: The associated input value for the loading state.
    case loading(Input)
    
    /// Represents a reloading state with an associated input value.
    ///
    /// Use this case when the screen is reloading data or refreshing content based on the input.
    /// - Parameter Input: The associated input value for the reloading state.
    case reloading(Input)
}
