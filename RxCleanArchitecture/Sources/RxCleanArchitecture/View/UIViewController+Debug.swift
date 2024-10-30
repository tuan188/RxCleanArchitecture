import UIKit

extension UIViewController {
    
    /// Logs a message to the console when the view controller is deinitialized.
    ///
    /// This function prints the class name of the view controller followed by "deinit", helping track the
    /// deinitialization of view controllers for debugging purposes.
    public func logDeinit() {
        print(String(describing: type(of: self)) + " deinit")
    }
}
