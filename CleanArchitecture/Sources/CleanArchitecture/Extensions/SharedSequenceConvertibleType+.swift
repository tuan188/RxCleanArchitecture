//
//  SharedSequenceConvertibleType+.swift
//  CleanArchitecture
//
//  Created by truong.anh.tuan on 16/10/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public extension SharedSequenceConvertibleType {
    func flatMapLatest<Object: AnyObject, Sharing, Result>(
        _ object: Object,
        _ selector: @escaping (Object, Element) -> SharedSequence<Sharing, Result>
    )
    -> SharedSequence<Sharing, Result> {
        weak var weakObject = object
        
        return flatMapLatest { element in
            guard let object = weakObject else {
                return SharedSequence<Sharing, Result>.empty()
            }
            return selector(object, element)
        }
    }
    
    func map<Object: AnyObject, Result>(_ object: Object,_ selector: @escaping (Object, Element) -> Result)
    -> SharedSequence<SharingStrategy, Result> {
        unowned let object = object
        return map { selector(object, $0) }
    }
}
