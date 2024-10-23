//
//  LoginViewModelTests.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 1/16/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import RxSwift
import RxTest
import ValidatedPropertyKit
import Dto

final class LoginViewModelTests: XCTestCase {
    private var viewModel: TestLoginViewModel!
    private var input: LoginViewModel.Input!
    private var output: LoginViewModel.Output!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    // Outputs
    private var usernameValidationMessageOutput: TestableObserver<String>!
    private var passwordValidationMessageOutput: TestableObserver<String>!
    private var loginOutput: TestableObserver<Void>!
    private var isLoginEnabledOutput: TestableObserver<Bool>!
    private var isLoadingOutput: TestableObserver<Bool>!
    private var errorOutput: TestableObserver<Error>!
    
    // Triggers
    private let usernameTrigger = PublishSubject<String>()
    private let passwordTrigger = PublishSubject<String>()
    private let loginTrigger = PublishSubject<Void>()
    
    override func setUp() {
        super.setUp()
        viewModel = TestLoginViewModel(navigationController: UINavigationController())
        
        input = LoginViewModel.Input(
            username: usernameTrigger.asDriverOnErrorJustComplete(),
            password: passwordTrigger.asDriverOnErrorJustComplete(),
            login: loginTrigger.asDriverOnErrorJustComplete()
        )
        
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        
        output = viewModel.transform(input, disposeBag: disposeBag)
        
        usernameValidationMessageOutput = scheduler.createObserver(String.self)
        passwordValidationMessageOutput = scheduler.createObserver(String.self)
        loginOutput = scheduler.createObserver(Void.self)
        isLoginEnabledOutput = scheduler.createObserver(Bool.self)
        isLoadingOutput = scheduler.createObserver(Bool.self)
        errorOutput = scheduler.createObserver(Error.self)
        
        output.$usernameValidationMessage.subscribe(usernameValidationMessageOutput).disposed(by: disposeBag)
        output.$passwordValidationMessage.subscribe(passwordValidationMessageOutput).disposed(by: disposeBag)
        output.$isLoginEnabled.subscribe(isLoginEnabledOutput).disposed(by: disposeBag)
        output.$isLoading.subscribe(isLoadingOutput).disposed(by: disposeBag)
        output.$error.unwrap().subscribe(errorOutput).disposed(by: disposeBag)
    }
    
    private func startTriggers() {
        scheduler.createColdObservable([.next(0, "foo")])
            .bind(to: usernameTrigger)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(0, "bar")])
            .bind(to: passwordTrigger)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: loginTrigger)
            .disposed(by: disposeBag)
        scheduler.start()
    }
    
    func test_loginTrigger_validateUsername() {
        // act
        startTriggers()
        
        // assert
        XCTAssert(viewModel.validateUserNameCalled)
    }
    
    func test_loginTrigger_validatePassword() {
        // act
        startTriggers()
        
        // assert
        XCTAssert(viewModel.validatePasswordCalled)
    }
    
    func test_loginTrigger_validateUsernameFailed_disableLogin() {
        // arrange
        viewModel.validatePasswordResult = .failure(ValidationError(description: "invalid username"))
        
        // act
        startTriggers()
        
        // assert
        XCTAssertEqual(isLoginEnabledOutput.events, [.next(0, true), .next(10, false)])
        XCTAssertEqual(isLoginEnabledOutput.events.last, .next(10, false))
        XCTAssertFalse(viewModel.loginCalled)
    }
    
    func test_loginTrigger_validatePasswordFailed_disableLogin() {
        // arrange
        viewModel.validatePasswordResult = .failure(ValidationError(description: "invalid password"))
        
        // act
        startTriggers()
        
        // assert
        XCTAssertEqual(isLoginEnabledOutput.events.last, .next(10, false))
        XCTAssertFalse(viewModel.loginCalled)
    }
    
    func test_loginTrigger_login() {
        // act
        startTriggers()
        
        // assert
        XCTAssert(viewModel.loginCalled)
        XCTAssert(viewModel.showLoginSuccessMessageCalled)
    }
    
    func test_loginTrigger_login_showLoading() {
        // arrange
        viewModel.loginRessult = .never()
        
        // act
        startTriggers()
        
        // assert
        XCTAssert(viewModel.loginCalled)
        XCTAssertEqual(isLoadingOutput.events, [.next(0, false), .next(10, true)])
        XCTAssertEqual(isLoginEnabledOutput.events.last, .next(10, false))
    }
    
    func test_loginTrigger_login_failedShowError() {
        // arrange
        viewModel.loginRessult = .error(TestError())
        
        // act
        startTriggers()
        
        // assert
        XCTAssert(viewModel.loginCalled)
        XCTAssert(errorOutput.events.last?.value.element is TestError)
        XCTAssertFalse(viewModel.showLoginSuccessMessageCalled)
    }
    
}

class TestLoginViewModel: LoginViewModel {
    var loginCalled: Bool = false
    var loginRessult: Observable<Void> = .just(())
    
    override func vm_login(dto: LoginDto) -> Observable<Void> {
        loginCalled = true
        return loginRessult.asObservable()
    }
    
    var showLoginSuccessMessageCalled: Bool = false
    
    override func showLoginSuccessMessage() {
        showLoginSuccessMessageCalled = true
    }
    
    var validateUserNameCalled: Bool = false
    var validateUserNameResult: ValidationResult = .success(())
    
    override func vm_validateUserName(_ username: String) -> ValidationResult {
        validateUserNameCalled = true
        return validateUserNameResult
    }
    
    var validatePasswordCalled: Bool = false
    var validatePasswordResult: ValidationResult = .success(())
    
    override func vm_validatePassword(_ password: String) -> ValidationResult {
        validatePasswordCalled = true
        return validatePasswordResult
    }
}
