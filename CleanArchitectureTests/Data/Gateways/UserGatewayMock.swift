//
//  UserGatewayMock.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 6/26/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import UIKit
import RxSwift

final class UserGatewayMock: UserGatewayProtocol {

    // MARK: - fetchUsers

    var getUsersCalled = false
    var getUsersReturnValue = Observable<[User]>.empty()

    func fetchUsers() -> Observable<[User]> {
        getUsersCalled = true
        return getUsersReturnValue
    }

    // MARK: - add

    var addCalled = false
    var addReturnValue = Observable.just(())

    func add(dto: AddUserDto) -> Observable<Void> {
        addCalled = true
        return addReturnValue
    }
}
