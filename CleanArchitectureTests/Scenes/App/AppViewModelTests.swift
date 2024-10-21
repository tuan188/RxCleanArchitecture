//
//  AppViewModelTests.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/4/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import RxSwift
import RxTest

final class AppViewModelTests: XCTestCase {
    
    private var viewModel: TestAppViewModel!
    private var input: AppViewModel.Input!
    private var output: AppViewModel.Output!
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    
    // Outputs
    private var toMainOutput: TestableObserver<Void>!
    
    // Triggers
    private let loadTrigger = PublishSubject<Void>()
    
    override func setUp() {
        super.setUp()
        viewModel = TestAppViewModel(window: UIWindow())
        
        input = AppViewModel.Input(
            load: loadTrigger.asDriverOnErrorJustComplete()
        )
        
        disposeBag = DisposeBag()
        output = viewModel.transform(input, disposeBag: disposeBag)
        
        scheduler = TestScheduler(initialClock: 0)
        toMainOutput = scheduler.createObserver(Void.self)
    }
    
    func test_loadTrigger_addUserData() {
        // act
        loadTrigger.onNext(())
        
        // assert
        XCTAssert(viewModel.addUserDataCalled)
        XCTAssert(viewModel.showMainCalled)
    }
}

class TestAppViewModel: AppViewModel {
    var addUserDataCalled: Bool = false
    var addUserDataResult: Observable<Void> = .just(())
    
    override func vm_addUserData() -> Observable<Void> {
        addUserDataCalled = true
        return addUserDataResult.asObservable()
    }
    
    var showMainCalled: Bool = false
    
    override func vm_showMain() {
        showMainCalled = true
    }
}
