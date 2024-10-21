//
//  UserListViewModelTests.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 1/14/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import RxSwift

final class UserListViewModelTests: XCTestCase {
    private var viewModel: TestUserListViewModel!
    
    private var input: UserListViewModel.Input!
    private var output: UserListViewModel.Output!

    private var disposeBag: DisposeBag!
    
    private let loadTrigger = PublishSubject<Void>()
    private let reloadTrigger = PublishSubject<Void>()
    private let selectUserTrigger = PublishSubject<IndexPath>()

    override func setUp() {
        super.setUp()
        viewModel = TestUserListViewModel()
        
        input = UserListViewModel.Input(
            load: loadTrigger.asDriverOnErrorJustComplete(),
            reload: reloadTrigger.asDriverOnErrorJustComplete(),
            selectUser: selectUserTrigger.asDriverOnErrorJustComplete()
        )

        disposeBag = DisposeBag()
        output = viewModel.transform(input, disposeBag: disposeBag)
    }

    func test_loadTrigger_getUserList() {
        // act
        loadTrigger.onNext(())
        
        // assert
        XCTAssert(viewModel.getUsersCalled)
        XCTAssertEqual(output.userList.count, 1)
    }

    func test_loadTrigger_getUserList_failedShowError() {
        // arrange
        viewModel.getUsersResult = .error(TestError())

        // act
        loadTrigger.onNext(())

        // assert
        XCTAssert(viewModel.getUsersCalled)
        XCTAssert(output.error is TestError)
    }

    func test_reloadTrigger_getUserList() {
        // act
        reloadTrigger.onNext(())

        // assert
        XCTAssert(viewModel.getUsersCalled)
        XCTAssertEqual(output.userList.count, 1)
    }

    func test_reloadTrigger_getUserList_failedShowError() {
        // arrange
        viewModel.getUsersResult = .error(TestError())

        // act
        reloadTrigger.onNext(())

        // assert
        XCTAssert(viewModel.getUsersCalled)
        XCTAssert(output.error is TestError)
    }

    func test_reloadTrigger_notGetUserListIfStillLoading() {
        // arrange
        viewModel.getUsersResult = Observable.never()

        // act
        loadTrigger.onNext(())
        viewModel.getUsersCalled = false
        reloadTrigger.onNext(())

        // assert
        XCTAssertFalse(viewModel.getUsersCalled)
    }

    func test_reloadTrigger_notGetUserListIfStillReloading() {
        // arrange
        viewModel.getUsersResult = Observable.never()

        // act
        reloadTrigger.onNext(())
        viewModel.getUsersCalled = false
        reloadTrigger.onNext(())

        // assert
        XCTAssertFalse(viewModel.getUsersCalled)
    }

    func test_selectUserTrigger_toUserDetail() {
        // act
        loadTrigger.onNext(())
        selectUserTrigger.onNext(IndexPath(row: 0, section: 0))

        // assert
        XCTAssert(viewModel.showUserDetailCalled)
    }
}

class TestUserListViewModel: UserListViewModel {
    var showUserDetailCalled: Bool = false
    
    override func showUserDetail(user: User) {
        showUserDetailCalled = true
    }
    
    var getUsersCalled: Bool = false
    var getUsersResult: Observable<[User]> = .just([User()])
    
    override func vm_getUsers() -> Observable<[User]> {
        getUsersCalled = true
        return getUsersResult
    }
}
