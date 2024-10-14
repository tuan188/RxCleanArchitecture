//
//  ProductGateway.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/26/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift
import Then
import Factory

protocol ProductGatewayProtocol {
    func getProductList(dto: GetPageDto) -> Observable<PagingInfo<Product>>
    func deleteProduct(dto: DeleteProductDto) -> Observable<Void>
    func update(_ product: ProductDto) -> Observable<Void>
}

struct ProductGateway: ProductGatewayProtocol {
    func getProductList(dto: GetPageDto) -> Observable<PagingInfo<Product>> {
        let page = dto.page
        
        return Observable.create { observer in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                let products = Array(0...9)
                    .map { $0 + (page - 1) * 10 }
                    .map { id in
                        Product().with {
                            $0.id = id
                            $0.name = "Product \(id)"
                            $0.price = Double(id * 2)
                        }
                    }
                let page = PagingInfo<Product>(page: page, items: products)
                observer.onNext(page)
                observer.onCompleted()
            })
            
            return Disposables.create()
        }
    }
    
    func deleteProduct(dto: DeleteProductDto) -> Observable<Void> {
        return Observable.just(())
    }
    
    func update(_ product: ProductDto) -> Observable<Void> {
        return Observable.just(())
    }
}

struct LocalAPIProductGateway: ProductGatewayProtocol {

    func getProductList(dto: GetPageDto) -> Observable<PagingInfo<Product>> {
//        return API.shared.getProductList(API.GetProductListInput())
//            .map { PagingInfo(page: 1, items: $0) }
        return Observable.empty()
    }
    
    func deleteProduct(dto: DeleteProductDto) -> Observable<Void> {
        return Observable.just(())
    }
    
    func update(_ product: ProductDto) -> Observable<Void> {
        return Observable.just(())
    }
}

extension Container {
    var productGateway: Factory<ProductGatewayProtocol> {
        Factory(self) {
            ProductGateway()
        }
    }
}
