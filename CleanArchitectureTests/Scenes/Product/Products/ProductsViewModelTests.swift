//
//  ProductsViewModelTests.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/5/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import RxSwift
import RxTest
import RxCocoa

final class ProductsViewModelTests: XCTestCase {
    private var viewModel: TestProductsViewModel!
    private var input: ProductsViewModel.Input!
    private var output: ProductsViewModel.Output!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    // Outputs
    private var errorOutput: TestableObserver<Error>!
    private var isLoadingOutput: TestableObserver<Bool>!
    private var isReloadingOutput: TestableObserver<Bool>!
    private var isLoadingMoreOutput: TestableObserver<Bool>!
    private var productListOutput: TestableObserver<[ProductItemViewModel]>!
    private var selectedProductOutput: TestableObserver<Void>!
    private var editedProductOutput: TestableObserver<Void>!
    private var isEmptyOutput: TestableObserver<Bool>!
    private var deletedProductOutput: TestableObserver<Void>!
    
    // Triggers
    private let loadTrigger = PublishSubject<Void>()
    private let reloadTrigger = PublishSubject<Void>()
    private let loadMoreTrigger = PublishSubject<Void>()
    private let selectProductTrigger = PublishSubject<IndexPath>()
    private let editProductTrigger = PublishSubject<IndexPath>()
    private let deleteProductTrigger = PublishSubject<IndexPath>()

    override func setUp() {
        super.setUp()
        viewModel = TestProductsViewModel(navigationController: UINavigationController())
        
        input = ProductsViewModel.Input(
            load: loadTrigger.asDriverOnErrorJustComplete(),
            reload: reloadTrigger.asDriverOnErrorJustComplete(),
            loadMore: loadMoreTrigger.asDriverOnErrorJustComplete(),
            selectProduct: selectProductTrigger.asDriverOnErrorJustComplete(),
            editProduct: editProductTrigger.asDriverOnErrorJustComplete(),
            deleteProduct: deleteProductTrigger.asDriverOnErrorJustComplete()
        )
        
        disposeBag = DisposeBag()
        output = viewModel.transform(input, disposeBag: disposeBag)
        
        scheduler = TestScheduler(initialClock: 0)
        
        errorOutput = scheduler.createObserver(Error.self)
        isLoadingOutput = scheduler.createObserver(Bool.self)
        isReloadingOutput = scheduler.createObserver(Bool.self)
        isLoadingMoreOutput = scheduler.createObserver(Bool.self)
        productListOutput = scheduler.createObserver([ProductItemViewModel].self)
        selectedProductOutput = scheduler.createObserver(Void.self)
        editedProductOutput = scheduler.createObserver(Void.self)
        isEmptyOutput = scheduler.createObserver(Bool.self)
        deletedProductOutput = scheduler.createObserver(Void.self)
        
        output.$error.asDriver().unwrap().drive(errorOutput).disposed(by: disposeBag)
        output.$isLoading.asDriver().drive(isLoadingOutput).disposed(by: disposeBag)
        output.$isReloading.asDriver().drive(isReloadingOutput).disposed(by: disposeBag)
        output.$isLoadingMore.asDriver().drive(isLoadingMoreOutput).disposed(by: disposeBag)
        output.$productList.asDriver().drive(productListOutput).disposed(by: disposeBag)
        output.$isEmpty.asDriver().drive(isEmptyOutput).disposed(by: disposeBag)
    }
    
    private func startTriggers(load: Recorded<Event<Void>>? = nil,
                               reload: Recorded<Event<Void>>? = nil,
                               loadMore: Recorded<Event<Void>>? = nil,
                               selectProduct: Recorded<Event<IndexPath>>? = nil,
                               editProduct: Recorded<Event<IndexPath>>? = nil,
                               deleteProduct: Recorded<Event<IndexPath>>? = nil) {
        if let load = load {
            scheduler.createColdObservable([load]).bind(to: loadTrigger).disposed(by: disposeBag)
        }
        
        if let reload = reload {
            scheduler.createColdObservable([reload]).bind(to: reloadTrigger).disposed(by: disposeBag)
        }
        
        if let loadMore = loadMore {
            scheduler.createColdObservable([loadMore]).bind(to: loadMoreTrigger).disposed(by: disposeBag)
        }
        
        if let selectProduct = selectProduct {
            scheduler.createColdObservable([selectProduct]).bind(to: selectProductTrigger).disposed(by: disposeBag)
        }
        
        if let editProduct = editProduct {
            scheduler.createColdObservable([editProduct]).bind(to: editProductTrigger).disposed(by: disposeBag)
        }
        
        if let deleteProduct = deleteProduct {
            scheduler.createColdObservable([deleteProduct]).bind(to: deleteProductTrigger).disposed(by: disposeBag)
        }
        
        scheduler.start()
    }

