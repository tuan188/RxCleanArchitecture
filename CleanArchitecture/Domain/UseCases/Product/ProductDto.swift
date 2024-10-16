//
//  ProductDto.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/26/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import ValidatedPropertyKit
import Then

struct ProductDto: Dto {
    var id = 0
    
    @Validated(.range(5...), errorMessage: "Name must be at least 5 characters long.")
    var name: String = ""
    
    @Validated(.greater(0), errorMessage: "Price must be greater than 0.")
    var price: Double = 0.0
    
    var priceString: String? = ""
    
    var validatedProperties: [ValidatedProperty] {
        return [_name, _price]
    }
}

extension ProductDto: Then { }

extension ProductDto {
    static func validateName(_ name: String) -> ValidationResult {
        return ProductDto(name: name)._name.result
    }
    
    static func validatePrice(_ price: Double) -> ValidationResult {
        ProductDto(price: price)._price.result
    }
}

extension Product {
    func toDto() -> ProductDto {
        let dto = ProductDto(id: self.id, name: self.name, price: self.price)
        return dto
    }
}
