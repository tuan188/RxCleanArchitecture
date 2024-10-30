//
//  UserGateway.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/24/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift
import Factory
import CoreStore
import CoreDataRepository

protocol UserGatewayProtocol {
    func fetchUsers() -> Observable<[User]>
    func add(dto: AddUserDto) -> Observable<Void>
}

class UserGateway: UserGatewayProtocol, CoreDataRepository {
    typealias Model = User
    typealias Entity = CDUser
    let dataStack: CoreStore.DataStack
    
    init(dataStack: CoreStore.DataStack = CoreStoreDefaults.dataStack) {
        self.dataStack = dataStack
    }

    func fetchUsers() -> Observable<[User]> {
        fetchAll()
    }
    
    func add(dto: AddUserDto) -> Observable<Void> {
        return create(objects: dto.users)
    }
}

extension Container {
    var userGateway: Factory<UserGatewayProtocol> {
        Factory(self) {
            UserGateway()
        }
    }
}