    func test_loadTriggerInvoked_getProductList() {
        // act
        startTriggers(load: .next(0, ()))
        
        // assert
        XCTAssert(viewModel.getProductListCalled)
        XCTAssertEqual(productListOutput.lastEventElement?.count, 1)
    }

    func test_loadTriggerInvoked_getProductList_failedShowError() {
        // arrange
        viewModel.getProductListResult = .error(TestError())

        // act
        startTriggers(load: .next(0, ()))

        // assert
        XCTAssert(viewModel.getProductListCalled)
        XCTAssert(errorOutput.lastEventElement is TestError)
    }

    func test_reloadTriggerInvoked_getProductList() {
        // act
        startTriggers(reload: .next(0, ()))

        // assert
        XCTAssert(viewModel.getProductListCalled)
        XCTAssertEqual(productListOutput.lastEventElement?.count, 1)
    }

    func test_reloadTriggerInvoked_getProductList_failedShowError() {
        // arrange
        viewModel.getProductListResult = Observable.error(TestError())

        // act
        startTriggers(reload: .next(0, ()))

        // assert
        XCTAssert(viewModel.getProductListCalled)
        XCTAssert(errorOutput.lastEventElement is TestError)
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
        startTriggers(load: .next(0, ()), loadMore: .next(10, ()))

        // assert
        XCTAssert(viewModel.getProductListCalled)
        XCTAssertEqual(productListOutput.lastEventElement?.count, 2)
    }

    func test_loadMoreTriggerInvoked_loadMoreProductList_failedShowError() {
        // arrange
        viewModel.getProductListResult = .error(TestError())

        // act
        startTriggers(load: .next(0, ()), loadMore: .next(10, ()))

        // assert
        XCTAssert(viewModel.getProductListCalled)
        XCTAssert(errorOutput.lastEventElement is TestError)
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
        startTriggers(load: .next(0, ()), selectProduct: .next(10, IndexPath(row: 0, section: 0)))

        // assert
        XCTAssert(viewModel.showProductDetailCalled)
    }
    
    func test_editProductTriggerInvoked_editProduct() {
        // act
        startTriggers(load: .next(0, ()), editProduct: .next(10, IndexPath(row: 0, section: 0)))

        // assert
        XCTAssert(viewModel.showEditProductCalled)
    }
    
    func test_deletedProductInvoked_deleteProduct() {
        // act
        startTriggers(load: .next(0, ()), deleteProduct: .next(10, IndexPath(row: 0, section: 0)))

        // assert
        XCTAssert(viewModel.confirmDeleteProductCalled)
        XCTAssert(viewModel.deleteProductCalled)
    }
}

final class TestProductsViewModel: ProductsViewModel {
    var getProductListCalled: Bool = false
    var getProductListResult: Observable<PagingInfo<Product>> = .just(PagingInfo<Product>(page: 1, items: [Product()]))
    
    override func getProductList(page: Int) -> Observable<PagingInfo<Product>> {
        getProductListCalled = true
        return getProductListResult
    }
    
    var deleteProductCalled: Bool = false
    var deleteProductResult: Observable<Void> = .just(())
    
    override func vm_deleteProduct(dto: DeleteProductDto) -> Observable<Void> {
        deleteProductCalled = true
        return deleteProductResult
    }
    
    var confirmDeleteProductCalled: Bool = false
    var confirmDeleteProductResult: Driver<Void> = .just(())
    
    override func confirmDeleteProduct(_ product: Product) -> Driver<Void> {
        confirmDeleteProductCalled = true
        return confirmDeleteProductResult
    }
    
    var showProductDetailCalled: Bool = false
    
    override func vm_showProductDetail(product: Product) {
        showProductDetailCalled = true
    }
    
    var showEditProductCalled: Bool = false
    var showEditProductResult: Driver<EditProductDelegate> = .just(.updatedProduct(Product()))
    
    override func vm_showEditProduct(_ product: Product) -> Driver<EditProductDelegate> {
        showEditProductCalled = true
        return showEditProductResult
    }
}
