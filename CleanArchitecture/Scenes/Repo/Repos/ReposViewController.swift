//
//  ReposViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/28/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import SDWebImage
import Factory
import RxCleanArchitecture
import PagingTableView

final class ReposViewController: UIViewController, Bindable {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: PagingTableView!
    
    // MARK: - Properties
    
    var viewModel: ReposViewModel!
    var disposeBag = DisposeBag()
    
    private var repoList = [RepoItemViewModel]()
    
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
            $0.register(cellType: RepoCell.self)
            $0.delegate = self
            $0.prefetchDataSource = self
            $0.estimatedRowHeight = 550
            $0.rowHeight = UITableView.automaticDimension
        }
        
        view.backgroundColor = ColorCompatibility.systemBackground
    }

    func bindViewModel() {
        let input = ReposViewModel.Input(
            load: Driver.just(()),
            reload: tableView.refreshTrigger,
            loadMore: tableView.loadMoreTrigger,
            selectRepo: tableView.rx.itemSelected.asDriver()
        )
        
        let output = viewModel.transform(input, disposeBag: disposeBag)
        
        output.$repoList
            .asDriver()
            .do(onNext: { [unowned self] repoList in
                self.repoList = repoList
            })
            .drive(tableView.rx.items) { tableView, index, repo in
                return tableView.dequeueReusableCell(
                    for: IndexPath(row: index, section: 0),
                    cellType: RepoCell.self
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

// MARK: - UITableViewDelegate
extension ReposViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - StoryboardSceneBased
extension ReposViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.repo
}

// MARK: - UITableViewDataSourcePrefetching
extension ReposViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = indexPaths
            .compactMap { repoList[$0.row].url }
        
        print("Preheat", urls)
        SDWebImagePrefetcher.shared.prefetchURLs(urls)
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
    }
}

extension Container {
    func reposViewController(navigationController: UINavigationController) -> Factory<ReposViewController> {
        return Factory(self) {
            let vc = ReposViewController.instantiate()
            let vm = ReposViewModel(navigationController: navigationController)
            vc.bindViewModel(to: vm)
            return vc
        }
    }
}
