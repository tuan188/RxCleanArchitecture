//
//  ProductDetailViewModelTests.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/22/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import RxSwift

final class ProductDetailViewModelTests: XCTestCase {

    private var viewModel: ProductDetailViewModel!
    private var input: ProductDetailViewModel.Input!
    private var output: ProductDetailViewModel.Output!
    private var disposeBag: DisposeBag!

    // Triggers
    private let loadTrigger = PublishSubject<Void>()
    
    private let product = Product(id: 1, name: "Foo", price: 1)

    override func setUp() {
        super.setUp()
        viewModel = ProductDetailViewModel(product: product)
        
        input = ProductDetailViewModel.Input(
            load: loadTrigger.asDriverOnErrorJustComplete()
        )
        
        disposeBag = DisposeBag()
        output = viewModel.transform(input, disposeBag: disposeBag)
    }

    func test_loadTriggerInvoked_createCells() {
        // act
        loadTrigger.onNext(())
        let cells = output.cells
        var productName: String?
        var productPrice: String?
        
        if case let ProductDetailViewModel.Cell.name(name) = cells[0] {
            productName = name
        }
        
        if case let ProductDetailViewModel.Cell.price(price) = cells[1] {
            productPrice = price
        }

        // assert
        XCTAssertEqual(cells.count, 2)
        XCTAssertEqual(productName, product.name)
        XCTAssertEqual(productPrice, product.price.currency)
    }

}
