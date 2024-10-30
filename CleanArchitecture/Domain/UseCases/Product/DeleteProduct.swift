//
//  DeleteProduct.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/26/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import ValidatedPropertyKit
import RxSwift
import Dto

struct DeleteProductDto: Dto {
    @Validated(Validation.greater(0))
    var id: Int = 0
    
    var validatedProperties: [ValidatedProperty] {
        return [_id]
    }
}

protocol DeleteProduct {
    var productGateway: ProductGatewayProtocol { get }
}

extension DeleteProduct {
    func deleteProduct(dto: DeleteProductDto) -> Observable<Void> {
        if let error = dto.validationError {
            return Observable.error(error)
        }
        
        return productGateway.deleteProduct(dto: dto)
    }
}
