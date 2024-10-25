import UIKit

public protocol Bindable: AnyObject {
    associatedtype ViewModel
    
    var viewModel: ViewModel! { get set }
    
    func bindViewModel()
}

extension Bindable where Self: UIViewController {
    public func bindViewModel(to model: Self.ViewModel) {
        viewModel = model
        loadViewIfNeeded()
        bindViewModel()
    }
}
