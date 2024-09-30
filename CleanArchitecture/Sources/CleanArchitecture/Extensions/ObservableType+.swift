//
//  ObservableType+.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/1/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa

extension ObservableType {
    
    public func catchErrorJustComplete() -> Observable<Element> {
        return catchError { _ in
            return Observable.empty()
        }
    }
    
    public func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { _ in
            return Driver.empty()
        }
    }
    
    public func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
    
    public func mapToOptional() -> Observable<Element?> {
        return map { value -> Element? in value }
    }
    
    public func unwrap<T>() -> Observable<T> where Element == T? {
        return flatMap { Observable.from(optional: $0) }
    }
}

extension ObservableType where Element == Bool {
    public func not() -> Observable<Bool> {
        return map(!)
    }
    
    public static func or(_ sources: Observable<Bool>...)
        -> Observable<Bool> {
            return Observable.combineLatest(sources)
                .map { $0.contains(true) }
    }
    
    public static func and(_ sources: Observable<Bool>...)
        -> Observable<Bool> {
            return Observable.combineLatest(sources)
                .map { $0.allSatisfy { $0 } }
    }
}
