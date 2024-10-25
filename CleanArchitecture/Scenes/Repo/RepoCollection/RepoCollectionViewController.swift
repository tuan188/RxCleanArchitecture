//
//  RepoCollectionViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/9/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable
import SDWebImage
import Factory
import RxCleanArchitecture
import PagingTableView

final class RepoCollectionViewController: UIViewController, Bindable {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: PagingCollectionView!
    
    // MARK: - Properties
    
    var viewModel: ReposViewModel!
    var disposeBag = DisposeBag()
    
    private var repoList = [RepoItemViewModel]()
    
    struct LayoutOptions {
        var itemSpacing: CGFloat = 16
        var lineSpacing: CGFloat = 16
        var itemsPerRow: Int = 2
        
        var sectionInsets = UIEdgeInsets(
            top: 16.0,
            left: 16.0,
            bottom: 16.0,
            right: 16.0
        )
        
        var itemSize: CGSize {
            let screenSize = UIScreen.main.bounds
            
            let paddingSpace = sectionInsets.left
                + sectionInsets.right
                + CGFloat(itemsPerRow - 1) * itemSpacing
            
            let availableWidth = screenSize.width - paddingSpace
            let widthPerItem = availableWidth / CGFloat(itemsPerRow)
            let heightPerItem = widthPerItem
            
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
            $0.register(cellType: RepoCollectionCell.self)
            $0.delegate = self
            $0.prefetchDataSource = self
            $0.alwaysBounceVertical = true
            $0.backgroundColor = ColorCompatibility.systemBackground
        }
        
        view.backgroundColor = ColorCompatibility.systemBackground
    }
    
    func bindViewModel() {
        let input = ReposViewModel.Input(
            load: Driver.just(()),
            reload: collectionView.refreshTrigger,
            loadMore: collectionView.loadMoreTrigger,
            selectRepo: collectionView.rx.itemSelected.asDriver()
        )
        
        let output = viewModel.transform(input, disposeBag: disposeBag)
        
        output.$repoList
            .asDriver()
            .do(onNext: { [unowned self] repoList in
                self.repoList = repoList
            })
            .drive(collectionView.rx.items) { collectionView, index, repo in
                return collectionView.dequeueReusableCell(
                    for: IndexPath(row: index, section: 0),
                    cellType: RepoCollectionCell.self
                )
                .then {
                    $0.bindViewModel(repo)
                }
            }
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
extension RepoCollectionViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.repo
}

// MARK: - UICollectionViewDelegate
extension RepoCollectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Set Collection View's Estimate Size to None in Storyboard
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
}

// MARK: - UICollectionViewDataSourcePrefetching
extension RepoCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths
            .compactMap { repoList[$0.row].url }
        
        print("Preheat", urls)
        SDWebImagePrefetcher.shared.prefetchURLs(urls)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
    }
}

extension Container {
    func repoCollectionViewController(navigationController: UINavigationController) -> Factory<RepoCollectionViewController> {
        Factory(self) {
            let vc = RepoCollectionViewController.instantiate()
            let vm = ReposViewModel(navigationController: navigationController)
            vc.bindViewModel(to: vm)
            return vc
        }
    }
}
