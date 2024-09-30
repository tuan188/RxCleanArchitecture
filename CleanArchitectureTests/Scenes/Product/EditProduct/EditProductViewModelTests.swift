//
//  EditProductViewModelTests.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/24/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import RxSwift
import RxTest
import ValidatedPropertyKit

final class EditProductViewModelTests: XCTestCase {
    
    private var viewModel: EditProductViewModel!
    private var navigator: EditProductNavigatorMock!
    private var useCase: EditProductUseCaseMock!
    private var input: EditProductViewModel.Input!
    private var output: EditProductViewModel.Output!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!

    // Outputs
    private var nameOutput: TestableObserver<String>!
    private var priceOutput: TestableObserver<Double>!
    private var nameValidationOutput: TestableObserver<ValidationResult>!
    private var priceValidationOutput: TestableObserver<ValidationResult>!
    private var isUpdateEnabledOutput: TestableObserver<Bool>!
    private var updatedProductOutput: TestableObserver<Void>!
    private var cancelOutput: TestableObserver<Void>!
    private var errorOutput: TestableObserver<Error>!
    private var isLoadingOutput: TestableObserver<Bool>!
    
    // Triggers
    private let nameTrigger = PublishSubject<String>()
    private let priceTrigger = PublishSubject<String>()
    private let loadTrigger = PublishSubject<Void>()
    private let updateTrigger = PublishSubject<Void>()
    private let cancelTrigger = PublishSubject<Void>()
    
    private let delegate = PublishSubject<EditProductDelegate>() // swiftlint:disable:this weak_delegate
    private var product: Product!
    
    override func setUp() {
        super.setUp()
        navigator = EditProductNavigatorMock()
        useCase = EditProductUseCaseMock()
        product = Product(id: 1, name: "foobar", price: 10)
        viewModel = EditProductViewModel(navigator: navigator, useCase: useCase, product: product, delegate: delegate)
        
        input = EditProductViewModel.Input(
            load: loadTrigger.asDriverOnErrorJustComplete(),
            name: nameTrigger.asDriverOnErrorJustComplete(),
            price: priceTrigger.asDriverOnErrorJustComplete(),
            update: updateTrigger.asDriverOnErrorJustComplete(),
            cancel: cancelTrigger.asDriverOnErrorJustComplete()
        )
        
        disposeBag = DisposeBag()
        output = viewModel.transform(input, disposeBag: disposeBag)
        
        scheduler = TestScheduler(initialClock: 0)
        
        nameOutput = scheduler.createObserver(String.self)
        priceOutput = scheduler.createObserver(Double.self)
        nameValidationOutput = scheduler.createObserver(ValidationResult.self)
        priceValidationOutput = scheduler.createObserver(ValidationResult.self)
        isUpdateEnabledOutput = scheduler.createObserver(Bool.self)
        updatedProductOutput = scheduler.createObserver(Void.self)
        cancelOutput = scheduler.createObserver(Void.self)
        errorOutput = scheduler.createObserver(Error.self)
        isLoadingOutput = scheduler.createObserver(Bool.self)
        
        output.$name.asDriver().drive(nameOutput).disposed(by: disposeBag)
        output.$price.asDriver().drive(priceOutput).disposed(by: disposeBag)
        output.$nameValidation.asDriver().drive(nameValidationOutput).disposed(by: disposeBag)
        output.$priceValidation.asDriver().drive(priceValidationOutput).disposed(by: disposeBag)
        output.$isUpdateEnabled.asDriver().drive(isUpdateEnabledOutput).disposed(by: disposeBag)
        output.$error.asDriver().unwrap().drive(errorOutput).disposed(by: disposeBag)
        output.$isLoading.asDriver().drive(isLoadingOutput).disposed(by: disposeBag)
    }
    
