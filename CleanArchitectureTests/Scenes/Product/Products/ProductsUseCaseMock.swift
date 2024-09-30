//
//  ProductsUseCaseMock.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/5/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import RxSwift

final class ProductsUseCaseMock: ProductsUseCaseType {
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

    // MARK: - deleteProduct
    
    var deleteProductCalled = false
    var deleteProductReturnValue: Observable<Void> = Observable.empty()
    
    func deleteProduct(dto: DeleteProductDto) -> Observable<Void> {
        deleteProductCalled = true
        return deleteProductReturnValue
    }
}
