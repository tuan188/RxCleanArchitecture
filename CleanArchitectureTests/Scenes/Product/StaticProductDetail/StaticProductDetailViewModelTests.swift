//
//  StaticProductDetailViewModelTests.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/24/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import RxSwift

final class StaticProductDetailViewModelTests: XCTestCase {

    private var viewModel: StaticProductDetailViewModel!
    private var input: StaticProductDetailViewModel.Input!
    private var output: StaticProductDetailViewModel.Output!
    private var disposeBag: DisposeBag!
    
    // Triggers
    private let loadTrigger = PublishSubject<Void>()
    
    private let product = Product(id: 1, name: "Foo", price: 1)

    override func setUp() {
        super.setUp()
        viewModel = StaticProductDetailViewModel(product: product)
        
        input = StaticProductDetailViewModel.Input(
            load: loadTrigger.asDriverOnErrorJustComplete()
        )
        
        disposeBag = DisposeBag()
        output = viewModel.transform(input, disposeBag: disposeBag)
    }

    func test_loadTriggerInvoked_createCells() {
        // act
        loadTrigger.onNext(())

        // assert
        XCTAssertEqual(output.name, product.name)
        XCTAssertEqual(output.price, product.price.currency)
    }

}