    private func startTriggers(load: Recorded<Event<Void>>? = nil,
                               name: Recorded<Event<String>>? = nil,
                               price: Recorded<Event<String>>? = nil,
                               update: Recorded<Event<Void>>? = nil,
                               cancel: Recorded<Event<Void>>? = nil) {
        if let load = load {
            scheduler.createColdObservable([load]).bind(to: loadTrigger).disposed(by: disposeBag)
        }
        
        if let name = name {
            scheduler.createColdObservable([name]).bind(to: nameTrigger).disposed(by: disposeBag)
        }
        
        if let price = price {
            scheduler.createColdObservable([price]).bind(to: priceTrigger).disposed(by: disposeBag)
        }
        
        if let update = update {
            scheduler.createColdObservable([update]).bind(to: updateTrigger).disposed(by: disposeBag)
        }
        
        if let cancel = cancel {
            scheduler.createColdObservable([cancel]).bind(to: cancelTrigger).disposed(by: disposeBag)
        }
        
        scheduler.start()
    }
    
    func test_loadTriggerInvoked_showProduct() {
        // act
        startTriggers(load: .next(0, ()))
        
        // assert
        XCTAssertEqual(nameOutput.lastEventElement, product.name)
        XCTAssertEqual(priceOutput.lastEventElement, product.price)
    }
    
    func test_loadTriggerInvoked_enableUpdateByDefault() {
        // act
        startTriggers(load: .next(0, ()))
        
        // assert
        XCTAssertEqual(isUpdateEnabledOutput.lastEventElement, true)
    }
    
    func test_nameTriggerInvoked_validateName() {
        // act
        startTriggers(name: .next(0, "Foo"), update: .next(10, ()))
        
        // assert
        XCTAssert(useCase.validateNameCalled)
    }
    
    func test_nameTriggerInvoked_validateNameFailNotEnableUpdate() {
        // arrange
        useCase.validateNameReturnValue = ValidationResult.failure(ValidationError(message: ""))
        
        // act
        startTriggers(
            name: .next(0, "Foo"),
            price: .next(0, "10"),
            update: .next(0, ())
        )
        
        // assert
        XCTAssertFalse(output.nameValidation.isValid)
        XCTAssert(output.priceValidation.isValid)
        XCTAssertEqual(isUpdateEnabledOutput.lastEventElement, false)
    }
    
    func test_priceTriggerInvoked_validatePrice() {
        // act
        startTriggers(
            price: .next(0, "10"),
            update: .next(10, ())
        )
        
        // assert
        XCTAssert(useCase.validatePriceCalled)
    }
    
    func test_priceTriggerInvoked_validatePriceFailNotEnableUpdate() {
        // arrange
        useCase.validatePriceReturnValue = ValidationResult.failure(ValidationError(message: ""))
        
        // act
        startTriggers(
            name: .next(0, "Foo"),
            price: .next(0, "10"),
            update: .next(10, ())
        )
        
        // assert
        XCTAssertEqual(isUpdateEnabledOutput.lastEventElement, false)
    }
    
    func test_enableUpdate() {
        // act
        startTriggers(
            name: .next(0, "Foo"),
            price: .next(0, "10"),
            update: .next(10, ())
        )
        
        // assert
        XCTAssertEqual(isUpdateEnabledOutput.lastEventElement, true)
    }
    
    func test_updateTriggerInvoked_notUpdateProduct() {
        // arrange
        useCase.validateNameReturnValue = ValidationResult.failure(ValidationError(message: ""))
        
        // act
        startTriggers(
            name: .next(0, "Foo"),
            price: .next(0, "10"),
            update: .next(10, ())
        )
        
        // assert
        XCTAssertFalse(useCase.updateCalled)
    }
    
    func test_updateTriggerInvoked_updateProduct() {
        // act
        startTriggers(
            name: .next(0, "Foo"),
            price: .next(0, "10"),
            update: .next(10, ())
        )
        
        // assert
        XCTAssert(useCase.updateCalled)
        XCTAssert(navigator.dismissCalled)
    }
    
    func test_updateTriggerInvoked_updateProductFailShowError() {
        // arrange
        useCase.updateReturnValue = Observable.error(TestError())
        
        // act
        startTriggers(
            name: .next(0, "Foo"),
            price: .next(0, "10"),
            update: .next(10, ())
        )
        
        // assert
        XCTAssert(useCase.updateCalled)
        XCTAssertFalse(navigator.dismissCalled)
        XCTAssert(errorOutput.lastEventElement is TestError)
    }
    
    func test_cancelTriggerInvoked_dismiss() {
        // act
        startTriggers(cancel: .next(0, ()))
        
        // assert
        XCTAssert(navigator.dismissCalled)
    }
    
}
