//
//  AddingUsers.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/25/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import RxSwift
import Dto
import ValidatedPropertyKit

struct AddUserDto: Dto {
    @Validated(!.isEmpty)
    var users: [User] = []
    
    var validatedProperties: [ValidatedProperty] {
        [_users]
    }
}

protocol AddingUsers {
    var userGatewayType: UserGatewayProtocol { get }
}

extension AddingUsers {
    func add(dto: AddUserDto) -> Observable<Void> {
        if let error = dto.validationError {
            return Observable.error(error)
        }
        
        return userGatewayType.add(dto: dto)
    }
}
