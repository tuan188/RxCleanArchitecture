//
//  LoginViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 1/16/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import ValidatedPropertyKit
import RxSwift
import RxCocoa
import Factory
import UIKit
import RxCleanArchitecture

class LoginViewModel: ShowAutoCloseMessage, LoggingIn {
    unowned var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showLoginSuccessMessage() {
        showAutoCloseMessage("Login success")
    }
    
    func vm_login(dto: LoginDto) -> Observable<Void> {
        login(dto: dto)
    }
    
    func vm_validateUserName(_ username: String) -> ValidationResult {
        validateUserName(username)
    }
    
    func vm_validatePassword(_ password: String) -> ValidationResult {
        validatePassword(password)
    }
}

// MARK: - ViewModel
extension LoginViewModel: ViewModel {
    struct Input {
        let username: Driver<String>
        let password: Driver<String>
        let login: Driver<Void>
    }

    struct Output {
        @Property var usernameValidationMessage = ""
        @Property var passwordValidationMessage = ""
        @Property var isLoginEnabled = true
        @Property var isLoading = false
        @Property var error: Error?
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        errorTracker
            .drive(output.$error)
            .disposed(by: disposeBag)
        
        let isLoading = activityIndicator.asDriver()
        
        isLoading
            .drive(output.$isLoading)
            .disposed(by: disposeBag)
        
        let usernameValidation = Driver.combineLatest(input.username, input.login)
            .map { $0.0 }
            .map(vm_validateUserName)
        
        usernameValidation
            .map(\.message)
            .drive(output.$usernameValidationMessage)
            .disposed(by: disposeBag)
  
        let passwordValidation = Driver.combineLatest(input.password, input.login)
            .map { $0.0 }
            .map(vm_validatePassword)
        
        passwordValidation
            .map(\.message)
            .drive(output.$passwordValidationMessage)
            .disposed(by: disposeBag)
        
        let validation = Driver.and(
            usernameValidation.map { $0.isValid },
            passwordValidation.map { $0.isValid }
        )
        .startWith(true)
        
        let isLoginEnabled = Driver.merge(validation, isLoading.not())
        
        isLoginEnabled
            .drive(output.$isLoginEnabled)
            .disposed(by: disposeBag)
        
        input.login
            .withLatestFrom(isLoginEnabled)
            .filter { $0 }
            .withLatestFrom(Driver.combineLatest(input.username, input.password))
            .flatMapLatest { username, password -> Driver<Void> in
                self.vm_login(dto: LoginDto(username: username, password: password))
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
            .drive(onNext: showLoginSuccessMessage)
            .disposed(by: disposeBag)
        
        return output
    }
}
