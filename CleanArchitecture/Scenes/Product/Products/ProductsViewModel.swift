//
//  ProductsViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/5/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import Factory
import RxCleanArchitecture

class ProductsViewModel: FetchProductList, DeleteProduct, ShowProductDetail, ShowEditProduct {
    @Injected(\.productGateway)
    var productGateway: ProductGatewayProtocol
    
    unowned var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func getProductList(page: Int) -> Observable<PagingInfo<Product>> {
        let dto = FetchPageDto(page: page, perPage: 10, usingCache: true)
        return fetchProducts(dto: dto)
    }
    
    func vm_deleteProduct(dto: DeleteProductDto) -> Observable<Void> {
        deleteProduct(dto: dto)
    }
    
    func confirmDeleteProduct(_ product: Product) -> Driver<Void> {
        return Observable<Void>.create({ (observer) -> Disposable in
            let alert = UIAlertController(
                title: "Delete product: " + product.name,
                message: "Are you sure?",
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(
                title: "Delete",
                style: .destructive) { _ in
                    observer.onNext(())
                    observer.onCompleted()
            }
            alert.addAction(okAction)
            
            let cancel = UIAlertAction(title: "Cancel",
                                       style: UIAlertAction.Style.cancel) { (_) in
                                        observer.onCompleted()
            }
            alert.addAction(cancel)
            
            self.navigationController.present(alert, animated: true, completion: nil)
            
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        })
        .asDriverOnErrorJustComplete()
    }
    
    func vm_showProductDetail(product: Product) {
        showProductDetail(product: product)
    }
    
    func vm_showEditProduct(_ product: Product) -> Driver<EditProductDelegate> {
        showEditProduct(product)
    }
}

// MARK: - ViewModel
extension ProductsViewModel: ViewModel {
    struct Input {
        let load: Driver<Void>
        let reload: Driver<Void> 
        let loadMore: Driver<Void>
        let selectProduct: Driver<IndexPath>
        let editProduct: Driver<IndexPath>
        let deleteProduct: Driver<IndexPath>
    }

    struct Output {
        @Property var error: Error?
        @Property var isLoading = false
        @Property var isReloading = false
        @Property var isLoadingMore = false
        @Property var productList = [ProductItemViewModel]()
        @Property var isEmpty = false
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        // Error
        
        let errorTracker = ErrorTracker()
        
        errorTracker.asDriver()
            .drive(output.$error)
            .disposed(by: disposeBag)

        // Loading
        
        let activityIndicator = PageActivityIndicator()
        let isLoading = activityIndicator.isLoading
        let isReloading = activityIndicator.isReloading
        
        isLoading
            .drive(output.$isLoading)
            .disposed(by: disposeBag)
        
        isReloading
            .drive(output.$isReloading)
            .disposed(by: disposeBag)
        
        activityIndicator.isLoadingMore
            .drive(output.$isLoadingMore)
            .disposed(by: disposeBag)
        
        // Get page
        
        let pageSubject = BehaviorRelay(value: PagingInfo<ProductModel>(page: 1, items: []))
        let updatedProductSubject = PublishSubject<Void>()
        let deleteProductSubject = PublishSubject<Void>()
        
        let config = PageFetchConfig(
            pageSubject: pageSubject,
            pageActivityIndicator: activityIndicator,
            errorTracker: errorTracker,
            loadTrigger: input.load,
            reloadTrigger: input.reload,
            loadMoreTrigger: input.loadMore,
            fetchItems: { [unowned self] _, page in
                return getProductList(page: page)
            },
            mapper: ProductModel.init(product:)
        )
        
        let fetchPageResult = fetchPage(config: config)
        
        let page = Driver.merge(
            fetchPageResult.page,
            Driver
                .merge(
                    updatedProductSubject.asDriverOnErrorJustComplete(),
                    deleteProductSubject.asDriverOnErrorJustComplete()
                )
                .withLatestFrom(pageSubject.asDriver())
        )

        let productList = page
            .map { $0.items }
        
        productList
            .map { products in products.map(ProductItemViewModel.init) }
            .drive(output.$productList)
            .disposed(by: disposeBag)
        
        // Select product
        
        selectItem(at: input.selectProduct, from: productList)
            .drive(onNext: { product in
                self.vm_showProductDetail(product: product.product)
            })
            .disposed(by: disposeBag)
        
        // Edit product
        
        selectItem(at: input.editProduct, from: productList)
            .map { $0.product }
            .flatMapLatest { product -> Driver<EditProductDelegate> in
                self.vm_showEditProduct(product)
            }
            .drive(onNext: { delegate in
                switch delegate {
                case .updatedProduct(let product):
                    let page = pageSubject.value
                    var productList = page.items
                    let productModel = ProductModel(product: product, edited: true)
                    
                    if let index = productList.firstIndex(of: productModel) {
                        productList[index] = productModel
                        let updatedPage = PagingInfo(page: page.page, items: productList)
                        pageSubject.accept(updatedPage)
                        updatedProductSubject.onNext(())
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // Check empty

        isDataEmpty(loadingTrigger: Driver.merge(isLoading, isReloading),
                    dataItems: productList)
            .drive(output.$isEmpty)
            .disposed(by: disposeBag)
        
        // Delete product
        
        selectItem(at: input.deleteProduct, from: productList)
            .map { $0.product }
            .flatMapLatest { product -> Driver<Product> in
                self.confirmDeleteProduct(product)
                    .map { product }
            }
            .flatMapLatest { product -> Driver<Product> in
                self.vm_deleteProduct(dto: DeleteProductDto(id: product.id))
                    .trackActivity(activityIndicator.loadingIndicator)
                    .trackError(errorTracker)
                    .map { _ in product }
                    .asDriverOnErrorJustComplete()
            }
            .drive(onNext: { product in
                let page = pageSubject.value
                
                var productList = page.items
                productList.removeAll { $0.product.id == product.id }
                
                let updatedPage = PagingInfo(page: page.page, items: productList)
                pageSubject.accept(updatedPage)
                deleteProductSubject.onNext(())
            })
            .disposed(by: disposeBag)
        
        return output
    }
}

