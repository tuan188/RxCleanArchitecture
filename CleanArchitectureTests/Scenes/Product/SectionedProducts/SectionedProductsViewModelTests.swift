//
//  SectionedProductsViewModelTests.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/11/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import RxSwift
import RxCleanArchitecture
    
final class SectionedProductsViewModelTests: XCTestCase {
    private var viewModel: TestSectionedProductsViewModel!
    private var input: SectionedProductsViewModel.Input!
    private var output: SectionedProductsViewModel.Output!
    private var disposeBag: DisposeBag!

    // Triggers
    private let loadTrigger = PublishSubject<Void>()
    private let reloadTrigger = PublishSubject<Void>()
    private let loadMoreTrigger = PublishSubject<Void>()
    private let selectProductTrigger = PublishSubject<IndexPath>()
    private let editProductTrigger = PublishSubject<IndexPath>()
    private let updatedProductTrigger = PublishSubject<Product>()

    override func setUp() {
        super.setUp()
        viewModel = TestSectionedProductsViewModel(navigationController: UINavigationController())
        
        input = SectionedProductsViewModel.Input(
            load: loadTrigger.asDriverOnErrorJustComplete(),
            reload: reloadTrigger.asDriverOnErrorJustComplete(),
            loadMore: loadMoreTrigger.asDriverOnErrorJustComplete(),
            selectProduct: selectProductTrigger.asDriverOnErrorJustComplete(),
            editProduct: editProductTrigger.asDriverOnErrorJustComplete(),
            updatedProduct: updatedProductTrigger.asDriverOnErrorJustComplete()
        )
        
        disposeBag = DisposeBag()
        output = viewModel.transform(input, disposeBag: disposeBag)
    }

    func test_loadTriggerInvoked_getProductList() {
        // act
        loadTrigger.onNext(())
        
        // assert
        XCTAssert(viewModel.getProductListCalled)
        XCTAssertEqual(output.productSections.count, 1)
        XCTAssertEqual(output.productSections[0].productList.count, 1)
    }

    func test_loadTriggerInvoked_getProductList_failedShowError() {
        // arrange
        viewModel.getProductListResult = .error(TestError())

        // act
        loadTrigger.onNext(())

        // assert
        XCTAssert(viewModel.getProductListCalled)
        XCTAssert(output.error is TestError)
    }

    func test_reloadTriggerInvoked_getProductList() {
        // act
        reloadTrigger.onNext(())

        // assert
        XCTAssert(viewModel.getProductListCalled)
        XCTAssertEqual(output.productSections.count, 1)
        XCTAssertEqual(output.productSections[0].productList.count, 1)
    }

    func test_reloadTriggerInvoked_getProductList_failedShowError() {
        // arrange
        viewModel.getProductListResult = .error(TestError())

        // act
        reloadTrigger.onNext(())

        // assert
        XCTAssert(viewModel.getProductListCalled)
        XCTAssert(output.error is TestError)
    }

    func test_reloadTriggerInvoked_notGetProductListIfStillLoading() {
        // arrange
        viewModel.getProductListResult = .never()

        // act
        loadTrigger.onNext(())
        viewModel.getProductListCalled = false
        reloadTrigger.onNext(())

        // assert
        XCTAssertFalse(viewModel.getProductListCalled)
    }

    func test_reloadTriggerInvoked_notGetProductListIfStillReloading() {
        // arrange
        viewModel.getProductListResult = .never()

        // act
        reloadTrigger.onNext(())
        viewModel.getProductListCalled = false
        reloadTrigger.onNext(())

        // assert
        XCTAssertFalse(viewModel.getProductListCalled)
    }

    func test_loadMoreTriggerInvoked_loadMoreProductList() {
        // act
        loadTrigger.onNext(())
        loadMoreTrigger.onNext(())

        // assert
        XCTAssert(viewModel.getProductListCalled)
        XCTAssertEqual(output.productSections.count, 1)
        XCTAssertEqual(output.productSections[0].productList.count, 2)
    }

    func test_loadMoreTriggerInvoked_loadMoreProductList_failedShowError() {
        // arrange
        viewModel.getProductListResult = .error(TestError())

        // act
        loadTrigger.onNext(())
        loadMoreTrigger.onNext(())

        // assert
        XCTAssert(viewModel.getProductListCalled)
        XCTAssert(output.error is TestError)
    }

    func test_loadMoreTriggerInvoked_notLoadMoreProductListIfStillLoading() {
        // arrange
        viewModel.getProductListResult = .never()

        // act
        loadTrigger.onNext(())
        viewModel.getProductListCalled = false
        loadMoreTrigger.onNext(())

        // assert
        XCTAssertFalse(viewModel.getProductListCalled)
    }

    func test_loadMoreTriggerInvoked_notLoadMoreProductListIfStillReloading() {
        // arrange
        viewModel.getProductListResult = .never()

        // act
        reloadTrigger.onNext(())
        viewModel.getProductListCalled = false
        loadMoreTrigger.onNext(())
        
        // assert
        XCTAssertFalse(viewModel.getProductListCalled)
    }

    func test_loadMoreTriggerInvoked_notLoadMoreDocumentTypesStillLoadingMore() {
        // arrange
        viewModel.getProductListResult = .never()

        // act
        loadMoreTrigger.onNext(())
        viewModel.getProductListCalled = false
        loadMoreTrigger.onNext(())

        // assert
        XCTAssertFalse(viewModel.getProductListCalled)
    }

    func test_selectProductTriggerInvoked_toProductDetail() {
        // act
        loadTrigger.onNext(())
        selectProductTrigger.onNext(IndexPath(row: 0, section: 0))

        // assert
        XCTAssert(viewModel.showStaticProductDetailCalled)
    }
}

final class TestSectionedProductsViewModel: SectionedProductsViewModel {
    var getProductListCalled: Bool = false
    var getProductListResult: Observable<PagingInfo<Product>> = .just(PagingInfo<Product>(page: 1, items: [Product()]))
    
    override func getProductList(page: Int) -> Observable<PagingInfo<Product>> {
        getProductListCalled = true
        return getProductListResult
    }
    
    var showStaticProductDetailCalled: Bool = false
    
    override func vm_showStaticProductDetail(product: Product) {
        showStaticProductDetailCalled = true
    }
    
    var showDynamicEditProductCalled: Bool = false
    
    override func vm_showDynamicEditProduct(_ product: Product) {
        showDynamicEditProductCalled = true
    }
}

