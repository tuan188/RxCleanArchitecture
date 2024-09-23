//
//  AppGatewayMock.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 6/26/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import UIKit

final class AppGatewayMock: AppGatewayProtocol {

    // MARK: - checkFirstRun

    var checkFirstRunCalled = false
    var checkFirstRunReturnValue = false

    func checkFirstRun() -> Bool {
        checkFirstRunCalled = true
        return checkFirstRunReturnValue
    }

    // MARK: - setFirstRun

    var setFirstRunCalled = false

    func setFirstRun() {
        setFirstRunCalled = true
    }
}
