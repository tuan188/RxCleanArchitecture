//
//  AppGateway.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/25/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import Factory

protocol AppGatewayProtocol {
    func checkFirstRun() -> Bool
    func setFirstRun()
}

struct AppGateway: AppGatewayProtocol {
    func checkFirstRun() -> Bool {
        return !AppSettings.didInit
    }
    
    func setFirstRun() {
        AppSettings.didInit = true
    }
}

extension Container {
    var appGateway: Factory<AppGatewayProtocol> {
        Factory(self) { AppGateway() }
    }
}
