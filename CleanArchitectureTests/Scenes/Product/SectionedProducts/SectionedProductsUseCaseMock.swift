//
//  SectionedProductsUseCaseMock.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/7/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import RxSwift

final class SectionedProductsUseCaseMock: SectionedProductsUseCaseType {
    
    // MARK: - getProductList
    
    var getProductListCalled = false
    
    var getProductListReturnValue: Observable<PagingInfo<Product>> = {
        let items = [
            Product().with { $0.id = 1 }
        ]
        
        let page = PagingInfo<Product>(page: 1, items: items)
        return Observable.just(page)
    }()
    
    func getProductList(page: Int) -> Observable<PagingInfo<Product>> {
        getProductListCalled = true
        return getProductListReturnValue
    }
}
