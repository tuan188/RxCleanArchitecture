//
//  GettingRepoListTests.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 6/26/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import RxTest
import RxSwift

final class GettingRepoListTests: XCTestCase, GettingRepoList {
    
    var repoGateway: RepoGatewayProtocol {
        return repoGatewayMock
    }
    
    private var repoGatewayMock: RepoGatewayMock!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    // Output Observers
    private var getRepoListOutput: TestableObserver<PagingInfo<Repo>>!

    override func setUp() {
        super.setUp()
        repoGatewayMock = RepoGatewayMock()
        
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        
        getRepoListOutput = scheduler.createObserver(PagingInfo<Repo>.self)
    }

    func test_getRepoList() {
        // act
        self.getRepoList(dto: GetPageDto(page: 1, perPage: 10, usingCache: false))
            .subscribe(getRepoListOutput)
            .disposed(by: disposeBag)

        // assert
        XCTAssert(repoGatewayMock.getRepoListCalled)
    }
    
    func test_getRepoList_error() {
        // arrange
        repoGatewayMock.getRepoListReturnValue = Observable.error(TestError())
        
        // act
        self.getRepoList(dto: GetPageDto(page: 1, perPage: 10, usingCache: false))
            .subscribe(getRepoListOutput)
            .disposed(by: disposeBag)

        // assert
        XCTAssert(repoGatewayMock.getRepoListCalled)
//        XCTAssertEqual(getRepoListOutput.events, [.error(0, TestError())])
    }
}
