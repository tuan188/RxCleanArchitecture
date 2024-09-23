//
//  UserListViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 1/14/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import UIKit
import Reusable
import MGLoadMore
import MGArchitecture
import RxSwift
import RxCocoa
import Factory

final class UserListViewController: UIViewController, Bindable {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: PagingTableView!

    // MARK: - Properties
    
    var viewModel: UserListViewModel!
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
            $0.register(cellType: UserCell.self)
            $0.delegate = self
            $0.estimatedRowHeight = 550
            $0.rowHeight = UITableView.automaticDimension
            $0.refreshFooter = nil
            $0.removeRefreshControl()
        }
        
        view.backgroundColor = ColorCompatibility.systemBackground
    }

    func bindViewModel() {
        let input = UserListViewModel.Input(
            load: Driver.just(()),
            reload: tableView.refreshTrigger,
            selectUser: tableView.rx.itemSelected.asDriver()
        )

        let output = viewModel.transform(input, disposeBag: disposeBag)
        
        output.$userList
            .asDriver()
            .drive(tableView.rx.items) { tableView, index, user in
                return tableView.dequeueReusableCell(
                    for: IndexPath(row: index, section: 0),
                    cellType: UserCell.self
                )
                .then {
                    $0.bindViewModel(user)
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
        
        output.$isEmpty
            .asDriver()
            .drive()
            .disposed(by: disposeBag)
    }
}

// MARK: - Binders
extension UserListViewController {

}

// MARK: - UITableViewDelegate
extension UserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - StoryboardSceneBased
extension UserListViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.user
}

extension Container {
    func userListViewController() -> Factory<UserListViewController> {
        Factory(self) {
            let vc = UserListViewController.instantiate()
            let vm = UserListViewModel()
            vc.bindViewModel(to: vm)
            return vc
        }
    }
}
