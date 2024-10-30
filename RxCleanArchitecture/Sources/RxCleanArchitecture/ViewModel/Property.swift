import UIKit
import RxSwift
import RxCocoa

/// A property wrapper that provides thread-safe, reactive access to a property value.
///
/// `Property` is backed by a `BehaviorRelay` and provides both synchronous and reactive access to the value.
@propertyWrapper
public struct Property<Value> {
    
    private var subject: BehaviorRelay<Value>
    private let lock = NSLock()
    
    /// The wrapped value of the property.
    ///
    /// Accessing this value is thread-safe. When the value is set, it updates the `BehaviorRelay` to emit the new value.
    public var wrappedValue: Value {
        get { return load() }
        set { store(newValue: newValue) }
    }
    
    /// The projected value of the property, providing reactive access to the property through a `BehaviorRelay`.
    ///
    /// Access this property to observe value changes as a reactive sequence.
    public var projectedValue: BehaviorRelay<Value> {
        return self.subject
    }
    
    /// Initializes a new `Property` with the specified initial value.
    ///
    /// - Parameter wrappedValue: The initial value of the property.
    public init(wrappedValue: Value) {
        subject = BehaviorRelay(value: wrappedValue)
    }
    
    /// Loads the current value of the property in a thread-safe manner.
    ///
    /// This method locks the underlying `BehaviorRelay` to safely access the value.
    /// - Returns: The current value of the property.
    private func load() -> Value {
        lock.lock()
        defer { lock.unlock() }
        return subject.value
    }
    
    /// Stores a new value in the property in a thread-safe manner.
    ///
    /// This method locks the underlying `BehaviorRelay` to safely update the value and notifies observers of the change.
    /// - Parameter newValue: The new value to store in the property.
    private mutating func store(newValue: Value) {
        lock.lock()
        defer { lock.unlock() }
        subject.accept(newValue)
    }
}
