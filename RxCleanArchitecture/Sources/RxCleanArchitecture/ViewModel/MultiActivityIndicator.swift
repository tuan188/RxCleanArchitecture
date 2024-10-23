//
//  MultiActivityIndicator.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 7/8/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class MultiActivityIndicator: ActivityIndicator {
    private let _lock = NSRecursiveLock()
    private let _set = BehaviorRelay<Set<String>>(value: [])
    private let _loading: SharedSequence<SharingStrategy, Bool>
    
    override public init() {
        _loading = _set
            .asDriver()
            .map { !$0.isEmpty }
            .distinctUntilChanged()
    }
    
    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        let id = UUID().uuidString
        
        return source.asObservable()
            .do(onNext: { [weak self] _ in
                self?.sendStopLoading(id: id)
            }, onError: { [weak self] _ in
                self?.sendStopLoading(id: id)
            }, onCompleted: { [weak self] in
                self?.sendStopLoading(id: id)
            }, onSubscribe: { [weak self] in
                self?.subscribed(id: id)
            })
    }
    
    private func subscribed(id: String) {
        _lock.lock()
        var set = _set.value
        set.insert(id)
        _set.accept(set)
        _lock.unlock()
    }
    
    private func sendStopLoading(id: String) {
        _lock.lock()
        var set = _set.value
        set.remove(id)
        _set.accept(set)
        _lock.unlock()
    }
}
