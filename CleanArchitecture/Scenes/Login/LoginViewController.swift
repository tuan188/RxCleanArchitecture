//
//  LoginViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 1/16/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import Factory

final class LoginViewController: UIViewController, Bindable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameValidationLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Properties
    
    var viewModel: LoginViewModel!
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }

    deinit {
        logDeinit()
    }
    
    // MARK: - Methods

    private func configView() {
        usernameValidationLabel.text = ""
        passwordValidationLabel.text = ""
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
    }

    func bindViewModel() {
        let input = LoginViewModel.Input(
            username: usernameTextField.rx.text.orEmpty.asDriver(),
            password: passwordTextField.rx.text.orEmpty.asDriver(),
            login: loginButton.rx.tap.asDriver()
        )
        
        let output = viewModel.transform(input, disposeBag: disposeBag)
        
        output.$usernameValidationMessage
            .asDriver()
            .drive(usernameValidationMessageBinder)
            .disposed(by: disposeBag)
        
        output.$passwordValidationMessage
            .asDriver()
            .drive(passwordValidationMessageBinder)
            .disposed(by: disposeBag)
        
        output.$isLoginEnabled
            .asDriver()
            .drive(loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.$isLoading
            .asDriver()
            .drive(rx.isLoading)
            .disposed(by: disposeBag)
        
        output.$error
            .asDriver()
            .unwrap()
            .drive(rx.error)
            .disposed(by: disposeBag)
    }
}

// MARK: - Binders
extension LoginViewController {
    var usernameValidationMessageBinder: Binder<String> {
        return Binder(self) { vc, message in
            vc.usernameValidationLabel.text = message
        }
    }
    
    var passwordValidationMessageBinder: Binder<String> {
        return Binder(self) { vc, message in
            vc.passwordValidationLabel.text = message
        }
    }
}

// MARK: - StoryboardSceneBased
extension LoginViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}

extension Container {
    func loginViewController(navigationController: UINavigationController) -> Factory<LoginViewController> {
        Factory(self) {
            let vc = LoginViewController.instantiate()
            let vm = LoginViewModel(navigationController: navigationController)
            vc.bindViewModel(to: vm)
            return vc
        }
    }
}
