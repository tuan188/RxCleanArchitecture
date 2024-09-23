//
//  DeletingProduct.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/26/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import Dto
import ValidatedPropertyKit
import RxSwift

struct DeleteProductDto: Dto {
    @Validated(Validation.greater(0))
    var id: Int?
    
    var validatedProperties: [ValidatedProperty] {
        return [_id]
    }
    
    init(id: Int) {
        self.id = id
    }
}

protocol DeletingProduct {
    var productGateway: ProductGatewayProtocol { get }
}

extension DeletingProduct {
    func deleteProduct(dto: DeleteProductDto) -> Observable<Void> {
        if let error = dto.validationError {
            return Observable.error(error)
        }
        
        return productGateway.deleteProduct(dto: dto)
    }
}
