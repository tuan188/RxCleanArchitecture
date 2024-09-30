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
    
    @Validated(.minLength(min: 5, message: "Product name must be at least 5 characters."))
    var name: String? = ""
    
    @Validated(.greater(0, message: "Product price must be greater than 0."))
    var price: Double? = 0.0
    
    @Validated(.isNumber(message: "Please enter a number"))
    var priceString: String? = ""
    
    var validatedProperties: [ValidatedProperty] {
        return [_name, _price]
    }
}

extension ProductDto: Then { }

extension ProductDto {
    init(id: Int, name: String, price: Double) {
        self.id = id
        self.name = name
        self.price = price
    }
    
    static func validateName(_ name: String) -> Result<String, ValidationError> {
        return ProductDto()._name.isValid(value: name)
    }
    
    static func validatePrice(_ price: Double) -> Result<Double, ValidationError> {
        return ProductDto()._price.isValid(value: price)
    }
    
    static func validatePriceString(_ priceString: String) -> Result<String, ValidationError> {
        return ProductDto()._priceString.isValid(value: priceString)
    }
}

extension Product {
    func toDto() -> ProductDto {
        return ProductDto(id: self.id, name: self.name, price: self.price)
    }
}
