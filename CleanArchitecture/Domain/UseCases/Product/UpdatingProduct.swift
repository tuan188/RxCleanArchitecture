//
//  UpdatingProduct.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/29/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift

protocol UpdatingProduct {
    var productGateway: ProductGatewayProtocol { get }
}

extension UpdatingProduct {
    func updateProduct(_ product: ProductDto) -> Observable<Void> {
        return productGateway.update(product)
    }
}
