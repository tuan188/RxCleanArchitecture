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
import MGArchitecture
import Then
import UIKit
import Factory

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
        return ProductDto.validateName(name).mapToVoid()
    }
    
    func validatePrice(_ price: String) -> ValidationResult {
        return ProductDto.validatePriceString(price).mapToVoid()
    }
    
    func update(_ product: ProductDto) -> Observable<Void> {
        if let error = product.validationError {
            return Observable.error(error)
        }
        
        return updateProduct(product)
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
            .map { $0.0 }
            .map { [unowned self] name in
                validateName(name)
            }
            .do(onNext: { result in
                output.nameValidation = result
            })
        
        let priceValidation = Driver.combineLatest(price, input.update)
            .map { $0.0 }
            .map { [unowned self] price in
                validatePrice(price)
            }
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
            .flatMapLatest { [unowned self] name, price -> Driver<Product> in
                let product = self.product.with {
                    $0.name = name
                    $0.price = Double(price) ?? 0.0
                }
                
                return update(product.toDto())
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
                    .map { _ in product }
            }
            .do(onNext: { [unowned self] product in
                delegate.onNext(EditProductDelegate.updatedProduct(product))
                dismiss()
            })
            .drive()
            .disposed(by: disposeBag)
        
        input.cancel
            .drive(onNext: { [unowned self] in
                dismiss()
            })
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
