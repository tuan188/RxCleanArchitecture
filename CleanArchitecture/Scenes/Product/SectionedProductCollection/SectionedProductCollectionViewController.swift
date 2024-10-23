//
//  SectionedProductCollectionViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 9/9/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import Factory
import RxCleanArchitecture

final class SectionedProductCollectionViewController: UIViewController, Bindable {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: PagingCollectionView!
    
    // MARK: - Properties
    
    var viewModel: SectionedProductsViewModel!
    var disposeBag = DisposeBag()
    
    private var productSections = [SectionedProductsViewModel.ProductSectionViewModel]()
    private let editProductTrigger = PublishSubject<IndexPath>()
    
    struct LayoutOptions {
        var itemSpacing: CGFloat = 16
        var lineSpacing: CGFloat = 16
        var itemsPerRow: Int = 1
        
        var sectionInsets = UIEdgeInsets(
            top: 16.0,
            left: 0.0,
            bottom: 16.0,
            right: 0.0
        )
        
        var itemSize: CGSize {
            let screenSize = UIScreen.main.bounds
            
            let paddingSpace = sectionInsets.left
                + sectionInsets.right
                + CGFloat(itemsPerRow - 1) * itemSpacing
            
            let availableWidth = screenSize.width - paddingSpace
            let widthPerItem = availableWidth / CGFloat(itemsPerRow)
            let heightPerItem: CGFloat = 76
            
            return CGSize(width: widthPerItem, height: heightPerItem)
        }
    }
    
    private var layoutOptions = LayoutOptions()
    
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
        collectionView.do {
            $0.register(cellType: ProductCollectionCell.self)
            $0.register(supplementaryViewType: ProductCollectionHeaderView.self,
                        ofKind: UICollectionView.elementKindSectionHeader)
            $0.alwaysBounceVertical = true
            $0.delegate = self
            $0.dataSource = self
        }
        
        view.backgroundColor = ColorCompatibility.systemBackground
        collectionView.backgroundColor = ColorCompatibility.systemBackground
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
            reload: collectionView.refreshTrigger,
            loadMore: collectionView.loadMoreTrigger,
            selectProduct: collectionView.rx.itemSelected.asDriver(),
            editProduct: editProductTrigger.asDriverOnErrorJustComplete(),
            updatedProduct: updatedProductTrigger
        )
        
        let output = viewModel.transform(input, disposeBag: disposeBag)
        
        output.$productSections
            .asDriver()
            .drive(onNext: { [unowned self] productSections in
                self.productSections = productSections
                self.collectionView.reloadData()
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
            .drive(collectionView.isRefreshing)
            .disposed(by: disposeBag)
        
        output.$isLoadingMore
            .asDriver()
            .drive(collectionView.isLoadingMore)
            .disposed(by: disposeBag)
        
        output.$isEmpty
            .asDriver()
            .drive(collectionView.isEmpty)
            .disposed(by: disposeBag)
    }
}

// MARK: - StoryboardSceneBased
extension SectionedProductCollectionViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.product
}

// MARK: - UICollectionViewDelegate
extension SectionedProductCollectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return layoutOptions.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return layoutOptions.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return layoutOptions.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return layoutOptions.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
}

// MARK: - UICollectionViewDataSource
extension SectionedProductCollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return productSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productSections[section].productList.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let product = productSections[indexPath.section].productList[indexPath.row]
        
        return collectionView.dequeueReusableCell(for: indexPath, cellType: ProductCollectionCell.self)
            .then { [weak self] in
                $0.bindViewModel(product)
                $0.editProductAction = {
                    self?.editProductTrigger.onNext(indexPath)
                }
            }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let section = productSections[indexPath.section]
        
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                               for: indexPath,
                                                               viewType: ProductCollectionHeaderView.self)
            .then {
                $0.titleLabel.text = section.header
            }
    }
}

extension Container {
    func sectionedProductCollectionViewController(navigationController: UINavigationController) -> Factory<SectionedProductCollectionViewController> {
        Factory(self) {
            let vc = SectionedProductCollectionViewController.instantiate()
            let vm = SectionedProductsViewModel(navigationController: navigationController)
            vc.bindViewModel(to: vm)
            return vc
        }
    }
}
