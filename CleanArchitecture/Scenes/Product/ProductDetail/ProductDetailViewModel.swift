//
//  ProductDetailViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/22/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa
import Factory

class ProductDetailViewModel {
    let product: Product
    
    init(product: Product) {
        self.product = product
    }
}

// MARK: - ViewModel
extension ProductDetailViewModel: ViewModel {
    struct Input {
        let load: Driver<Void>
    }

    struct Output {
        @Property var cells = [Cell]()
    }

    enum Cell {
        case name(String)
        case price(String)
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.load
            .map { self.product }
            .map { product -> [Cell] in
                return [
                    Cell.name(product.name),
                    Cell.price(product.price.currency)
                ]
            }
            .drive(output.$cells)
            .disposed(by: disposeBag)
        
        return output
    }
}
