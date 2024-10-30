//
//  UserListViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 1/14/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import Factory
import RxCleanArchitecture

class UserListViewModel: FetchUsers {
    @Injected(\.userGateway)
    var userGatewayType: UserGatewayProtocol

    func showUserDetail(user: User) {
        print("User detail: \(user.name)")
    }
    
    func vm_getUsers() -> Observable<[User]> {
        fetchUsers()
    }
}

// MARK: - ViewModel
extension UserListViewModel: ViewModel {
    struct Input {
        let load: Driver<Void>
        let reload: Driver<Void>
        let selectUser: Driver<IndexPath>
    }
    
    struct Output {
        @Property var error: Error?
        @Property var isLoading = false
        @Property var isReloading = false
        @Property var userList = [UserItemViewModel]()
        @Property var isEmpty = false
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        let config = ListFetchConfig(
            loadTrigger: input.load,
            reloadTrigger: input.reload,
            fetchItems: { [unowned self] in
                vm_getUsers()
            })
        
        let (userList, error, isLoading, isReloading) = fetchList(config: config).destructured
        
        error
            .drive(output.$error)
            .disposed(by: disposeBag)
        
        isLoading
            .drive(output.$isLoading)
            .disposed(by: disposeBag)
        
        isReloading
            .drive(output.$isReloading)
            .disposed(by: disposeBag)
        
        userList
            .map { $0.map(UserItemViewModel.init) }
            .drive(output.$userList)
            .disposed(by: disposeBag)

        selectItem(at: input.selectUser, from: userList)
            .drive(onNext: showUserDetail)
            .disposed(by: disposeBag)
        
        isDataEmpty(loadingTrigger: Driver.merge(isLoading, isReloading),
                    dataItems: userList)
            .drive(output.$isEmpty)
            .disposed(by: disposeBag)
        
        return output
    }
}
