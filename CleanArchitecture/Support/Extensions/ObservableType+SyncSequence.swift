//
//  ObservableType+SyncSequence.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 7/25/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa

extension ObservableType where Element: Sequence {
    
    public typealias T = Element.Iterator.Element
    
    /// Create an observable which is an Array of the projected values
    /// the operator produce an array of the same size than the original sequence
    /// and will generate new array every time a new item is emitted
    public func sync<V>(project: @escaping (T) -> Observable<V>) -> Observable<[V]> {
        typealias Pair = (value: V, index: Int) // swiftlint:disable:this nesting
        return self
            .flatMapLatest { (seq) -> Observable<[V]> in
                // get number of element in sequence
                let count = Array(seq).count
                var buffer = Dictionary<Int, V>(minimumCapacity: count) // swiftlint:disable:this syntactic_sugar
                
                return Observable
                    
                    // convert sequence to observable
                    .from(seq)
                    
                    // flatMap into Pair
                    .enumerated()
                    .flatMap({ (index: Int, item: T) -> Observable<Pair> in
                        return Observable.combineLatest(project(item), Observable.just(index)) { (value: $0, index:$1) }
                    })
                    
                    // reduce into a dictionnary using the index as a key
                    // Scan might be more approriate here but it would create a new [Int:V] dictionary
                    // for every iteration, since the accumulator needs to be immutable
                    .map { (item) -> [Int: V] in
                        buffer[item.index] = item.value
                        return buffer
                    }
                    
                    // filter until we get a dictionary of the same size than the original sequence
                    .filter { $0.count == count }
                    
                    // map to an array
                    .map { dic in
                        return Array(0..<count).compactMap { dic[$0] }
                    }
            }
    }
}
