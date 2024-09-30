//
//  LoginUseCaseMock.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 1/16/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import RxSwift
import ValidatedPropertyKit

final class LoginUseCaseMock: LoginUseCaseType {
    
    // MARK: - validateUserName
    
    var validateUserNameCalled = false
    var validateUserNameReturnValue = ValidationResult.success(())
    
    func validateUserName(_ username: String) -> ValidationResult {
        validateUserNameCalled = true
        return validateUserNameReturnValue
    }
    
    // MARK: - validatePassword
    
    var validatePasswordCalled = false
    var validatePasswordReturnValue = ValidationResult.success(())
    
    func validatePassword(_ password: String) -> ValidationResult {
        validatePasswordCalled = true
        return validatePasswordReturnValue
    }
    
    // MARK: - login
    
    var loginCalled = false
    var loginReturnValue = Observable.just(())
    
    func login(dto: LoginDto) -> Observable<Void> {
        loginCalled = true
        return loginReturnValue
    }
}
