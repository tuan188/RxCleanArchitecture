//
//  DynamicEditProductViewModelTests.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 9/10/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import RxSwift
import ValidatedPropertyKit

final class DynamicEditProductViewModelTests: XCTestCase {
    private var viewModel: DynamicEditProductViewModel!
    private var navigator: DynamicEditProductNavigatorMock!
    private var useCase: DynamicEditProductUseCaseMock!
    private var input: DynamicEditProductViewModel.Input!
    private var output: DynamicEditProductViewModel.Output!
    private var disposeBag: DisposeBag!

    // Triggers
    private let loadTrigger = PublishSubject<DynamicEditProductViewModel.TriggerType>()
    private let updateTrigger = PublishSubject<Void>()
    private let cancelTrigger = PublishSubject<Void>()
    private let dataTrigger = PublishSubject<DynamicEditProductViewModel.DataType>()
    
    override func setUp() {
        super.setUp()
        navigator = DynamicEditProductNavigatorMock()
        useCase = DynamicEditProductUseCaseMock()
        viewModel = DynamicEditProductViewModel(navigator: navigator, useCase: useCase, product: Product())
        
        input = DynamicEditProductViewModel.Input(
            load: loadTrigger.asDriverOnErrorJustComplete(),
            update: updateTrigger.asDriverOnErrorJustComplete(),
            cancel: cancelTrigger.asDriverOnErrorJustComplete(),
            data: dataTrigger.asDriverOnErrorJustComplete()
        )
        
        disposeBag = DisposeBag()
        output = viewModel.transform(input, disposeBag: disposeBag)
    }
    
    func test_loadTrigger_cells_need_reload() {
        // act
        loadTrigger.onNext(.load)
        let cellCollection = output.cellCollection
        
        // assert
        XCTAssertEqual(cellCollection.cells.count, 2)
        XCTAssertEqual(cellCollection.needsReloading, true)
    }
    
    func test_loadTrigger_cells_no_need_reload() {
        // act
        loadTrigger.onNext(.endEditing)
        let cellCollection = output.cellCollection
        
        // assert
        XCTAssertEqual(cellCollection.cells.count, 2)
        XCTAssertEqual(cellCollection.needsReloading, false)
    }
    
    func test_cancelTrigger_dismiss() {
        // act
        cancelTrigger.onNext(())
        
        // assert
        XCTAssert(navigator.dismissCalled)
    }
    
    func test_dataTrigger_product_name() {
        // act
        let productName = "foo"
        dataTrigger.onNext(DynamicEditProductViewModel.DataType.name(productName))
        loadTrigger.onNext(.endEditing)
        let cellCollection = output.cellCollection
        
        // assert
        XCTAssertEqual(cellCollection.cells.count, 2)
        
        if case let DynamicEditProductViewModel.DataType.name(name) = cellCollection.cells[0].dataType {
            XCTAssertEqual(name, productName)
        } else {
            XCTFail()
        }
    }
    
    func test_dataTrigger_validate_product_name() {
        // act
        let productName = "foo"
        dataTrigger.onNext(DynamicEditProductViewModel.DataType.name(productName))
        updateTrigger.onNext(())
        
        // assert
        XCTAssert(useCase.validateNameCalled)
    }
    
    func test_dataTrigger_product_price() {
        // act
        let productPrice = "1.0"
        dataTrigger.onNext(DynamicEditProductViewModel.DataType.price(productPrice))
        loadTrigger.onNext(.endEditing)
        let cellCollection = output.cellCollection
        
        // assert
        XCTAssertEqual(cellCollection.cells.count, 2)
        
        if case let DynamicEditProductViewModel.DataType.price(price) = cellCollection.cells[1].dataType {
            XCTAssertEqual(price, String(Double(productPrice) ?? 0))
        } else {
            XCTFail()
        }
    }
    
    func test_dataTrigger_validate_product_price() {
        // act
        let productPrice = "1.0"
        dataTrigger.onNext(DynamicEditProductViewModel.DataType.price(productPrice))
        updateTrigger.onNext(())
        
        // assert
        XCTAssert(useCase.validatePriceCalled)
    }
    
    func test_loadTriggerInvoked_enableUpdateByDefault() {
        // act
        loadTrigger.onNext(.load)
        
        // assert
        XCTAssertEqual(output.isUpdateEnabled, true)
    }
    
    func test_updateTrigger_not_update() {
        // arrange
        useCase.validateNameReturnValue = ValidationResult.failure(ValidationError(message: ""))
        useCase.validatePriceReturnValue = ValidationResult.failure(ValidationError(message: ""))
        
        // act
        dataTrigger.onNext(DynamicEditProductViewModel.DataType.name("foo"))
        dataTrigger.onNext(DynamicEditProductViewModel.DataType.price("1.0"))
        updateTrigger.onNext(())
        
        // assert
        XCTAssertFalse(output.nameValidation.isValid)
        XCTAssertFalse(output.priceValidation.isValid)
        XCTAssertEqual(output.isUpdateEnabled, false)
        XCTAssertFalse(useCase.updateCalled)
    }
    
    func test_updateTrigger_update() {
        // act
        updateTrigger.onNext(())
        
        // assert
        XCTAssert(useCase.updateCalled)
        XCTAssert(useCase.notifyUpdatedCalled)
    }
    
    func test_updateTrigger_update_fail_show_error() {
        // arrange
        useCase.updateReturnValue = Observable.error(TestError())
        
        // act
        updateTrigger.onNext(())
        
        // assert
        XCTAssert(useCase.updateCalled)
        XCTAssert(output.error is TestError)
    }
}
