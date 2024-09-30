//
//  Driver+.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 7/25/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa

extension SharedSequenceConvertibleType {
    
    public func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
    
    public func mapToOptional() -> SharedSequence<SharingStrategy, Element?> {
        return map { value -> Element? in value }
    }
    
    public func unwrap<T>() -> SharedSequence<SharingStrategy, T> where Element == T? {
        return flatMap { SharedSequence.from(optional: $0) }
    }
}

extension SharedSequenceConvertibleType where Element == Bool {
    public func not() -> SharedSequence<SharingStrategy, Bool> {
        return map(!)
    }
    
    public static func or(_ sources: SharedSequence<DriverSharingStrategy, Bool>...)
        -> SharedSequence<DriverSharingStrategy, Bool> {
            return Driver.combineLatest(sources)
                .map { $0.contains(true) }
    }
    
    public static func and(_ sources: SharedSequence<DriverSharingStrategy, Bool>...)
        -> SharedSequence<DriverSharingStrategy, Bool> {
            return Driver.combineLatest(sources)
                .map { $0.allSatisfy { $0 } }
    }
}
