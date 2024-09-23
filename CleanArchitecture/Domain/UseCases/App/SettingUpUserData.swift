//
//  SettingUpUserData.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/26/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol SettingUpUserData {
    var appGateway: AppGatewayProtocol { get }
    var userGateway: UserGatewayProtocol { get }
}

extension SettingUpUserData {
    func addUserData() -> Observable<Void> {
        return Observable.just(())
            .map { _ in
                self.appGateway.checkFirstRun()
            }
            .flatMapLatest { firstRun -> Driver<Bool> in
                if firstRun {
                    return self.addUsers()
                        .asDriverOnErrorJustComplete()
                        .map { _ in firstRun }
                }
                return Driver.just(firstRun)
            }
            .do(onNext: { firstRun in
                if firstRun {
                    self.appGateway.setFirstRun()
                }
            })
            .mapToVoid()
    }
    
    private func addUsers() -> Observable<Void> {
        let users = [
            User(id: UUID().uuidString,
                 name: "John Appleseed",
                 gender: .male,
                 birthday: Date.date(day: 22, month: 6, year: 1_980) ?? Date()),
            User(id: UUID().uuidString,
                 name: "Kate Bell",
                 gender: .female,
                 birthday: Date.date(day: 20, month: 1, year: 1_978) ?? Date()),
            User(id: UUID().uuidString,
                 name: "Anna Haro",
                 gender: .female,
                 birthday: Date.date(day: 29, month: 8, year: 1_985) ?? Date())
        ]
        
        return userGateway.add(dto: AddUserDto(users: users))
    }
}
