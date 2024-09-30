//
//  ViewModel+.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 9/3/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension ViewModel {
    public func checkIfDataIsEmpty<T: Collection>(trigger: Driver<Bool>, items: Driver<T>) -> Driver<Bool> {
        return Driver
            .combineLatest(trigger, items) {
                ($0, $1.isEmpty)
            }
            .map { loading, isEmpty -> Bool in
                if loading { return false }
                return isEmpty
            }
            .distinctUntilChanged()
    }
    
    public func select<T>(trigger: Driver<IndexPath>, items: Driver<[T]>) -> Driver<T> {
        return trigger
            .withLatestFrom(items) {
                return ($0, $1)
            }
            .filter { indexPath, items in indexPath.row < items.count }
            .map { indexPath, items in
                return items[indexPath.row]
            }
    }
}

extension ViewModel where Output == Never {
    func transform(_ input: Input, disposeBag: DisposeBag) {
        
    }
}

