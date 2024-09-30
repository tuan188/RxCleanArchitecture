//
//  ProductDetailViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/22/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import Factory

final class ProductDetailViewController: UIViewController, Bindable {
    
    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties

    var viewModel: ProductDetailViewModel!
    var disposeBag = DisposeBag()
    
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
            $0.estimatedRowHeight = 550
            $0.rowHeight = UITableView.automaticDimension
            $0.register(cellType: ProductNameCell.self)
            $0.register(cellType: ProductPriceCell.self)
        }
    }

    func bindViewModel() {
        let input = ProductDetailViewModel.Input(load: Driver.just(()))
        
        let output = viewModel.transform(input, disposeBag: disposeBag)
        
        output.$cells
            .asDriver()
            .drive(tableView.rx.items) { tableView, index, cell in
                let indexPath = IndexPath(row: index, section: 0)
                switch cell {
                case let .name(name):
                    return tableView.dequeueReusableCell(for: indexPath,
                                                         cellType: ProductNameCell.self)
                        .then {
                            $0.nameLabel.text = name
                        }
                case let .price(price):
                    return tableView.dequeueReusableCell(for: indexPath,
                                                         cellType: ProductPriceCell.self)
                        .then {
                            $0.priceLabel.text = price
                        }
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - StoryboardSceneBased
extension ProductDetailViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.product
}

extension Container {
    func productDetailViewController(product: Product) -> Factory<ProductDetailViewController> {
        Factory(self) {
            let vc = ProductDetailViewController.instantiate()
            let vm = ProductDetailViewModel(product: product)
            vc.bindViewModel(to: vm)
            return vc
        }
    }
}
