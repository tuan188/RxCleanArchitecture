//
//  EditProductViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/24/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import ValidatedPropertyKit
import RxSwift
import RxCocoa
import Then
import UIKit
import Factory
import RxCleanArchitecture
import Dto

enum EditProductDelegate {
    case updatedProduct(Product)
}

class EditProductViewModel: UpdatingProduct, Dismissible {
    @Injected(\.productGateway)
    var productGateway: ProductGatewayProtocol

    let product: Product
    unowned let delegate: PublishSubject<EditProductDelegate> // swiftlint:disable:this weak_delegate
    unowned var navigationController: UINavigationController
    
    init(product: Product, delegate: PublishSubject<EditProductDelegate>, navigationController: UINavigationController) {
        self.product = product
        self.delegate = delegate
        self.navigationController = navigationController
    }
    
    func validateName(_ name: String) -> ValidationResult {
        ProductDto.validateName(name)
    }
    
    func validatePrice(_ price: String) -> ValidationResult {
        ProductDto.validatePrice(Double(price) ?? 0.0)
    }
    
    func update(_ product: ProductDto) -> Observable<Void> {
        if let error = product.validationError {
            return Observable.error(error)
        }
        
        return updateProduct(product)
    }
    
    func vm_dismiss() {
        dismiss()
    }
    
    deinit {
        print("EditProductViewModel deinit")
    }
}

// MARK: - ViewModel
extension EditProductViewModel: ViewModel {
    struct Input {
        let load: Driver<Void>
        let name: Driver<String>
        let price: Driver<String>
        let update: Driver<Void>
        let cancel: Driver<Void>
    }

    struct Output {
        @Property var name = ""
        @Property var price = 0.0
        @Property var nameValidation = ValidationResult.success(())
        @Property var priceValidation = ValidationResult.success(())
        @Property var isUpdateEnabled = true
        @Property var error: Error?
        @Property var isLoading = false
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output(name: product.name, price: product.price)
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        let name = Driver.merge(
            input.name,
            input.load.map { self.product.name }
        )
        
        let price = Driver.merge(
            input.price,
            input.load.map { String(self.product.price) }
        )
        
        let nameValidation = Driver.combineLatest(name, input.update)
            .map(\.0)
            .map(validateName)
            .do(onNext: { result in
                output.nameValidation = result
            })
        
        let priceValidation = Driver.combineLatest(price, input.update)
            .map(\.0)
            .map(validatePrice)
            .do(onNext: { result in
                output.priceValidation = result
            })
        
        let isUpdateEnabled = Driver.and(
            nameValidation.map { $0.isValid },
            priceValidation.map { $0.isValid }
        )
        .startWith(true)
        .do(onNext: { isEnabled in
            output.isUpdateEnabled = isEnabled
        })
        
        input.update
            .withLatestFrom(isUpdateEnabled)
            .filter { $0 }
            .withLatestFrom(Driver.combineLatest(
                name,
                price
            ))
            .flatMapLatest { name, price -> Driver<Product> in
                let product = self.product.with {
                    $0.name = name
                    $0.price = Double(price) ?? 0.0
                }
                
                return self.update(product.toDto())
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
                    .map { _ in product }
            }
            .drive(onNext: { product in
                self.delegate.onNext(EditProductDelegate.updatedProduct(product))
                self.vm_dismiss()
            })
            .disposed(by: disposeBag)
        
        input.cancel
            .drive(onNext: vm_dismiss)
            .disposed(by: disposeBag)
        
        errorTracker
            .asDriver()
            .drive(output.$error)
            .disposed(by: disposeBag)
            
        activityIndicator
            .asDriver()
            .drive(output.$isLoading)
            .disposed(by: disposeBag)
        
        return output
    }
}
