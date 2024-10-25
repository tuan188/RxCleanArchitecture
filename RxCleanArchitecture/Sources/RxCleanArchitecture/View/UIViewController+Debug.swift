import UIKit

extension UIViewController {
    public func logDeinit() {
        print(String(describing: type(of: self)) + " deinit")
    }
}
