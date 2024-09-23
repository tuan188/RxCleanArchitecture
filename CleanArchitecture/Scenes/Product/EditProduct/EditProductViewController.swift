//
//  EditProductViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/24/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import UIKit
import Reusable
import Dto
import MGArchitecture
import RxSwift
import RxCocoa
import Factory

final class EditProductViewController: UITableViewController, Bindable {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var updateButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameValidationLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var priceValidationLabel: UILabel!

    // MARK: - Properties

    var viewModel: EditProductViewModel!
    var disposeBag = DisposeBag()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        logDeinit()
    }
    
    // MARK: - Methods

    func bindViewModel() {
        let input = EditProductViewModel.Input(
            load: rx.sentMessage(#selector(viewWillAppear(_:)))
                .take(1)
                .mapToVoid()
                .asDriverOnErrorJustComplete(),
            name: nameTextField.rx.text.orEmpty.asDriver(),
            price: priceTextField.rx.text.orEmpty.asDriver(),
            update: updateButton.rx.tap
                .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
                .asDriverOnErrorJustComplete(),
            cancel: cancelButton.rx.tap
                .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
                .asDriverOnErrorJustComplete()
        )
        
        let output = viewModel.transform(input, disposeBag: disposeBag)
        
        output.$name
            .asDriver()
            .drive(nameTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.$price
            .map { String($0) }
            .asDriverOnErrorJustComplete()
            .drive(priceTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.$nameValidation
            .asDriver()
            .drive(nameValidationBinder)
            .disposed(by: disposeBag)
        
        output.$priceValidation
            .asDriver()
            .drive(priceValidationBinder)
            .disposed(by: disposeBag)
        
        output.$isUpdateEnabled
            .asDriver()
            .drive(updateButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.$error
            .asDriver()
            .unwrap()
            .drive(rx.error)
            .disposed(by: disposeBag)
        
        output.$isLoading
            .asDriver()
            .drive(rx.isLoading)
            .disposed(by: disposeBag)
    }
}

// MARK: - Binders
extension EditProductViewController {
    var nameValidationBinder: Binder<ValidationResult> {
        return Binder(self) { vc, result in
            let viewModel = ValidationResultViewModel(validationResult: result)
            vc.nameTextField.backgroundColor = viewModel.backgroundColor
            vc.nameValidationLabel.text = viewModel.text
        }
    }
    
    var priceValidationBinder: Binder<ValidationResult> {
        return Binder(self) { vc, result in
            let viewModel = ValidationResultViewModel(validationResult: result)
            vc.priceTextField.backgroundColor = viewModel.backgroundColor
            vc.priceValidationLabel.text = viewModel.text
        }
    }
}

// MARK: - StoryboardSceneBased
extension EditProductViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.product
}

extension Container {
    func editProductViewController(product: Product,
                                   delegate: PublishSubject<EditProductDelegate>,
                                   navigationController: UINavigationController)
    -> Factory<EditProductViewController> {
        Factory(self) {
            let vc = EditProductViewController.instantiate()
            let vm = EditProductViewModel(product: product,
                                          delegate: delegate,
                                          navigationController: navigationController)
            vc.bindViewModel(to: vm)
            return vc
        }
    }
}
