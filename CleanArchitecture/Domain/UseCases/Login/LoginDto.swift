//
//  LoginDto.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/25/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import ValidatedPropertyKit

struct LoginDto: Dto {
    @Validated(!.isEmpty)
    var username: String? = ""
    
    @Validated(!.isEmpty)
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
    
    static func validateUserName(_ username: String) -> ValidationResult {
        LoginDto(username: username)._username.result
    }
    
    static func validatePassword(_ password: String) -> ValidationResult {
        LoginDto(password: password)._password.result
    }
}
