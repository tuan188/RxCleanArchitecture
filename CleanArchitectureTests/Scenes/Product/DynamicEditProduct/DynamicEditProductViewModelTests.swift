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
    private var viewModel: TestDynamicEditProductViewModel!
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
        viewModel = TestDynamicEditProductViewModel(navigationController: UINavigationController(),
                                                    product: Product())
        
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
        XCTAssert(viewModel.dismissCalled)
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
        XCTAssert(viewModel.validateNameCalled)
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
        XCTAssert(viewModel.validatePriceCalled)
    }
    
    func test_loadTriggerInvoked_enableUpdateByDefault() {
        // act
        loadTrigger.onNext(.load)
        
        // assert
        XCTAssertEqual(output.isUpdateEnabled, true)
    }
    
    func test_updateTrigger_not_update() {
        // arrange
        viewModel.validateNameResult = ValidationResult.failure(ValidationError(description: ""))
        viewModel.validatePriceResult = ValidationResult.failure(ValidationError(description: ""))
        
        // act
        dataTrigger.onNext(DynamicEditProductViewModel.DataType.name("foo"))
        dataTrigger.onNext(DynamicEditProductViewModel.DataType.price("1.0"))
        updateTrigger.onNext(())
        
        // assert
        XCTAssertFalse(output.nameValidation.isValid)
        XCTAssertFalse(output.priceValidation.isValid)
        XCTAssertEqual(output.isUpdateEnabled, false)
        XCTAssertFalse(viewModel.updateCalled)
    }
    
    func test_updateTrigger_update() {
        // act
        updateTrigger.onNext(())
        
        // assert
        XCTAssert(viewModel.updateCalled)
        XCTAssert(viewModel.notifyUpdatedCalled)
    }
    
    func test_updateTrigger_update_fail_show_error() {
        // arrange
        viewModel.updateResult = Observable.error(TestError())
        
        // act
        updateTrigger.onNext(())
        
        // assert
        XCTAssert(viewModel.updateCalled)
        XCTAssert(output.error is TestError)
    }
}

class TestDynamicEditProductViewModel: DynamicEditProductViewModel {
    var validateNameCalled: Bool = false
    var validateNameResult: ValidationResult = .success(())
    
    override func validateName(_ name: String) -> ValidationResult {
        validateNameCalled = true
        return validateNameResult
    }
    
    var validatePriceCalled: Bool = false
    var validatePriceResult: ValidationResult = .success(())
    
    override func validatePrice(_ price: String) -> ValidationResult {
        validatePriceCalled = true
        return validatePriceResult
    }
    
    var updateCalled: Bool = false
    var updateResult: Observable<Void> = .just(())
    
    override func update(_ product: ProductDto) -> Observable<Void> {
        updateCalled = true
        return updateResult
    }
    
    var notifyUpdatedCalled: Bool = false
    
    override func notifyUpdated(_ product: Product) {
        notifyUpdatedCalled = true
    }
    
    var dismissCalled: Bool = false
    
    override func vm_dismiss() {
        dismissCalled = true
    }
}
