//
//  FetchProductList.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/26/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift
import RxCleanArchitecture

protocol FetchProductList {
    var productGateway: ProductGatewayProtocol { get }
}

extension FetchProductList {
    func fetchProducts(dto: FetchPageDto) -> Observable<PagingInfo<Product>> {
        return productGateway.fetchProducts(dto: dto)
    }
}
