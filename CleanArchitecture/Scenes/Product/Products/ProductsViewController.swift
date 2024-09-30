//
//  ProductsViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/5/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import Factory

final class ProductsViewController: UIViewController, Bindable {
    
    // MARK: - IBOutlets

    @IBOutlet weak var tableView: PagingTableView!
    
    // MARK: - Properties

    var viewModel: ProductsViewModel!
    var disposeBag = DisposeBag()
    
    private var products = [ProductItemViewModel]()
    private var editProductTrigger = PublishSubject<IndexPath>()
    private var deleteProductTrigger = PublishSubject<IndexPath>()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    deinit {
        logDeinit()
    }
    
    // MARK: - Methods
    
    private func configView() {
        tableView.do {
            $0.register(cellType: ProductCell.self)
            $0.delegate = self
            $0.dataSource = self
            $0.estimatedRowHeight = 550
            $0.rowHeight = UITableView.automaticDimension
        }
        
        tableView.refreshHeader = RefreshHeaderAnimator(frame: .zero)
        
        view.backgroundColor = ColorCompatibility.systemBackground
    }

    func bindViewModel() {
        let input = ProductsViewModel.Input(
            load: Driver.just(()),
            reload: tableView.refreshTrigger,
            loadMore: tableView.loadMoreTrigger,
            selectProduct: tableView.rx.itemSelected.asDriver(),
            editProduct: editProductTrigger.asDriverOnErrorJustComplete(),
            deleteProduct: deleteProductTrigger.asDriverOnErrorJustComplete()
        )
        
        let output = viewModel?.transform(input, disposeBag: disposeBag)
        
        
        
        output?.$productList
            .asDriver()
            .drive(onNext: { [unowned self] products in
                self.products = products
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output?.$error
            .asDriver()
            .unwrap()
            .drive(rx.error)
            .disposed(by: disposeBag)
        
        output?.$isLoading
            .asDriver()
            .drive(rx.isLoading)
            .disposed(by: disposeBag)
        
        output?.$isReloading
            .asDriver()
            .drive(tableView.isRefreshing)
            .disposed(by: disposeBag)
        
        output?.$isLoadingMore
            .asDriver()
            .drive(tableView.isLoadingMore)
            .disposed(by: disposeBag)
        
        output?.$isEmpty
            .asDriver()
            .drive(tableView.isEmpty)
            .disposed(by: disposeBag)
    }
    
    public var isRefreshing2: Binder<Bool> {
        return Binder(self) { tableView, loading in
            
        }
    }

}

// MARK: - UITableViewDataSource
extension ProductsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = products[indexPath.row]
        
        return tableView.dequeueReusableCell(for: indexPath, cellType: ProductCell.self).with { [weak self] in
            $0.bindViewModel(product)
            
            $0.editProductAction = {
                self?.editProductTrigger.onNext(indexPath)
            }
            
            $0.deleteProductAction = {
                self?.deleteProductTrigger.onNext(indexPath)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension ProductsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - StoryboardSceneBased
extension ProductsViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.product
}

extension Container {
    func productsViewController(navigationController: UINavigationController) -> Factory<ProductsViewController> {
        Factory(self) {
            let vc = ProductsViewController.instantiate()
            let vm = ProductsViewModel(navigationController: navigationController)
            vc.bindViewModel(to: vm)
            return vc
        }
    }
}
