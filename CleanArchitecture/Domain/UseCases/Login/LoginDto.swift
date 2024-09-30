//
//  LoginDto.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/25/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import ValidatedPropertyKit

struct LoginDto: Dto {
    @Validated(.nonEmpty(message: "Please enter user name"))
    var username: String? = ""
    
    @Validated(.nonEmpty(message: "Please enter password"))
    var password: String? = ""
    
    var validatedProperties: [ValidatedProperty] {
        return [_username, _password]
    }
}

extension LoginDto {
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    static func validateUserName(_ username: String) -> Result<String, ValidationError> {
        LoginDto()._username.isValid(value: username)
    }
    
    static func validatePassword(_ password: String) -> Result<String, ValidationError> {
        LoginDto()._password.isValid(value: password)
    }
}
