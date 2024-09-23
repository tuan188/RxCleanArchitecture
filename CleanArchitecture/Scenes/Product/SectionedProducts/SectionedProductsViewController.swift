//
//  SectionedProductsViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/11/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import MGLoadMore
import MGArchitecture
import Factory

final class SectionedProductsViewController: UIViewController, Bindable {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: PagingTableView!
    
    // MARK: - Properties
    
    var viewModel: SectionedProductsViewModel!
    var disposeBag = DisposeBag()
    
    private var productSections = [SectionedProductsViewModel.ProductSectionViewModel]()
    private let editProductTrigger = PublishSubject<IndexPath>()
    
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
            $0.register(cellType: SectionedProductCell.self)
            $0.register(headerFooterViewType: ProductHeaderView.self)
            $0.estimatedRowHeight = 550
            $0.rowHeight = UITableView.automaticDimension
            $0.delegate = self
            $0.dataSource = self
        }
        
        view.backgroundColor = ColorCompatibility.systemBackground
    }

    func bindViewModel() {
        let updatedProductTrigger = NotificationCenter.default.rx
            .notification(Notification.Name.updatedProduct)
            .map { notification in
                notification.object as? Product
            }
            .unwrap()
            .asDriverOnErrorJustComplete()
        
        let input = SectionedProductsViewModel.Input(
            load: Driver.just(()),
            reload: tableView.refreshTrigger.debug(),
            loadMore: tableView.loadMoreTrigger,
            selectProduct: tableView.rx.itemSelected.asDriver(),
            editProduct: editProductTrigger.asDriverOnErrorJustComplete(),
            updatedProduct: updatedProductTrigger
        )
        
        let output = viewModel.transform(input, disposeBag: disposeBag)
        
        output.$productSections
            .asDriver()
            .drive(onNext: { [unowned self] sections in
                self.productSections = sections
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.$error
            .asDriver()
            .unwrap()
            .drive(rx.error)
            .disposed(by: disposeBag)
        
        output.$isLoading
            .asDriver()
            .drive(rx.isLoading)
            .disposed(by: disposeBag)
        
        output.$isReloading
            .asDriver()
            .drive(tableView.isRefreshing)
            .disposed(by: disposeBag)
        
        output.$isLoadingMore
            .asDriver()
            .drive(tableView.isLoadingMore)
            .disposed(by: disposeBag)
        
        output.$isEmpty
            .asDriver()
            .drive(tableView.isEmpty)
            .disposed(by: disposeBag)
    }

}

// MARK: - UITableViewDataSource
extension SectionedProductsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return productSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productSections[section].productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = productSections[indexPath.section].productList[indexPath.row]
        
        return tableView.dequeueReusableCell(for: indexPath,
                                             cellType: SectionedProductCell.self)
            .then { [weak self] in
                $0.bindViewModel(product)
                
                $0.editProductAction = {
                    self?.editProductTrigger.onNext(indexPath)
                }
            }
    }
}

// MARK: - UITableViewDelegate
extension SectionedProductsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(ProductHeaderView.self)
        header?.titleLabel.text = productSections[section].header
        return header
    }
}

// MARK: - StoryboardSceneBased
extension SectionedProductsViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.product
}

extension Container {
    func sectionedProductsViewController(navigationController: UINavigationController) -> Factory<SectionedProductsViewController> {
        Factory(self) {
            let vc = SectionedProductsViewController.instantiate()
            let vm = SectionedProductsViewModel(navigationController: navigationController)
            vc.bindViewModel(to: vm)
            return vc
        }
    }
}
