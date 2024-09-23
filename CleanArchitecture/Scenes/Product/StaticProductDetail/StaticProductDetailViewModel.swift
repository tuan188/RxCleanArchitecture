//
//  StaticProductDetailViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/24/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa
import MGArchitecture

class StaticProductDetailViewModel {
    let product: Product
    
    init(product: Product) {
        self.product = product
    }
}

// MARK: - ViewModel
extension StaticProductDetailViewModel: ViewModel {
    struct Input {
        let load: Driver<Void>
    }

    struct Output {
        @Property var name = ""
        @Property var price = ""
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        let product = input.load
            .map { self.product }
        
        product.map { $0.name }
            .drive(output.$name)
            .disposed(by: disposeBag)
        
        product.map { $0.price.currency }
            .drive(output.$price)
            .disposed(by: disposeBag)
        
        return output
    }
}
