//
//  UpdateProduct.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/29/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift

protocol UpdateProduct {
    var productGateway: ProductGatewayProtocol { get }
}

extension UpdateProduct {
    func updateProduct(_ product: ProductDto) -> Observable<Void> {
        return productGateway.update(product)
    }
}
