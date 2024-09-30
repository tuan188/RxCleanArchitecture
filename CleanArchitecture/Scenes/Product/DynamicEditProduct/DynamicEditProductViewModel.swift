//
//  DynamicEditProductViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 9/10/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa
import Factory
import UIKit

class DynamicEditProductViewModel: UpdatingProduct, Dismissible {
    @Injected(\.productGateway)
    var productGateway: ProductGatewayProtocol

    unowned var navigationController: UINavigationController
    let product: Product

    init(navigationController: UINavigationController, product: Product) {
        self.product = product
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
    
    func notifyUpdated(_ product: Product) {
        NotificationCenter.default.post(name: Notification.Name.updatedProduct, object: product)
    }
}

// MARK: - ViewModel
extension DynamicEditProductViewModel: ViewModel {
    struct Input {
        let load: Driver<TriggerType>
        let update: Driver<Void>
        let cancel: Driver<Void>
        let data: Driver<DataType>
    }

    struct Output {
        @Property var nameValidation = ValidationResult.success(())
        @Property var priceValidation = ValidationResult.success(())
        @Property var isUpdateEnabled = true
        @Property var error: Error?
        @Property var isLoading = false
        @Property var cellCollection = CellCollection()
    }
    
    enum DataType {
        case name(String)
        case price(String)
    }
    
    struct Cell {
        let dataType: DataType
        let validationResult: ValidationResult
    }
    
    struct CellCollection {
        var cells: [Cell] = []
        var needsReloading = false
    }
    
    enum TriggerType {
        case load
        case endEditing
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        let name = input.data
            .map { data -> String? in
                if case let DataType.name(name) = data {
                    return name
                }
                return nil
            }
            .unwrap()
            .startWith(self.product.name)
        
        let price = input.data
            .map { data -> String? in
                if case let DataType.price(price) = data {
                    return price
                }
                return nil
            }
            .unwrap()
            .startWith(String(self.product.price))
        
        let nameValidation = Driver.combineLatest(name, input.update)
            .map { $0.0 }
            .map { [unowned self] name in validateName(name) }
            .do(onNext: { result in
                return output.nameValidation = result
            })
        
        let priceValidation = Driver.combineLatest(price, input.update)
            .map { $0.0 }
            .map { [unowned self] price in validatePrice(price) }
            .do(onNext: { result in
                output.priceValidation = result
            })
        
        let isUpdateEnabled = Driver.combineLatest([
            nameValidation,
            priceValidation
        ])
        .map {
            $0.allSatisfy { $0.isValid }
        }
        .startWith(true)
        .do(onNext: { isEnabled in
            output.isUpdateEnabled = isEnabled
        })
        
        let product = Driver.combineLatest(name, price)
            .map { name, price in
                Product(
                    id: self.product.id,
                    name: name,
                    price: Double(price) ?? 0.0
                )
            }
        
        input.load
            .withLatestFrom(product)
            .map { product -> [Cell] in
                return [
                    Cell(dataType: .name(product.name), validationResult: output.nameValidation),
                    Cell(dataType: .price(String(product.price)), validationResult: output.priceValidation)
                ]
            }
            .withLatestFrom(input.load) {
                CellCollection(cells: $0, needsReloading: $1 == .load)
            }
            .drive(output.$cellCollection)
            .disposed(by: disposeBag)
        
        input.cancel
            .drive(onNext: { [unowned self] in dismiss() })
            .disposed(by: disposeBag)
        
        input.update
            .withLatestFrom(isUpdateEnabled)
            .filter { $0 }
            .withLatestFrom(product)
            .flatMapLatest { [unowned self] product in
                update(product.toDto())
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
                    .map { _ in product }
            }
            .drive(onNext: { [unowned self] product in
                notifyUpdated(product)
                dismiss()
            })
            .disposed(by: disposeBag)
        
        errorTracker.asDriver()
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
