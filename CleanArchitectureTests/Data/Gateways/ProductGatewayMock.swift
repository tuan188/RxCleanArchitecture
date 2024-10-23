//
//  ProductGatewayMock.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 6/29/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import UIKit
import RxSwift
import RxCleanArchitecture

final class ProductGatewayMock: ProductGatewayProtocol {

    // MARK: - getProductList

    var getProductListCalled = false
    var getProductListReturnValue = Observable<PagingInfo<Product>>.just(
        PagingInfo(page: 1, items: [Product()])
    )

    func getProductList(dto: GetPageDto) -> Observable<PagingInfo<Product>> {
        getProductListCalled = true
        return getProductListReturnValue
    }

    // MARK: - deleteProduct

    var deleteProductCalled = false
    var deleteProductReturnValue = Observable.just(())

    func deleteProduct(dto: DeleteProductDto) -> Observable<Void> {
        deleteProductCalled = true
        return deleteProductReturnValue
    }

    // MARK: - update

    var updateCalled = false
    var updateReturnValue = Observable.just(())

    func update(_ product: ProductDto) -> Observable<Void> {
        updateCalled = true
        return updateReturnValue
    }
}
