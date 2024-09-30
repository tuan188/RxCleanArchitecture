//
//  Property.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 8/25/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@propertyWrapper
public struct Property<Value> {
    
    private var subject: BehaviorRelay<Value>
    private let lock = NSLock()
    
    public var wrappedValue: Value {
        get { return load() }
        set { store(newValue: newValue) }
    }
    
    public var projectedValue: BehaviorRelay<Value> {
        return self.subject
    }
    
    public init(wrappedValue: Value) {
        subject = BehaviorRelay(value: wrappedValue)
    }
    
    private func load() -> Value {
        lock.lock()
        defer { lock.unlock() }
        return subject.value
    }
    
    private mutating func store(newValue: Value) {
        lock.lock()
        defer { lock.unlock() }
        subject.accept(newValue)
    }
}
