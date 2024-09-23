//
//  SettingUpUserDataTests.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 6/26/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import RxTest
import RxSwift

final class SettingUpUserDataTests: XCTestCase, SettingUpUserData {
    var appGateway: AppGatewayProtocol {
        return appGatewayMock
    }
    
    var userGateway: UserGatewayProtocol {
        return userGatewayMock
    }
    
    private var appGatewayMock: AppGatewayMock!
    private var userGatewayMock: UserGatewayMock!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    // Output Observers
    private var addUserDataOutput: TestableObserver<Void>!

    override func setUp() {
        super.setUp()
        appGatewayMock = AppGatewayMock()
        userGatewayMock = UserGatewayMock()
        
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        
        addUserDataOutput = scheduler.createObserver(Void.self)
    }
    
    func test_addUserData_firstRun() {
        // arrange
        appGatewayMock.checkFirstRunReturnValue = true

        // act
        self.addUserData().subscribe(addUserDataOutput).disposed(by: disposeBag)

        // assert
        XCTAssert(appGatewayMock.checkFirstRunCalled)
        XCTAssert(userGatewayMock.addCalled)
        XCTAssert(appGatewayMock.setFirstRunCalled)
    }
    
    func test_addUserData_not_firstRun() {
        // arrange
        appGatewayMock.checkFirstRunReturnValue = false

        // act
        self.addUserData().subscribe(addUserDataOutput).disposed(by: disposeBag)

        // assert
        XCTAssert(appGatewayMock.checkFirstRunCalled)
        XCTAssertFalse(userGatewayMock.addCalled)
        XCTAssertFalse(appGatewayMock.setFirstRunCalled)
    }
}
