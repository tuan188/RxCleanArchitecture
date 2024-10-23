//
//  LoginDto.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/25/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import Dto
import ValidatedPropertyKit

struct LoginDto: Dto {
    @Validated(!.isEmpty, errorMessage: "Username is required")
    var username: String = ""
    
    @Validated(!.isEmpty, errorMessage: "Password is required")
    var password: String = ""
    
    var validatedProperties: [ValidatedProperty] {
        return [_username, _password]
    }
}

extension LoginDto {
    static func validateUserName(_ username: String) -> ValidationResult {
        LoginDto(username: username)._username.result
    }
    
    static func validatePassword(_ password: String) -> ValidationResult {
        LoginDto(password: password)._password.result
    }
}
