//
//  FetchUsers.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/24/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import RxSwift

protocol FetchUsers {
    var userGatewayType: UserGatewayProtocol { get }
}

extension FetchUsers {
    func fetchUsers() -> Observable<[User]> {
        return userGatewayType.fetchUsers()
    }
}
