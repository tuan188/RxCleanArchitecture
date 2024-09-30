//
//  EditProductUseCaseMock.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/24/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import RxSwift

final class EditProductUseCaseMock: EditProductUseCaseType {
    
    // MARK: - validateName
    
    var validateNameCalled = false
    var validateNameReturnValue = ValidationResult.success(())
    
    func validateName(_ name: String) -> ValidationResult {
        validateNameCalled = true
        return validateNameReturnValue
    }
    
    // MARK: - validatePrice
    
    var validatePriceCalled = false
    var validatePriceReturnValue = ValidationResult.success(())
    
    func validatePrice(_ price: String) -> ValidationResult {
        validatePriceCalled = true
        return validatePriceReturnValue
    }
    
    // MARK: - update
    
    var updateCalled = false
    var updateReturnValue = Observable.just(())
    
    func update(_ product: ProductDto) -> Observable<Void> {
        updateCalled = true
        return updateReturnValue
    }
}
