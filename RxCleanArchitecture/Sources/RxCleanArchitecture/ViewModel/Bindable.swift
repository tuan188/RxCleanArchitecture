import UIKit

/// A protocol that defines a bindable view controller with a view model.
///
/// Classes conforming to `Bindable` are expected to have a view model and a method to bind the view model's data to the UI.
public protocol Bindable: AnyObject {
    
    /// The type of the view model associated with the view controller.
    associatedtype ViewModel
    
    /// The view model instance for the view controller.
    ///
    /// This property is set when binding a view model to the view controller.
    var viewModel: ViewModel! { get set }
    
    /// Binds the view model's data to the view controller's UI elements.
    ///
    /// Implement this method to set up bindings between the view model and the UI components of the view controller.
    func bindViewModel()
}

extension Bindable where Self: UIViewController {
    
    /// Binds a given view model to the view controller.
    ///
    /// This method sets the `viewModel` property, loads the view if needed, and then calls `bindViewModel` to bind the data.
    /// - Parameter model: The view model to bind to the view controller.
    public func bindViewModel(to model: Self.ViewModel) {
        viewModel = model
        loadViewIfNeeded()
        bindViewModel()
    }
}
